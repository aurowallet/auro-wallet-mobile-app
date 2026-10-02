import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/components/importLedgerDialog.dart';
import 'package:auro_wallet/common/components/ledgerWaitingContent.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/ledger_error_message.dart';
import 'package:auro_wallet/ledgerMina/ledger_status_code.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_sign_message_operation.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/signatureDialog.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAccount.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

import 'ledger_connection_flow_test.dart'
    show FakeApi, FakeLedger, device, pumpFlow;

const address = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';

List<int> messageResponse(String message) {
  final bytes = utf8.encode('Message : $message');
  return [
    1,
    ...List.filled(31, 0),
    ...List.filled(31, 0),
    2,
    bytes.length,
    ...bytes,
  ];
}

class MessageLedger extends FakeLedger {
  String accountAddress = address;
  Object? messageFailure;
  Completer<void>? messageGate;

  @override
  Future<T> sendOperation<T>(
    LedgerDevice device,
    LedgerOperation<T> operation, {
    LedgerTransformer? transformer,
  }) async {
    if (operation is MinaPublicKeyOperation) {
      operations.add(operation);
      return await (accountsGate?.future ?? Future.value([accountAddress]))
          as T;
    }
    if (operation is MinaSignMessageOperation) {
      final messageOperation = operation as MinaSignMessageOperation;
      operations.add(operation);
      await messageGate?.future;
      if (messageFailure != null) throw messageFailure!;
      return await operation.read(
        ByteDataReader()..add(messageResponse(messageOperation.message)),
      );
    }
    return super.sendOperation(device, operation, transformer: transformer);
  }
}

class MessageApi extends FakeApi {
  MessageApi(super.context);
  @override
  late ApiAccount account;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MinaSignMessageOperation operation(
    String message, {
    int account = 7,
    int network = 1,
  }) => MinaSignMessageOperation(
    accountIndex: account,
    networkId: network,
    message: message,
  );

  test(
    'SIGN_MSG uses Mina CLA, account, network and UTF-8 byte length',
    () async {
      for (final message in ['hello', 'line 1\r\nline 2', '{"value":"test"}']) {
        final bytes = utf8.encode(message);
        expect((await operation(message).write(ByteDataWriter())).single, [
          0xe0,
          0x05,
          0,
          0,
          5 + bytes.length,
          0,
          0,
          0,
          7,
          1,
          ...bytes,
        ]);
      }
      expect(
        (await operation(
          'a',
          account: 0x01020304,
          network: 0,
        ).write(ByteDataWriter())).single.sublist(5, 10),
        [1, 2, 3, 4, 0],
      );
    },
  );

  test(
    'message contents reach the device unchanged within the APDU payload size',
    () async {
      for (final message in [
        '',
        'a' * 66,
        '你好',
        'a\u0000b',
        'a\tb',
        '😀',
        'a' * 250,
      ]) {
        final bytes = utf8.encode(message);
        final apdu = (await operation(message).write(ByteDataWriter())).single;
        expect(apdu[4], 5 + bytes.length);
        expect(apdu.sublist(10), bytes);
      }
      for (final message in ['a' * 251, '你' * 84]) {
        await expectLater(
          operation(message).write(ByteDataWriter()),
          throwsFormatException,
        );
      }
      for (final op in [
        operation('a', account: -1),
        operation('a', account: 0x100000000),
        operation('a', network: 2),
      ]) {
        await expectLater(op.write(ByteDataWriter()), throwsFormatException);
      }
    },
  );

  test(
    'message parser preserves firmware prefix and big-endian decimal signature',
    () async {
      final result = await operation(
        'hello',
      ).read(ByteDataReader()..add(messageResponse('hello')));
      expect(result, {
        'data': 'Message : hello',
        'signature': {'field': (BigInt.one << 248).toString(), 'scalar': '2'},
      });
    },
  );

  test(
    'message parser rejects short, mismatched, malformed and extra data',
    () async {
      final response = messageResponse('hello');
      for (final bytes in [
        <int>[],
        response.sublist(0, 64),
        response.sublist(0, response.length - 1),
        [...response, 0],
        messageResponse('other'),
        [...response.sublist(0, response.length - 1), 255],
      ]) {
        await expectLater(
          operation('hello').read(ByteDataReader()..add(bytes)),
          throwsFormatException,
        );
      }
    },
  );

  late MessageLedger ledger;
  late WalletData wallet;
  final toasts = <String>[];

  setUp(() {
    ledger = MessageLedger();
    toasts.clear();
    globalAppStore.ledger = LedgerStore()
      ..setLedger(ledger)
      ..setDevice(device);
    globalAppStore.settings = SettingsStore(globalAppStore)
      ..currentNode = defaultNetworkList.first;
    globalAppStore.assets = AssetsStore(globalAppStore);
    wallet = WalletData()
      ..id = 'ledger-wallet'
      ..walletType = WalletStore.seedTypeLedger
      ..accounts = [
        AccountData()
          ..pubKey = address
          ..name = 'Ledger account'
          ..accountIndex = 7,
      ]
      ..currentAccountIndex = 7;
    globalAppStore.wallet = WalletStore(globalAppStore)
      ..walletList.add(wallet)
      ..currentWalletId = wallet.id;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (call) async {
            if (call.method == 'showToast')
              toasts.add(call.arguments['msg'] as String);
            return true;
          },
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (data) async {
            return const StandardMessageCodec().encodeMessage([null]);
          },
        );
  });

  tearDown(() async {
    await ledger.discoveries.close();
  });

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          webApi = MessageApi(context);
          webApi.account = ApiAccount(webApi);
          return child;
        },
      ),
    ),
  );

  for (final method in ['mina_signMessage', 'mina_sign_JsonMessage']) {
    testWidgets(
      '$method signs with the requested account/network and returns the extension shape',
      (tester) async {
        tester.view.physicalSize = const Size(1800, 2700);
        addTearDown(tester.view.resetPhysicalSize);
        ledger.messageGate = Completer<void>();
        Map? result;
        final Object content = method == 'mina_signMessage'
            ? 'hello'
            : [
                {'label': 'test', 'value': 'hello'},
              ];
        await tester.pumpWidget(
          host(
            SignatureDialog(
              method: method,
              content: content,
              url: 'https://example.com',
              signWallet: wallet,
              fromAddress: address,
              walletConnectChainId: 'mina:devnet',
              onConfirm: (data) async {
                result = data;
              },
            ),
          ),
        );
        await pumpFlow(tester);
        final confirm = tester
            .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
            .onConfirm;
        final signing = confirm() as Future<bool>;
        expect(await confirm(), isFalse);
        await pumpFlow(tester);
        expect(find.byType(LedgerWaitingContent), findsOneWidget);
        expect(result, isNull);
        final op = ledger.operations
            .whereType<MinaSignMessageOperation>()
            .single;
        expect(op.accountIndex, 7);
        expect(op.networkId, 0);
        expect(
          op.message,
          method == 'mina_signMessage' ? content : jsonEncode(content),
        );
        expect(
          ledger.operations
              .whereType<MinaPublicKeyOperation>()
              .single
              .showAddressInDevice,
          isFalse,
        );
        ledger.messageGate!.complete();
        expect(await signing, isTrue);
        await pumpFlow(tester);
        expect(result, {
          'publicKey': address,
          'data': 'Message : ${op.message}',
          'signature': {'field': (BigInt.one << 248).toString(), 'scalar': '2'},
        });
        expect(find.byType(LedgerWaitingContent), findsNothing);
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isFalse,
        );
        expect(toasts, isEmpty);
      },
    );
  }

  testWidgets('wrong Ledger account cannot sign a message', (tester) async {
    ledger.accountAddress = 'different account';
    await tester.pumpWidget(host(const Text('Host')));
    final context = tester.element(find.text('Host'));
    final result = await webApi.account.ledgerSignMessage(
      context: context,
      message: 'hello',
      accountIndex: 7,
      fromAddress: address,
      networkId: 'mina:mainnet',
    );
    expect(result, isNull);
    expect(ledger.operations.whereType<MinaSignMessageOperation>(), isEmpty);
    expect(toasts, [AppLocalizations.of(context)!.ledgerAccountMismatch]);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'preparation keeps confirmation loading until Ledger interaction',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      ledger.versionGate = Completer<void>();
      ledger.messageGate = Completer<void>();
      await tester.pumpWidget(
        host(
          SignatureDialog(
            method: 'mina_signMessage',
            content: 'hello',
            url: 'https://example.com',
            onConfirm: (_) async {},
          ),
        ),
      );
      await pumpFlow(tester);
      final pending =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      expect(find.byType(LedgerWaitingContent), findsNothing);
      expect(
        tester
            .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
            .submitting,
        isTrue,
      );
      expect(ledger.operations.whereType<MinaPublicKeyOperation>(), isEmpty);
      ledger.versionGate!.complete();
      await pumpFlow(tester);
      expect(find.byType(LedgerWaitingContent), findsOneWidget);
      ledger.messageGate!.complete();
      expect(await pending, isTrue);
    },
  );

  testWidgets(
    'closing before readiness completes cannot start message signing',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      ledger.versionGate = Completer<void>();
      await tester.pumpWidget(
        host(
          SignatureDialog(
            method: 'mina_signMessage',
            content: 'hello',
            url: 'https://example.com',
            onConfirm: (_) {
              fail('Closed request must not deliver a result');
            },
          ),
        ),
      );
      await pumpFlow(tester);
      final pending =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      await tester.pumpWidget(host(const Text('Host')));
      ledger.versionGate!.complete();
      expect(await pending, isFalse);
      expect(ledger.operations.whereType<MinaPublicKeyOperation>(), isEmpty);
      expect(ledger.operations.whereType<MinaSignMessageOperation>(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancelled address lookup cannot proceed to message signing', (
    tester,
  ) async {
    ledger.accountsGate = Completer<List<String>>();
    await tester.pumpWidget(host(const Text('Host')));
    final context = tester.element(find.text('Host'));
    var active = true;
    final pending = webApi.account.ledgerSignMessage(
      context: context,
      message: 'hello',
      accountIndex: 7,
      fromAddress: address,
      networkId: 'mina:mainnet',
      onLedgerInteraction: () => active,
    );
    await pumpFlow(tester);
    active = false;
    ledger.accountsGate!.complete([address]);
    expect(await pending, isNull);
    expect(ledger.operations.whereType<MinaSignMessageOperation>(), isEmpty);
    expect(toasts, isEmpty);
  });

  testWidgets(
    'mainnet message signing keeps the requested network during device lookup',
    (tester) async {
      ledger.accountsGate = Completer<List<String>>();
      await tester.pumpWidget(host(const Text('Host')));
      final context = tester.element(find.text('Host'));
      final pending = webApi.account.ledgerSignMessage(
        context: context,
        message: 'hello',
        accountIndex: 7,
        fromAddress: address,
        networkId: 'mina:mainnet',
      );
      await pumpFlow(tester);
      globalAppStore.settings!.currentNode = defaultNetworkList.last;
      ledger.accountsGate!.complete([address]);
      expect(await pending, isNotNull);
      expect(
        ledger.operations
            .whereType<MinaSignMessageOperation>()
            .single
            .networkId,
        1,
      );
    },
  );

  for (final code in [
    LedgerStatusCode.userRejected,
    LedgerStatusCode.deviceLocked,
    LedgerStatusCode.deviceBusy,
    LedgerStatusCode.instructionUnsupported,
  ]) {
    testWidgets('message signing error $code resets waiting and loading', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      ledger.messageFailure = LedgerException(errorCode: code);
      var delivered = false;
      await tester.pumpWidget(
        host(
          SignatureDialog(
            method: 'mina_signMessage',
            content: 'hello',
            url: 'https://example.com',
            onConfirm: (_) {
              delivered = true;
            },
          ),
        ),
      );
      await pumpFlow(tester);
      final pending =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      expect(await pending, isFalse);
      expect(delivered, isFalse);
      expect(find.byType(LedgerWaitingContent), findsNothing);
      expect(
        tester
            .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
            .submitting,
        isFalse,
      );
      expect(
        ledger.operations.whereType<MinaSignMessageOperation>(),
        hasLength(1),
      );
      final dic = AppLocalizations.of(
        tester.element(find.byType(SignatureDialog)),
      )!;
      expect(toasts, [
        ledgerFailureMessage(dic, classifyLedgerErrorCode(code)),
      ]);
      await tester.pump(const Duration(seconds: 1));
    });
  }

  for (final rejected in [false, true]) {
    testWidgets('message ${rejected ? "rejection" : "success"} clears loading before wakelock release', (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      final release = Completer<ByteData?>();
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
            'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
            (_) async => ++calls == 1
                ? const StandardMessageCodec().encodeMessage([null])
                : await release.future,
          );
      ledger.messageGate = Completer<void>();
      if (rejected) {
        ledger.messageFailure = LedgerException(errorCode: LedgerStatusCode.userRejected);
      }
      await tester.pumpWidget(host(SignatureDialog(
        method: 'mina_signMessage',
        content: 'hello',
        url: 'https://example.com',
        onConfirm: (_) {},
      )));
      final pending = tester.widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
          .onConfirm() as Future<bool>;
      await pumpFlow(tester);
      expect(find.byType(LedgerWaitingContent), findsOneWidget);
      ledger.messageGate!.complete();
      await pumpFlow(tester);
      expect(calls, 2);
      expect(release.isCompleted, isFalse);
      expect(find.byType(LedgerWaitingContent), findsNothing);
      expect(tester.widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton)).submitting, isFalse);
      await tester.pump(const Duration(seconds: 5));
      expect(await pending, !rejected);
      release.complete(const StandardMessageCodec().encodeMessage([null]));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  for (final stage in ['address timeout', 'signature disconnect']) {
    testWidgets(
      '$stage still reports failure after the BLE session is cleared',
      (tester) async {
        tester.view.physicalSize = const Size(1800, 2700);
        addTearDown(tester.view.resetPhysicalSize);
        if (stage == 'address timeout') {
          ledger.accountsGate = Completer<List<String>>();
        } else {
          ledger.messageGate = Completer<void>();
          ledger.messageFailure = LedgerException(
            message: 'Ledger BLE disconnected.',
          );
        }
        await tester.pumpWidget(
          host(
            SignatureDialog(
              method: 'mina_signMessage',
              content: 'hello',
              url: 'https://example.com',
              onConfirm: (_) {
                fail('Disconnected request must not succeed');
              },
            ),
          ),
        );
        await pumpFlow(tester);
        final pending =
            tester
                    .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                    .onConfirm()
                as Future<bool>;
        await pumpFlow(tester);
        expect(find.byType(LedgerWaitingContent), findsOneWidget);
        globalAppStore.ledger!.setDevice(null);
        if (stage == 'address timeout') {
          ledger.accountsGate!.completeError(
            TimeoutException('Ledger address timed out.'),
          );
        } else {
          ledger.messageGate!.complete();
        }
        expect(await pending, isFalse);
        await pumpFlow(tester);
        final dic = AppLocalizations.of(
          tester.element(find.byType(SignatureDialog)),
        )!;
        expect(toasts, [dic.buildFailed]);
        expect(find.byType(ImportLedger), findsNothing);
        expect(find.byType(LedgerWaitingContent), findsNothing);
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isFalse,
        );
        expect(
          globalAppStore.ledger!.ledgerStatus,
          LedgerStatusTypes.unavailable,
        );
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }

  for (final close in ['close icon', 'back']) {
    testWidgets(
      '$close during a message signature rejects once and ignores a late response',
      (tester) async {
        tester.view.physicalSize = const Size(1800, 2700);
        addTearDown(tester.view.resetPhysicalSize);
        ledger.messageGate = Completer<void>();
        await tester.pumpWidget(host(const Text('Host')));
        final context = tester.element(find.text('Host'));
        var delivered = 0;
        var cancelled = 0;
        final sheet = UI.showSignatureAction(
          context: context,
          method: 'mina_signMessage',
          content: 'hello',
          url: 'https://example.com',
          onConfirm: (_) async {
            delivered++;
          },
          onCancel: () {
            cancelled++;
          },
        );
        await pumpFlow(tester);
        final lateCancel = tester
            .widget<SignatureDialog>(find.byType(SignatureDialog))
            .onCancel!;
        final pending =
            tester
                    .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                    .onConfirm()
                as Future<bool>;
        await pumpFlow(tester);
        expect(find.text('Cancel'), findsNothing);
        final title = tester.widget<BrowserDialogTitleRow>(
          find.byType(BrowserDialogTitleRow),
        );
        expect(title.showCloseIcon, isTrue);
        expect(title.showChainType, isFalse);
        expect(title.showLedgerStatus, isFalse);
        if (close == 'close icon') {
          await tester.tap(find.descendant(
            of: find.byType(BrowserDialogTitleRow),
            matching: find.byType(GestureDetector),
          ));
        } else {
          Navigator.of(context).pop();
        }
        await pumpFlow(tester);
        await sheet;
        lateCancel();
        ledger.messageGate!.complete();
        expect(await pending, isFalse);
        await pumpFlow(tester);
        expect(delivered, 0);
        expect(cancelled, 1);
        expect(ledger.disconnects, 1);
        expect(find.text('Host'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(toasts, isEmpty);
      },
    );
  }

  testWidgets(
    'failed dApp response delivery allows retry from the same sheet',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(host(const Text('Host')));
      final context = tester.element(find.text('Host'));
      var attempts = 0;
      final sheet = UI.showSignatureAction(
        context: context,
        method: 'mina_signMessage',
        content: 'hello',
        url: 'https://example.com',
        onConfirm: (_) async {
          if (++attempts == 1) throw StateError('Response delivery failed');
        },
      );
      await pumpFlow(tester);
      final first =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      expect(await first, isFalse);
      final second =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      expect(await second, isTrue);
      expect(attempts, 2);
      await sheet;
      expect(find.byType(SignatureDialog), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'screen-awake release failure cannot leave message confirmation loading',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      var toggles = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
            'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
            (_) async {
              return const StandardMessageCodec().encodeMessage(
                ++toggles == 1
                    ? [null]
                    : ['release_failed', 'test release failed', null],
              );
            },
          );
      await tester.pumpWidget(
        host(
          SignatureDialog(
            method: 'mina_signMessage',
            content: 'hello',
            url: 'https://example.com',
            onConfirm: (_) async {},
          ),
        ),
      );
      await pumpFlow(tester);
      final pending =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<bool>;
      await pumpFlow(tester);
      expect(await pending, isTrue);
      expect(
        tester
            .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
            .submitting,
        isFalse,
      );
      expect(find.byType(LedgerWaitingContent), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('successful message request returns once and closes its sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1800, 2700);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host(const Text('Host')));
    final context = tester.element(find.text('Host'));
    var delivered = 0;
    var cancelled = 0;
    final sheet = UI.showSignatureAction(
      context: context,
      method: 'mina_signMessage',
      content: 'hello',
      url: 'https://example.com',
      onConfirm: (_) async {
        delivered++;
      },
      onCancel: () {
        cancelled++;
      },
    );
    await pumpFlow(tester);
    final pending =
        tester
                .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                .onConfirm()
            as Future<bool>;
    await pumpFlow(tester);
    expect(await pending, isTrue);
    await sheet;
    expect(delivered, 1);
    expect(cancelled, 0);
    expect(find.byType(SignatureDialog), findsNothing);
    expect(find.text('Host'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Mina app recovery opens only once for repeated signing failure',
    (tester) async {
      ledger.messageFailure = LedgerException(
        errorCode: LedgerStatusCode.mobileMinaAppNotOpen,
      );
      await tester.pumpWidget(host(const Text('Host')));
      final context = tester.element(find.text('Host'));
      final pending = webApi.account.ledgerSignMessage(
        context: context,
        message: 'hello',
        accountIndex: 7,
        fromAddress: address,
        networkId: 'mina:mainnet',
      );
      await pumpFlow(tester);
      expect(find.byType(ImportLedger), findsOneWidget);
      await tester.tap(find.text('689C'));
      await pumpFlow(tester);
      expect(await pending, isNull);
      expect(find.byType(ImportLedger), findsNothing);
      expect(
        ledger.operations.whereType<MinaSignMessageOperation>(),
        hasLength(2),
      );
      expect(toasts, [AppLocalizations.of(context)!.openMinaApp]);
      await tester.pump(const Duration(seconds: 1));
    },
  );

  for (final method in ['mina_signFields', 'mina_createNullifier']) {
    testWidgets('$method remains unsupported like the extension', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        host(
          SignatureDialog(
            method: method,
            content: ['1'],
            url: 'https://example.com',
            onConfirm: (_) {},
          ),
        ),
      );
      await pumpFlow(tester);
      expect(
        await tester
            .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
            .onConfirm(),
        isFalse,
      );
      expect(ledger.operations.whereType<MinaSignMessageOperation>(), isEmpty);
      expect(ledger.operations.whereType<MinaPublicKeyOperation>(), isEmpty);
      await tester.pump(const Duration(seconds: 1));
    });
  }

  for (final network in ['zeko:mainnet', 'zeko:testnet', 'unknown:network']) {
    testWidgets('$network is rejected before message signing', (tester) async {
      await tester.pumpWidget(host(const Text('Host')));
      final context = tester.element(find.text('Host'));
      expect(
        await webApi.account.ledgerSignMessage(
          context: context,
          message: 'hello',
          accountIndex: 7,
          fromAddress: address,
          networkId: network,
        ),
        isNull,
      );
      expect(ledger.operations, isEmpty);
      expect(toasts, [AppLocalizations.of(context)!.notSupportNow]);
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets(
    'message content restrictions are left to Ledger without an early toast',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 2700);
      addTearDown(tester.view.resetPhysicalSize);
      for (final message in ['', 'a' * 66, '你好']) {
        ledger.messageGate = Completer<void>();
        ledger.messageFailure = LedgerException(
          errorCode: LedgerStatusCode.errorExecution,
        );
        globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
        toasts.clear();
        await tester.pumpWidget(
          host(
            SignatureDialog(
              method: 'mina_signMessage',
              content: message,
              url: 'https://example.com',
              onConfirm: (_) {
                fail('A failed device response must not succeed');
              },
            ),
          ),
        );
        await pumpFlow(tester);
        final pending =
            tester
                    .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                    .onConfirm()
                as Future<bool>;
        await pumpFlow(tester);
        expect(
          ledger.operations.whereType<MinaSignMessageOperation>().last.message,
          message,
        );
        expect(toasts, isEmpty);
        expect(find.byType(LedgerWaitingContent), findsOneWidget);
        ledger.messageGate!.complete();
        expect(await pending, isFalse);
        await pumpFlow(tester);
        final dic = AppLocalizations.of(
          tester.element(find.byType(SignatureDialog)),
        )!;
        expect(toasts, [
          ledgerFailureMessage(
            dic,
            classifyLedgerErrorCode(LedgerStatusCode.errorExecution),
          ),
        ]);
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isFalse,
        );
        await tester.pump(const Duration(seconds: 1));
      }
    },
  );
}
