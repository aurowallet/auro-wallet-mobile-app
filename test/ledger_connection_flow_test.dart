import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/components/importLedgerDialog.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/ledgerWaitingContent.dart';
import 'package:auro_wallet/common/components/ledgerStatusView.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/ledger_status_code.dart';
import 'package:auro_wallet/ledgerMina/ledger_error_message.dart';
import 'package:auro_wallet/ledgerMina/mina_version.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_version_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_sign_transfer_operation.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAccount.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/ledgerInit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final device = LedgerDevice(
  id: 'test-nano',
  name: '689C',
  connectionType: ConnectionType.ble,
);

class FakeLedger extends Fake implements Ledger {
  final operations = <LedgerOperation>[];
  final discoveries = StreamController<LedgerDevice>.broadcast();
  String appName = 'Mina';
  Object? failure;
  Object? connectFailure;
  Object? signingFailure;
  String? transferSignature;
  Completer<void>? signingGate;
  Completer<void>? versionGate;
  Completer<List<String>>? accountsGate;
  final disconnectedDevices = <LedgerDevice>[];
  Object? versionFailure;
  int scans = 0;
  int connects = 0;
  int disconnects = 0;

  @override
  Future<T> sendOperation<T>(
    LedgerDevice device,
    LedgerOperation<T> operation, {
    LedgerTransformer? transformer,
  }) async {
    operations.add(operation);
    if (failure != null) throw failure!;
    if (operation is MinaPublicKeyOperation || operation is MinaSignTransferOperation) {
      await signingGate?.future;
      if (signingFailure != null) throw signingFailure!;
    }
    if (operation is MinaNameOperation) {
      const appVersion = '1.2.3';
      // Exercise the real parser with a response payload (status already removed).
      return await operation.read(ByteDataReader()..add([
        1, // Response format identifier.
        appName.length,
        ...ascii.encode(appName),
        appVersion.length,
        ...ascii.encode(appVersion),
        // Simulate a Dashboard response without flags; apps include length + flags.
        if (appName != 'BOLOS') ...[1, 0x80],
      ]));
    }
    if (operation is MinaVersionOperation) {
      await versionGate?.future;
      if (versionFailure != null) throw versionFailure!;
      return MinaVersion(versionMajor: 1, versionMinor: 2, versionPatch: 3)
          as T;
    }
    if (operation is MinaPublicKeyOperation && accountsGate != null) {
      return await accountsGate!.future as T;
    }
    if (operation is MinaSignTransferOperation && transferSignature != null) {
      return transferSignature as T;
    }
    throw StateError('Connection must not derive a key or sign a transaction');
  }

  @override
  Future<void> disconnect(LedgerDevice device) async {
    disconnects++;
    disconnectedDevices.add(device);
  }

  @override
  Future<void> connect(LedgerDevice device, {LedgerOptions? options}) async {
    connects++;
    if (connectFailure != null) throw connectFailure!;
  }

  @override
  Future<void> stopScanning() async {}
  @override
  Stream<LedgerDevice> scan({LedgerOptions? options}) {
    scans++;
    return discoveries.stream;
  }
}

class FakeApi extends Fake implements Api {
  FakeApi(this.context);
  @override
  final BuildContext context;
}

Future<void> pumpFlow(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeLedger ledger;
  final toasts = <String>[];
  setUp(() {
    ledger = FakeLedger();
    toasts.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (call) async {
            if (call.method == 'showToast')
              toasts.add(call.arguments['msg'] as String);
            return true;
          },
        );
    globalAppStore.ledger = LedgerStore()
      ..setLedger(ledger)
      ..setDevice(device);
    globalAppStore.settings = SettingsStore(globalAppStore);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (_) async => const StandardMessageCodec().encodeMessage([null]),
        );
  });
  tearDown(() async {
    await LedgerInit.stopScanLoop(ledger: ledger);
    await ledger.discoveries.close();
  });

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );

  Widget readinessHost(void Function(bool) onResult) => host(
    Builder(
      builder: (context) => TextButton(
        onPressed: () async => onResult(
          await UI.ensureLedgerReady(
            context: context,
            ledgerStore: globalAppStore.ledger!,
            stage: 'Ledger shared readiness test',
          ),
        ),
        child: const Text('Check Ledger'),
      ),
    ),
  );

  test('readiness only reads active app and Mina version', () async {
    await MinaLedgerApp(ledger).ensureMinaAppReady(device);
    expect(ledger.operations.map((e) => e.runtimeType), [
      MinaNameOperation,
      MinaVersionOperation,
    ]);
  });

  for (final name in ['BOLOS', 'Ethereum']) {
    test('readiness rejects $name without issuing Mina operations', () async {
      ledger.appName = name;
      await expectLater(
        MinaLedgerApp(ledger).ensureMinaAppReady(device),
        throwsA(
          isA<LedgerException>().having((e) => e.errorCode, 'code', 0x6511),
        ),
      );
      expect(ledger.operations, hasLength(1));
    });
  }

  test(
    'app information uses length fields, including multi-digit versions',
    () async {
      final operation = MinaNameOperation();
      expect((await operation.write(ByteDataWriter())).single, [
        0xb0,
        0x01,
        0,
        0,
        0,
      ]);
      final reader = ByteDataReader()
        ..add([
          1,
          4,
          ...ascii.encode('Mina'),
          6,
          ...ascii.encode('1.10.0'),
          1,
          0x80,
        ]);
      final info = await operation.read(reader);
      expect(info.name, 'Mina');
      expect(info.version, '1.10.0');
    },
  );

  test('Dashboard app information has no flags field', () async {
    // Ledger DMK GetAppAndVersionCommand's BOLOS response, without status bytes.
    final reader = ByteDataReader()..add([
      1, 5, 66, 79, 76, 79, 83, 9, 49, 46, 52, 46, 48, 45, 114, 99, 50,
    ]);
    final info = await MinaNameOperation().read(reader);
    expect(info.name, 'BOLOS');
    expect(info.version, '1.4.0-rc2');
  });

  test('app information accepts an explicitly empty flags field', () async {
    final reader = ByteDataReader()..add([
      1, 4, ...ascii.encode('Mina'), 5, ...ascii.encode('1.2.3'), 0,
    ]);
    final info = await MinaNameOperation().read(reader);
    expect(info.name, 'Mina');
    expect(info.version, '1.2.3');
  });

  test('malformed app information cannot mark a connection ready', () async {
    for (final bytes in <List<int>>[
      [],
      [2],
      [1, 4, 77],
      [1, 0],
      [1, 4, ...ascii.encode('Mina'), 5, ...ascii.encode('1.2.3'), 2, 0x80],
      [1, 4, ...ascii.encode('Mina'), 5, ...ascii.encode('1.2.3'), 0, 0x80],
    ]) {
      await expectLater(
        MinaNameOperation().read(ByteDataReader()..add(bytes)),
        throwsFormatException,
      );
    }
  });

  testWidgets('new device selection closes sheet and hands off session', (
    tester,
  ) async {
    globalAppStore.ledger!.setDevice(null);
    bool? connected;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              connected = await UI.showImportLedgerDialog(context: context);
            },
            child: const Text('Connect'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Connect'));
    await pumpFlow(tester);
    ledger.discoveries.add(device);
    await pumpFlow(tester);
    await tester.tap(find.text('689C'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await pumpFlow(tester);
    expect(connected, isTrue);
    expect(find.byType(ImportLedger), findsNothing);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
    expect(ledger.disconnects, 0);
    expect(ledger.operations.map((e) => e.runtimeType), [
      MinaNameOperation,
      MinaVersionOperation,
    ]);
  });

  testWidgets('closed Mina remains visible and opening Mina allows retry', (
    tester,
  ) async {
    ledger.appName = 'BOLOS';
    bool? connected;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              connected = await UI.showImportLedgerDialog(context: context);
            },
            child: const Text('Connect'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Connect'));
    await pumpFlow(tester);
    final context = tester.element(find.byType(ImportLedger));
    expect(
      find.text(AppLocalizations.of(context)!.openMinaApp),
      findsOneWidget,
    );
    expect(
      find.text(AppLocalizations.of(context)!.ledgerConnectionError),
      findsNothing,
    );
    expect(ledger.operations.map((op) => op.runtimeType), [MinaNameOperation]);
    expect(ledger.disconnects, 0);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unavailable);
    expect(connected, isNull);
    ledger.appName = 'Mina';
    await tester.tap(find.text('689C'));
    await pumpFlow(tester);
    expect(connected, isTrue);
    expect(find.byType(ImportLedger), findsNothing);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
    expect(ledger.disconnects, 0);
  });

  testWidgets('probe timeout remains visible while discovery resumes', (
    tester,
  ) async {
    ledger.failure = TimeoutException('probe timed out');
    await tester.pumpWidget(host(ImportLedger()));
    await pumpFlow(tester);
    final context = tester.element(find.byType(ImportLedger));
    expect(
      find.text(AppLocalizations.of(context)!.ledgerConnectionError),
      findsOneWidget,
    );
    expect(
      find.text(AppLocalizations.of(context)!.ledgerPairingError),
      findsNothing,
    );
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unavailable);
    expect(ledger.disconnects, 1);
    ledger.discoveries.add(device);
    await pumpFlow(tester);
    expect(find.text('689C'), findsOneWidget);
    expect(
      find.text(AppLocalizations.of(context)!.ledgerConnectionError),
      findsOneWidget,
    );
  });

  testWidgets(
    'token cold connection returns to overview and starts business flow once',
    (tester) async {
      globalAppStore.ledger!.setDevice(null);
      var confirmations = 0;
      final transaction = Completer<void>();
      await tester.pumpWidget(
        host(
          TxConfirmDialog(
            items: const [],
            title: 'Transaction overview',
            isLedger: true,
            ledgerZkApp: true,
            onConfirm: (onLedgerInteraction) async {
              confirmations++;
              expect(onLedgerInteraction(), isTrue);
              await transaction.future;
            },
          ),
        ),
      );
      await pumpFlow(tester);
      await tester.tap(find.text('Confirm'));
      await pumpFlow(tester);
      expect(find.byType(ImportLedger), findsOneWidget);
      expect(confirmations, 0);
      ledger.discoveries.add(device);
      await pumpFlow(tester);
      await tester.tap(find.text('689C'));
      await pumpFlow(tester);
      expect(find.byType(ImportLedger), findsNothing);
      expect(confirmations, 1);
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
      expect(ledger.operations.map((op) => op.runtimeType), [
        MinaNameOperation,
        MinaVersionOperation,
      ]);
      transaction.complete();
      await pumpFlow(tester);
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
      // Returning to the overview refreshes the shared status after signing.
      expect(ledger.operations, hasLength(4));
      expect(ledger.disconnects, 0);
    },
  );

  for (final zkApp in [false, true]) {
    testWidgets(
      '${zkApp ? "token" : "MINA"} confirmation proceeds after identical readiness checks',
      (tester) async {
        var confirmations = 0;
        await tester.pumpWidget(
          host(
            TxConfirmDialog(
              items: const [],
              title: 'Transaction overview',
              isLedger: true,
              ledgerZkApp: zkApp,
              onConfirm: (_) async {
                confirmations++;
              },
            ),
          ),
        );
        await pumpFlow(tester);
        ledger.operations.clear();
        await tester.tap(find.text('Confirm'));
        await pumpFlow(tester);
        expect(confirmations, 1);
        expect(
          globalAppStore.ledger!.ledgerStatus,
          LedgerStatusTypes.available,
        );
        expect(
          ledger.operations.every(
            (op) => op is MinaNameOperation || op is MinaVersionOperation,
          ),
          isTrue,
        );
        expect(ledger.disconnects, 0);
      },
    );
  }

  testWidgets(
    'exhausted connection attempts replace a previous pairing error',
    (tester) async {
      ledger.connectFailure = StateError('test connection failed');
      globalAppStore.ledger!.setDevice(null);
      await tester.pumpWidget(host(ImportLedger(
        initialLedgerFailure: LedgerFailureType.pairing,
      )));
      await pumpFlow(tester);
      ledger.discoveries.add(device);
      await pumpFlow(tester);
      await tester.tap(find.text('689C'));
      for (var i = 0; i < 5; i++) {
        await pumpFlow(tester);
      }
      final dic = AppLocalizations.of(
        tester.element(find.byType(ImportLedger)),
      )!;
      expect(ledger.connects, 3);
      expect(
        globalAppStore.ledger!.ledgerStatus,
        LedgerStatusTypes.unavailable,
      );
      expect(find.text(dic.ledgerConnectionError), findsOneWidget);
      expect(find.text(dic.ledgerPairingError), findsNothing);
      expect(toasts, isEmpty);
      ledger.discoveries.add(device);
      await pumpFlow(tester);
      expect(find.text('689C'), findsOneWidget);
    },
  );

  for (final flow in [(false, false), (true, false), (true, true)]) {
    testWidgets(
      'confirmation error fallback is scoped: ledger=${flow.$1}, zkApp=${flow.$2}',
      (tester) async {
        final failure = StateError('transaction failed');
        await tester.pumpWidget(
          host(
            TxConfirmDialog(
              items: const [],
              title: 'Transaction overview',
              isLedger: flow.$1,
              ledgerZkApp: flow.$2,
              onConfirm: (_) async {
                throw failure;
              },
            ),
          ),
        );
        await pumpFlow(tester);
        final button = tester.widget<ZkAppBottomButton>(
          find.byType(ZkAppBottomButton),
        );
        final future = button.onConfirm() as Future<void>;
        if (flow.$1 && flow.$2) {
          await future;
          await pumpFlow(tester);
          final dic = AppLocalizations.of(
            tester.element(find.byType(TxConfirmDialog)),
          )!;
          expect(toasts, [dic.buildFailed]);
        } else {
          await expectLater(future, throwsA(same(failure)));
          await pumpFlow(tester);
          expect(toasts, isEmpty);
        }
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isFalse,
        );
      },
    );
  }

  for (final submit in [false, true]) {
    testWidgets(
      'token ${submit ? "submit" : "build"} API reports each request failure once',
      (tester) async {
        await tester.pumpWidget(host(const SizedBox()));
        final context = tester.element(find.byType(SizedBox).first);
        final account = ApiAccount(FakeApi(context));
        for (final response in [
          http.Response('{"message":"service unavailable"}', 503),
          http.Response('service unavailable', 503),
          if (submit) http.Response('[]', 200),
          http.ClientException('network unavailable'),
        ]) {
          toasts.clear();
          final client = MockClient((request) async {
            if (response is http.Response) return response;
            throw response;
          });
          final result = await http.runWithClient(
            () => submit
                ? account.postTokenResult({})
                : account.buildTokenBody({}),
            () => client,
          );
          // Fluttertoast resets its state on a one-second timer.
          await pumpFlow(tester);
          expect(result, isNull);
          expect(toasts, hasLength(1));
          if (response is http.Response &&
              response.statusCode == 503 &&
              submit) {
            expect(toasts.single, 'service unavailable');
          }
        }
      },
    );
  }

  testWidgets(
    'shared failure messages retain every classification in all locales',
    (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        final dic = await AppLocalizations.delegate.load(locale);
        final messages = {
          LedgerFailureType.rejected: dic.ledgerReject,
          LedgerFailureType.busy: dic.ledgerBusyTip,
          LedgerFailureType.locked: dic.unlockLedger,
          LedgerFailureType.appNotOpen: dic.openMinaApp,
          LedgerFailureType.unsupported: dic.ledgerZkAppUpdateRequired,
          LedgerFailureType.pairing: dic.ledgerPairingError,
          LedgerFailureType.other: dic.buildFailed,
        };
        for (final entry in messages.entries) {
          expect(ledgerFailureMessage(dic, entry.key), entry.value);
        }
      }
    },
  );

  for (final code in [0x9001, 0x5515, 0x6511, 0x6d00]) {
    testWidgets('shared readiness preserves error $code in sheet until retry', (
      tester,
    ) async {
      ledger.failure = LedgerException(errorCode: code);
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      final context = tester.element(find.byType(ImportLedger));
      final message = ledgerFailureMessage(
        AppLocalizations.of(context)!,
        classifyLedgerErrorCode(code),
      );
      expect(find.text(message), findsOneWidget);
      expect(ledger.operations, hasLength(1));
      expect(result, isNull);
      expect(toasts, isEmpty);
      ledger.failure = null;
      await tester.tap(find.text('689C'));
      await pumpFlow(tester);
      expect(result, isTrue);
      expect(find.byType(ImportLedger), findsNothing);
      expect(ledger.operations, hasLength(3));
      expect(ledger.disconnects, 0);
    });
  }

  testWidgets(
    'shared readiness rejection reports once without opening a sheet',
    (tester) async {
      ledger.failure = LedgerException(errorCode: 0x6985);
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      final dic = AppLocalizations.of(tester.element(find.byType(TextButton)))!;
      expect(result, isFalse);
      expect(toasts, [dic.ledgerReject]);
      expect(find.byType(ImportLedger), findsNothing);
      expect(
        globalAppStore.ledger!.ledgerStatus,
        LedgerStatusTypes.unavailable,
      );
    },
  );

  testWidgets(
    'shared readiness timeout recovers through discovery and an explicit retry',
    (tester) async {
      ledger.failure = TimeoutException('readiness timed out');
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      final dic = AppLocalizations.of(
        tester.element(find.byType(ImportLedger)),
      )!;
      expect(find.text(dic.ledgerConnectionError), findsOneWidget);
      expect(find.text(dic.ledgerPairingError), findsNothing);
      expect(toasts, isEmpty);
      expect(result, isNull);
      ledger.failure = null;
      ledger.discoveries.add(device);
      await pumpFlow(tester);
      await tester.tap(find.text('689C'));
      await pumpFlow(tester);
      expect(result, isTrue);
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
    },
  );

  testWidgets(
    'closing connection sheet does not authorize transaction continuation',
    (tester) async {
      globalAppStore.ledger!.setDevice(null);
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      Navigator.of(tester.element(find.byType(ImportLedger))).pop();
      await pumpFlow(tester);
      expect(result, isFalse);
      expect(ledger.operations, isEmpty);
    },
  );

  for (final fail in [false, true]) {
    testWidgets(
      'disposed caller ignores late readiness ${fail ? "failure" : "success"}',
      (tester) async {
        ledger.versionGate = Completer<void>();
        if (fail) ledger.versionFailure = LedgerException(errorCode: 0x5515);
        bool? result;
        await tester.pumpWidget(readinessHost((value) => result = value));
        await tester.tap(find.text('Check Ledger'));
        await pumpFlow(tester);
        expect(ledger.operations, hasLength(2));
        await tester.pumpWidget(host(const SizedBox()));
        ledger.versionGate!.complete();
        await pumpFlow(tester);
        expect(result, isFalse);
        expect(toasts, isEmpty);
        expect(find.byType(ImportLedger), findsNothing);
        expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unknown);
      },
    );
  }

  for (final replacement in [
    (true, false),
    (true, true),
    (false, false),
    (false, true),
  ]) {
    testWidgets(
      'replaced ${replacement.$1 ? "device" : "transport"} ignores late ${replacement.$2 ? "failure" : "success"}',
      (tester) async {
        ledger.versionGate = Completer<void>();
        if (replacement.$2)
          ledger.versionFailure = LedgerException(errorCode: 0x5515);
        bool? result;
        await tester.pumpWidget(readinessHost((value) => result = value));
        await tester.tap(find.text('Check Ledger'));
        await pumpFlow(tester);
        final nextLedger = FakeLedger();
        if (replacement.$1) {
          globalAppStore.ledger!.setDevice(
            LedgerDevice(
              id: 'replacement',
              name: 'new device',
              connectionType: ConnectionType.ble,
            ),
          );
        } else {
          globalAppStore.ledger!.setLedger(nextLedger);
        }
        globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
        ledger.versionGate!.complete();
        await pumpFlow(tester);
        expect(result, isFalse);
        expect(toasts, isEmpty);
        expect(find.byType(ImportLedger), findsNothing);
        expect(
          globalAppStore.ledger!.ledgerStatus,
          LedgerStatusTypes.available,
        );
        await nextLedger.discoveries.close();
      },
    );
  }

  testWidgets(
    'repeated confirmation while readiness is pending starts one transaction',
    (tester) async {
      globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
      ledger.versionGate = Completer<void>();
      var confirmations = 0;
      await tester.pumpWidget(
        host(
          TxConfirmDialog(
            items: const [],
            title: 'Transaction overview',
            isLedger: true,
            ledgerZkApp: true,
            onConfirm: (_) async {
              confirmations++;
            },
          ),
        ),
      );
      await pumpFlow(tester);
      final button = tester.widget<ZkAppBottomButton>(
        find.byType(ZkAppBottomButton),
      );
      final first = button.onConfirm() as Future<void>;
      await pumpFlow(tester);
      final second = button.onConfirm() as Future<void>;
      await second;
      expect(ledger.operations, hasLength(2));
      expect(confirmations, 0);
      ledger.versionGate!.complete();
      await first;
      await pumpFlow(tester);
      expect(confirmations, 1);
      expect(ledger.operations, hasLength(2));
    },
  );
  testWidgets(
    'all status icons share one probe and disconnect turns both red',
    (tester) async {
      ledger.versionGate = Completer<void>();
      await tester.pumpWidget(
        host(Row(children: [LedgerStatusView(), LedgerStatusView()])),
      );
      await pumpFlow(tester);
      expect(ledger.operations, hasLength(2));
      expect(
        tester
            .widgetList<SvgPicture>(find.byType(SvgPicture))
            .map((w) => w.colorFilter),
        everyElement(
          const ColorFilter.mode(Color(0xFFD65A5A), BlendMode.srcIn),
        ),
      );
      ledger.versionGate!.complete();
      await pumpFlow(tester);
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
      expect(
        tester
            .widgetList<SvgPicture>(find.byType(SvgPicture))
            .map((w) => w.colorFilter),
        everyElement(
          const ColorFilter.mode(Color(0xFF0DB27C), BlendMode.srcIn),
        ),
      );
      globalAppStore.ledger!.setDevice(null);
      await tester.pump();
      expect(
        tester
            .widgetList<SvgPicture>(find.byType(SvgPicture))
            .map((w) => w.colorFilter),
        everyElement(
          const ColorFilter.mode(Color(0xFFD65A5A), BlendMode.srcIn),
        ),
      );
    },
  );

  testWidgets('ready status proceeds directly without another probe or sheet', (
    tester,
  ) async {
    globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
    bool? result;
    await tester.pumpWidget(readinessHost((value) => result = value));
    await tester.tap(find.text('Check Ledger'));
    await pumpFlow(tester);
    expect(result, isTrue);
    expect(ledger.operations, isEmpty);
    expect(find.byType(ImportLedger), findsNothing);
  });

  testWidgets('unavailable status opens connection sheet and waits for retry', (
    tester,
  ) async {
    globalAppStore.ledger!.recordFailure(LedgerException(errorCode: 0x5515));
    bool? result;
    await tester.pumpWidget(readinessHost((value) => result = value));
    await tester.tap(find.text('Check Ledger'));
    await pumpFlow(tester);
    expect(result, isNull);
    expect(find.byType(ImportLedger), findsOneWidget);
    expect(ledger.operations, isEmpty);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unavailable);
    await tester.tap(find.text('689C'));
    await pumpFlow(tester);
    expect(result, isTrue);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
    expect(ledger.operations, hasLength(2));
  });

  testWidgets(
    'tapping status rechecks Mina and synchronizes the shared result',
    (tester) async {
      await tester.pumpWidget(host(LedgerStatusView()));
      await pumpFlow(tester);
      ledger.appName = 'BOLOS';
      await tester.tap(find.byType(LedgerStatusView));
      await pumpFlow(tester);
      expect(
        globalAppStore.ledger!.ledgerStatus,
        LedgerStatusTypes.unavailable,
      );
      expect(globalAppStore.ledger!.lastFailure, LedgerFailureType.appNotOpen);
      expect(find.byType(ImportLedger), findsNothing);
      ledger.appName = 'Mina';
      await tester.tap(find.byType(LedgerStatusView));
      await pumpFlow(tester);
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
      expect(globalAppStore.ledger!.lastFailure, isNull);
    },
  );

  testWidgets(
    'foreground checks detect lock but never queue behind a signature',
    (tester) async {
      await tester.pumpWidget(host(LedgerStatusView()));
      await pumpFlow(tester);
      final count = ledger.operations.length;
      globalAppStore.ledger!.operationPending = true;
      ledger.failure = LedgerException(errorCode: 0x5515);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.tap(find.byType(LedgerStatusView));
      await pumpFlow(tester);
      expect(ledger.operations, hasLength(count));
      expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.available);
      globalAppStore.ledger!.operationPending = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpFlow(tester);
      expect(
        globalAppStore.ledger!.ledgerStatus,
        LedgerStatusTypes.unavailable,
      );
      expect(ledger.operations, hasLength(count + 1));
    },
  );

  for (final failure in [false, true]) {
    test(
      'status probe ignores replaced device even on late ${failure ? "failure" : "success"}',
      () async {
        ledger.versionGate = Completer<void>();
        if (failure) ledger.versionFailure = LedgerException(errorCode: 0x5515);
        final store = globalAppStore.ledger!;
        final pending = store.refreshStatus();
        await Future<void>.delayed(Duration.zero);
        store.setDevice(
          LedgerDevice(
            id: 'replacement',
            name: 'new',
            connectionType: ConnectionType.ble,
          ),
        );
        store.setLedgerStatus(LedgerStatusTypes.available);
        ledger.versionGate!.complete();
        await pending;
        expect(store.ledgerStatus, LedgerStatusTypes.available);
        expect(store.lastFailure, isNull);
      },
    );
  }

  test(
    'removing transport invalidates its device and late status probe',
    () async {
      ledger.versionGate = Completer<void>();
      final store = globalAppStore.ledger!;
      final pending = store.refreshStatus();
      await Future<void>.delayed(Duration.zero);
      store.setLedger(null);
      ledger.versionGate!.complete();
      await pending;
      expect(store.ledgerStatus, LedgerStatusTypes.unavailable);
      expect(store.ledgerDevice, isNull);
    },
  );

  test(
    'signature rejection preserves ready status while lock invalidates it',
    () {
      final store = globalAppStore.ledger!;
      store.setLedgerStatus(LedgerStatusTypes.available);
      store.recordFailure(LedgerException(errorCode: 0x6985));
      expect(store.ledgerStatus, LedgerStatusTypes.available);
      store.recordFailure(LedgerException(errorCode: 0x5515));
      expect(store.ledgerStatus, LedgerStatusTypes.unavailable);
      expect(store.lastFailure, LedgerFailureType.locked);
    },
  );

  testWidgets(
    'confirmation waits for status probe and connects after failure',
    (tester) async {
      globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
      ledger.versionGate = Completer<void>();
      ledger.versionFailure = LedgerException(errorCode: 0x5515);
      var confirmations = 0;
      await tester.pumpWidget(
        host(
          TxConfirmDialog(
            items: const [],
            title: 'Transaction overview',
            isLedger: true,
            onConfirm: (_) async {
              confirmations++;
            },
          ),
        ),
      );
      await pumpFlow(tester);
      await tester.tap(find.text('Confirm'));
      await pumpFlow(tester);
      expect(confirmations, 0);
      ledger.versionGate!.complete();
      await pumpFlow(tester);
      expect(confirmations, 0);
      expect(find.byType(ImportLedger), findsOneWidget);
      expect(
        globalAppStore.ledger!.ledgerStatus,
        LedgerStatusTypes.unavailable,
      );
    },
  );
  testWidgets(
    'confirmation cannot use a replacement device after awaiting a status check',
    (tester) async {
      ledger.versionGate = Completer<void>();
      final store = globalAppStore.ledger!;
      final pending = store.refreshStatus();
      await pumpFlow(tester);
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      store.setDevice(
        LedgerDevice(
          id: 'replacement',
          name: 'new',
          connectionType: ConnectionType.ble,
        ),
      );
      store.setLedgerStatus(LedgerStatusTypes.available);
      ledger.versionGate!.complete();
      await pending;
      await pumpFlow(tester);
      expect(result, isFalse);
      expect(store.ledgerStatus, LedgerStatusTypes.available);
      expect(find.byType(ImportLedger), findsNothing);
    },
  );

  testWidgets('covered status icon does not probe behind a connection sheet', (
    tester,
  ) async {
    await tester.pumpWidget(host(LedgerStatusView()));
    await pumpFlow(tester);
    globalAppStore.ledger!.recordFailure(LedgerException(errorCode: 0x5515));
    final context = tester.element(find.byType(LedgerStatusView));
    final sheet = UI.showImportLedgerDialog(
      context: context,
      initialLedgerFailure: LedgerFailureType.locked,
    );
    await pumpFlow(tester);
    final count = ledger.operations.length;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpFlow(tester);
    expect(ledger.operations, hasLength(count));
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unavailable);
    Navigator.of(tester.element(find.byType(ImportLedger))).pop();
    await sheet;
    await pumpFlow(tester);
  });
  testWidgets(
    'rejection during shared status check is reported once without a connection sheet',
    (tester) async {
      ledger.versionGate = Completer<void>();
      ledger.versionFailure = LedgerException(errorCode: 0x6985);
      final pending = globalAppStore.ledger!.refreshStatus();
      await pumpFlow(tester);
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      ledger.versionGate!.complete();
      await pending;
      await pumpFlow(tester);
      expect(result, isFalse);
      expect(toasts, hasLength(1));
      expect(find.byType(ImportLedger), findsNothing);
    },
  );

  for (final reject in [false, true]) {
    testWidgets(
      'late address ${reject ? "failure" : "success"} cannot affect replacement device',
      (tester) async {
        ledger.accountsGate = Completer<List<String>>();
        await tester.pumpWidget(
          host(
            ImportLedger(
              generateAddress: true,
              accountIndex: 1,
              accountName: 'test',
            ),
          ),
        );
        await pumpFlow(tester);
        expect(ledger.operations.last, isA<MinaPublicKeyOperation>());
        final replacement = LedgerDevice(
          id: 'other',
          name: 'other',
          connectionType: ConnectionType.ble,
        );
        globalAppStore.ledger!.setDevice(replacement);
        globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
        if (reject) {
          ledger.accountsGate!.completeError(
            LedgerException(errorCode: 0x6511),
          );
        } else {
          ledger.accountsGate!.complete(['late-address']);
        }
        await pumpFlow(tester);
        expect(
          globalAppStore.ledger!.ledgerStatus,
          LedgerStatusTypes.available,
        );
        expect(globalAppStore.ledger!.ledgerDevice, same(replacement));
        expect(toasts, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final sameId in [false, true]) {
    testWidgets(
      'closing address page leaves replacement ${sameId ? "session" : "device"} connected',
      (tester) async {
        ledger.accountsGate = Completer<List<String>>();
        await tester.pumpWidget(
          host(
            ImportLedger(
              generateAddress: true,
              accountIndex: 1,
              accountName: 'test',
            ),
          ),
        );
        await pumpFlow(tester);
        final replacement = LedgerDevice(
          id: sameId ? device.id : 'other',
          name: 'other',
          connectionType: ConnectionType.ble,
        );
        globalAppStore.ledger!.setDevice(replacement);
        globalAppStore.ledger!.setLedgerStatus(LedgerStatusTypes.available);
        await tester.pumpWidget(host(const SizedBox()));
        await pumpFlow(tester);
        expect(ledger.disconnectedDevices, sameId ? isEmpty : [device]);
        expect(globalAppStore.ledger!.ledgerDevice, same(replacement));
        expect(
          globalAppStore.ledger!.ledgerStatus,
          LedgerStatusTypes.available,
        );
        ledger.accountsGate!.complete(['late-address']);
        await pumpFlow(tester);
        expect(toasts, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('transaction preflights and status icons share one pending probe', () async {
    ledger.versionGate = Completer<void>();
    final store = globalAppStore.ledger!;
    final first = store.prepareForTransaction(
      stage: 'first confirmation', isActive: () => true,
    );
    final second = store.prepareForTransaction(
      stage: 'second confirmation', isActive: () => true,
    );
    await Future<void>.delayed(Duration.zero);
    final icon = store.refreshStatus();
    expect(ledger.operations, hasLength(2));
    ledger.versionGate!.complete();
    expect(await first, LedgerReadiness.ready);
    expect(await second, LedgerReadiness.ready);
    await icon;
    expect(ledger.operations, hasLength(2));
  });

  for (final error in [
    LedgerException(errorCode: LedgerStatusCode.deviceLocked),
    LedgerException(errorCode: LedgerStatusCode.userRejected),
    LedgerException(errorCode: LedgerStatusCode.instructionUnsupported),
    TimeoutException('no response'),
    StateError('CBError Code=14 peer removed pairing information'),
  ]) {
    test('readiness never retries ${classifyLedgerError(error)} ${error.runtimeType}',
        () async {
      ledger.failure = error;
      await expectLater(
        MinaLedgerApp(ledger).ensureMinaAppReadyWithRetry(
          device, isCurrent: () => true,
        ),
        throwsA(same(error)),
      );
      expect(ledger.operations, hasLength(1));
    });
  }

  testWidgets('busy readiness can settle and succeed on the next attempt',
      (tester) async {
    ledger.failure = LedgerException(errorCode: LedgerStatusCode.deviceBusy);
    final ready = MinaLedgerApp(ledger).ensureMinaAppReadyWithRetry(
      device, isCurrent: () => true,
    );
    await tester.pump();
    expect(ledger.operations, hasLength(1));
    ledger.failure = null;
    await tester.pump(const Duration(milliseconds: 500));
    await ready;
    expect(ledger.operations.map((op) => op.runtimeType), [
      MinaNameOperation, MinaNameOperation, MinaVersionOperation,
    ]);
  });

  for (final close in [false, true]) {
    testWidgets('readiness retry stops when ${close ? "closed" : "replaced"}',
        (tester) async {
      ledger.failure = LedgerException(errorCode: LedgerStatusCode.deviceBusy);
      await tester.pumpWidget(host(ImportLedger()));
      await tester.pump();
      await tester.pump();
      expect(ledger.operations, hasLength(1));
      final replacement = device.copyWith();
      if (close) {
        await tester.pumpWidget(host(const SizedBox()));
      } else {
        globalAppStore.ledger!.setDevice(replacement);
      }
      await tester.pump(const Duration(seconds: 2));
      expect(ledger.operations, hasLength(1));
      if (!close) {
        expect(ledger.scans, 0);
        await tester.pumpWidget(host(const SizedBox()));
        expect(globalAppStore.ledger!.ledgerDevice, same(replacement));
        expect(ledger.disconnects, 0);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final cold in [false, true]) {
    testWidgets('pairing error retains its message and allows ${cold ? "discovery" : "rediscovery"}',
        (tester) async {
      if (cold) {
        globalAppStore.ledger!.setDevice(null);
        globalAppStore.ledger!.recordFailure(StateError('CBError Code=14'));
      } else {
        ledger.failure = StateError('CBError Code=14');
      }
      bool? result;
      await tester.pumpWidget(readinessHost((value) => result = value));
      await tester.tap(find.text('Check Ledger'));
      await pumpFlow(tester);
      final dic = AppLocalizations.of(tester.element(find.byType(ImportLedger)))!;
      expect(find.text(dic.ledgerPairingError), findsOneWidget);
      expect(find.text(dic.ledgerConnectionError), findsNothing);
      expect(toasts, isEmpty);
      ledger.failure = null;
      ledger.discoveries.add(device);
      await pumpFlow(tester);
      expect(find.text('689C'), findsOneWidget);
      await tester.tap(find.text('689C'));
      await pumpFlow(tester);
      expect(result, isTrue);
      expect(globalAppStore.ledger!.isReady, isTrue);
    });
  }

  testWidgets('pairing failure during sheet probe remains visible after cleanup',
      (tester) async {
    ledger.failure = StateError('CBError Code=14');
    await tester.pumpWidget(host(ImportLedger()));
    await pumpFlow(tester);
    final dic = AppLocalizations.of(tester.element(find.byType(ImportLedger)))!;
    expect(find.text(dic.ledgerPairingError), findsOneWidget);
    expect(find.text(dic.ledgerConnectionError), findsNothing);
    expect(ledger.operations, hasLength(1));
    expect(globalAppStore.ledger!.ledgerDevice, isNull);
    ledger.discoveries.add(device);
    await pumpFlow(tester);
    expect(find.text('689C'), findsOneWidget);
    expect(find.text(dic.ledgerPairingError), findsOneWidget);
    expect(find.byType(RotatingCircle), findsNothing);
  });

  testWidgets('closing an active old connector preserves same-ID replacement',
      (tester) async {
    ledger.versionGate = Completer<void>();
    await tester.pumpWidget(host(ImportLedger()));
    await pumpFlow(tester);
    final replacement = device.copyWith();
    globalAppStore.ledger!.setDevice(replacement);
    await tester.pumpWidget(host(const SizedBox()));
    expect(ledger.disconnects, 0);
    expect(globalAppStore.ledger!.ledgerDevice, same(replacement));
    ledger.versionGate!.complete();
    await pumpFlow(tester);
    expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unknown);
    expect(tester.takeException(), isNull);
  });

  test(
    'same device ID replaces the session object and ignores its old probe',
    () async {
      ledger.versionGate = Completer<void>();
      final store = globalAppStore.ledger!;
      final pending = store.refreshStatus();
      await Future<void>.delayed(Duration.zero);
      final replacement = device.copyWith();
      store.setDevice(replacement);
      expect(store.ledgerDevice, same(replacement));
      ledger.versionGate!.complete();
      await pending;
      expect(store.ledgerStatus, LedgerStatusTypes.unknown);
    },
  );

  testWidgets(
    'device row keeps its device and shows loading while checking with an old error',
    (tester) async {
      final gate = Completer<void>();
      var checks = 0;
      await tester.pumpWidget(
        host(
          ConnectLedger(
            failure: LedgerFailureType.locked,
            onConnected: (_) async {
              checks++;
              await gate.future;
            },
          ),
        ),
      );
      await pumpFlow(tester);
      final dic = AppLocalizations.of(tester.element(find.byType(ConnectLedger)))!;
      expect(find.text(dic.unlockLedger), findsOneWidget);
      expect(find.byType(RotatingCircle), findsNothing);
      await tester.tap(find.text('689C'));
      await tester.pump();
      expect(find.text(dic.unlockLedger), findsNothing);
      await pumpFlow(tester);
      expect(checks, 1);
      expect(find.text('689C'), findsOneWidget);
      expect(find.text(dic.unlockLedger), findsNothing);
      expect(find.byType(RotatingCircle), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNotNull,
      );
      await tester.tap(find.text('689C'));
      expect(checks, 1);
      gate.complete();
      await pumpFlow(tester);
      expect(find.text(dic.unlockLedger), findsOneWidget);
      expect(find.byType(RotatingCircle), findsNothing);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('retry hides the previous error until the new probe fails', (
    tester,
  ) async {
    await tester.pumpWidget(host(ImportLedger(
      initialLedgerFailure: LedgerFailureType.appNotOpen,
    )));
    await pumpFlow(tester);
    final dic = AppLocalizations.of(tester.element(find.byType(ImportLedger)))!;
    expect(find.text(dic.openMinaApp), findsOneWidget);
    ledger.versionGate = Completer<void>();
    ledger.versionFailure = LedgerException(errorCode: LedgerStatusCode.deviceLocked);
    await tester.tap(find.text('689C'));
    await tester.pump();
    expect(find.text(dic.openMinaApp), findsNothing);
    await pumpFlow(tester);
    expect(find.text(dic.unlockLedger), findsNothing);
    expect(find.byType(RotatingCircle), findsOneWidget);
    ledger.versionGate!.complete();
    await pumpFlow(tester);
    expect(find.text(dic.openMinaApp), findsNothing);
    expect(find.text(dic.unlockLedger), findsOneWidget);
    expect(find.byType(RotatingCircle), findsNothing);
  });

  testWidgets('reconnect rejection does not restore the previous error', (
    tester,
  ) async {
    globalAppStore.ledger!.setDevice(null);
    ledger.connectFailure = LedgerException(errorCode: LedgerStatusCode.userRejected);
    await tester.pumpWidget(host(ImportLedger(
      initialLedgerFailure: LedgerFailureType.appNotOpen,
    )));
    await pumpFlow(tester);
    final dic = AppLocalizations.of(tester.element(find.byType(ImportLedger)))!;
    ledger.discoveries.add(device);
    await pumpFlow(tester);
    expect(find.text(dic.openMinaApp), findsOneWidget);
    await tester.tap(find.text('689C'));
    await tester.pump();
    expect(find.text(dic.openMinaApp), findsNothing);
    expect(find.byType(RotatingCircle), findsOneWidget);
    await pumpFlow(tester);
    expect(find.text(dic.openMinaApp), findsNothing);
    expect(find.byType(RotatingCircle), findsNothing);
    expect(toasts, [dic.ledgerReject]);
    expect(ledger.operations, isEmpty);
    await tester.pump(const Duration(seconds: 1));
  });

  for (final outcome in ['success', 'error', 'early return']) {
    testWidgets(
      'confirmation keeps button loading until Ledger interaction and resets after $outcome',
      (tester) async {
        final preparation = Completer<void>();
        final interaction = Completer<void>();
        var calls = 0;
        await tester.pumpWidget(
          host(
            TxConfirmDialog(
              title: 'Transaction overview',
              items: [TxItem(label: 'Recipient', value: 'test-recipient')],
              isLedger: true,
              ledgerZkApp: true,
              onConfirm: (onLedgerInteraction) async {
                calls++;
                await preparation.future;
                if (outcome == 'early return') return;
                expect(onLedgerInteraction(), isTrue);
                await interaction.future;
                if (outcome == 'error') throw StateError('sign failed');
              },
            ),
          ),
        );
        await pumpFlow(tester);
        final button = tester.widget<ZkAppBottomButton>(
          find.byType(ZkAppBottomButton),
        );
        final pending = button.onConfirm() as Future<void>;
        await pumpFlow(tester);
        expect(find.text('Transaction overview'), findsOneWidget);
        expect(find.text('test-recipient'), findsOneWidget);
        expect(find.byType(LedgerWaitingContent), findsNothing);
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isTrue,
        );
        await button.onConfirm();
        expect(calls, 1);
        preparation.complete();
        await pumpFlow(tester);
        if (outcome != 'early return') {
          expect(find.byType(LedgerWaitingContent), findsOneWidget);
          expect(find.byType(ZkAppBottomButton), findsNothing);
        }
        interaction.complete();
        await pending;
        await pumpFlow(tester);
        expect(find.byType(LedgerWaitingContent), findsNothing);
        expect(
          tester
              .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
              .submitting,
          isFalse,
        );
        expect(find.text('Transaction overview'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'closing confirmation during preparation prevents a late Ledger interaction',
    (tester) async {
      final gate = Completer<void>();
      bool? allowed;
      await tester.pumpWidget(
        host(
          TxConfirmDialog(
            title: 'Transaction overview',
            items: const [],
            isLedger: true,
            onConfirm: (onLedgerInteraction) async {
              await gate.future;
              allowed = onLedgerInteraction();
            },
          ),
        ),
      );
      await pumpFlow(tester);
      final pending =
          tester
                  .widget<ZkAppBottomButton>(find.byType(ZkAppBottomButton))
                  .onConfirm()
              as Future<void>;
      await pumpFlow(tester);
      await tester.pumpWidget(host(const SizedBox()));
      gate.complete();
      await pending;
      expect(allowed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('connection entry rejects duplicates and unlocks after closing',
      (tester) async {
    await tester.pumpWidget(host(const Text('Overview')));
    final context = tester.element(find.text('Overview'));
    final first = UI.showImportLedgerDialog(
      context: context,
      initialLedgerFailure: LedgerFailureType.locked,
    );
    final duplicate = UI.showImportLedgerDialog(
      context: context, generateAddress: true, accountIndex: 0, accountName: 'new',
    );
    expect(await duplicate, isNull);
    await pumpFlow(tester);
    expect(find.byType(ImportLedger), findsOneWidget);
    expect(tester.widget<ImportLedger>(find.byType(ImportLedger)).generateAddress,
        isFalse);
    Navigator.of(context).pop();
    expect(await first, isNull);
    expect(await UI.showImportLedgerDialog(context: context), isNull);
    await pumpFlow(tester);
    final next = UI.showImportLedgerDialog(
      context: context,
      initialLedgerFailure: LedgerFailureType.locked,
    );
    await pumpFlow(tester);
    expect(find.byType(ImportLedger), findsOneWidget);
    Navigator.of(context).pop();
    await next;
    await pumpFlow(tester);
    expect(find.text('Overview'), findsOneWidget);
  });

  for (final address in [false, true]) {
    testWidgets('late ${address ? "address" : "readiness"} response during close cannot pop another route',
        (tester) async {
      if (address) {
        ledger.accountsGate = Completer<List<String>>();
      } else {
        ledger.versionGate = Completer<void>();
      }
      await tester.pumpWidget(host(const Text('Overview')));
      final context = tester.element(find.text('Overview'));
      final sheet = UI.showImportLedgerDialog(
        context: context, generateAddress: address,
        accountIndex: 0, accountName: 'test',
      );
      await pumpFlow(tester);
      final sheetContext = tester.element(find.byType(ImportLedger));
      Navigator.of(context).pop();
      expect(sheetContext.mounted, isTrue);
      final other = showDialog<void>(context: context,
        builder: (_) => const AlertDialog(content: Text('Other dialog')),
      );
      if (address) {
        ledger.accountsGate!.completeError(
          LedgerException(errorCode: LedgerStatusCode.deviceLocked),
        );
      } else {
        ledger.versionGate!.complete();
      }
      await pumpFlow(tester);
      expect(await sheet, isNull);
      expect(find.text('Other dialog'), findsOneWidget);
      expect(toasts, isEmpty);
      expect(tester.takeException(), isNull);
      Navigator.of(context).pop();
      await other;
      await pumpFlow(tester);
    });
  }

  for (final flow in ['MINA', 'stake', 'token']) {
    for (final cancel in [false, true]) {
      testWidgets('$flow signing ${cancel ? "cancellation stops recovery" : "opens at most one recovery sheet"}',
          (tester) async {
        ledger.signingFailure = LedgerException(
          errorCode: LedgerStatusCode.mobileMinaAppNotOpen,
        );
        if (cancel) ledger.signingGate = Completer<void>();
        await tester.pumpWidget(host(const Text('Overview')));
        final context = tester.element(find.text('Overview'));
        final account = ApiAccount(FakeApi(context));
        var active = true;
        final txInfo = {
          'accountIndex': 0, 'fromAddress': 'sender', 'toAddress': 'receiver',
          'fee': '0.1', 'amount': '1', 'nonce': 0, 'memo': '',
        };
        final signing = flow == 'token'
            ? account.ledgerSignAndSendZkTx(txInfo, context: context,
                networkId: 'mina:mainnet', onLedgerInteraction: () => active)
            : account.ledgerSign(txInfo, context: context,
                isDelegation: flow == 'stake', networkId: 'mina:mainnet',
                onLedgerInteraction: () => active);
        await pumpFlow(tester);
        if (cancel) {
          active = false;
          ledger.signingGate!.complete();
        } else {
          expect(find.byType(ImportLedger), findsOneWidget);
          await tester.tap(find.text('689C'));
        }
        await pumpFlow(tester);
        expect(find.byType(ImportLedger), findsNothing);
        expect(await signing, isNull);
        expect(ledger.operations.where((op) =>
            op is MinaPublicKeyOperation || op is MinaSignTransferOperation),
            hasLength(cancel ? 1 : 2));
        final dic = AppLocalizations.of(context)!;
        expect(toasts, cancel ? isEmpty : [dic.openMinaApp]);
        expect(globalAppStore.ledger!.ledgerStatus, LedgerStatusTypes.unavailable);
        expect(find.text('Overview'), findsOneWidget);
      });
    }
  }

  for (final failed in [false, true]) {
    testWidgets('cancelled token address ${failed ? "failure" : "success"} cannot continue or notify',
        (tester) async {
      ledger.accountsGate = Completer<List<String>>();
      await tester.pumpWidget(host(const Text('Overview')));
      final context = tester.element(find.text('Overview'));
      final account = ApiAccount(FakeApi(context));
      var active = true;
      final pending = account.ledgerSignAndSendZkTx(
        {'accountIndex': 0, 'fromAddress': 'sender'},
        context: context, networkId: 'mina:mainnet',
        onLedgerInteraction: () => active,
      );
      await pumpFlow(tester);
      active = false;
      if (failed) {
        ledger.accountsGate!.completeError(StateError('address failed'));
      } else {
        ledger.accountsGate!.complete(['sender']);
      }
      expect(await pending, isNull);
      await pumpFlow(tester);
      expect(ledger.operations, hasLength(1));
      expect(toasts, isEmpty);
      expect(find.byType(ImportLedger), findsNothing);
    });
  }

  for (final delegation in [false, true]) {
    testWidgets('${delegation ? "staking" : "MINA"} transport timeout remains a handled failure after disconnect', (tester) async {
      ledger.signingGate = Completer<void>();
      ledger.signingFailure = TimeoutException('Ledger transport timed out.');
      await tester.pumpWidget(host(const Text('Overview')));
      final context = tester.element(find.text('Overview'));
      final account = ApiAccount(FakeApi(context));
      final pending = account.ledgerSign({
        'accountIndex': 0, 'fromAddress': 'sender', 'toAddress': 'receiver',
        'fee': '0.1', 'amount': '1', 'nonce': 0, 'memo': '',
      }, context: context, isDelegation: delegation, networkId: 'mina:mainnet');
      await pumpFlow(tester);
      globalAppStore.ledger!.setDevice(null);
      ledger.signingGate!.complete();
      expect(await pending, isNull);
      await pumpFlow(tester);
      expect(toasts, [AppLocalizations.of(context)!.buildFailed]);
      expect(find.byType(ImportLedger), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('cancelled MINA signature is not returned for broadcast', (tester) async {
    ledger.signingGate = Completer<void>();
    ledger.transferSignature = '0' * 128;
    await tester.pumpWidget(host(const Text('Overview')));
    final context = tester.element(find.text('Overview'));
    final account = ApiAccount(FakeApi(context));
    var active = true;
    final pending = account.ledgerSign({
      'accountIndex': 0, 'fromAddress': 'sender', 'toAddress': 'receiver',
      'fee': '0.1', 'amount': '1', 'nonce': 0, 'memo': '',
    }, context: context, networkId: 'mina:mainnet',
      onLedgerInteraction: () => active);
    await pumpFlow(tester);
    active = false;
    ledger.signingGate!.complete();
    expect(await pending, isNull);
    expect(toasts, isEmpty);
  });

  testWidgets('cancelled token preparation never sends its address APDU', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SizedBox()));
    final context = tester.element(find.byType(SizedBox).first);
    final account = ApiAccount(FakeApi(context));
    var callbacks = 0;
    final result = await account.ledgerSignAndSendZkTx(
      {'accountIndex': 0},
      context: context,
      networkId: 'mina:mainnet',
      onLedgerInteraction: () {
        callbacks++;
        return false;
      },
    );
    expect(result, isNull);
    expect(callbacks, 1);
    expect(ledger.operations, isEmpty);
  });
}
