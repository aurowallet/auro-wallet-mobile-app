import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

import 'network_context_test.dart' as helpers;

const providers = MinaExchangesConfig(
  enabled: true,
  exchanges: [
    MinaExchange(
      id: 'one',
      enabled: true,
      name: 'First exchange',
      iconUrl: 'https://example.com/one.png',
      url: 'https://example.com/one',
      description: {'en': 'Buy MINA'},
    ),
    MinaExchange(
      id: 'two',
      enabled: true,
      name: 'Second exchange',
      iconUrl: 'https://example.com/two.png',
      url: 'https://example.com/two',
      description: {'en': 'Buy MINA'},
    ),
  ],
);

class _AssetsApi extends Fake implements ApiAssets {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.value([]);
}

class _Api extends Fake implements Api {
  @override
  final assets = _AssetsApi();
}

void main() {
  late AppStore store;
  late Token token;
  final routes = <RouteSettings>[];

  setUp(() {
    store = AppStore();
    helpers.init(store);
    store.minaExchanges.value = providers;
    token = Token.fromJson(defaultMINAAssets);
    store.assets!.updateTokenAssets([token], 'account');
    store.assets!.nextToken = token;
    routes.clear();
    webApi = _Api();
  });

  tearDown(() {
    store.minaExchanges.dispose();
    store.requests.dispose();
  });

  Widget app({
    bool fullPage = false,
    Locale locale = const Locale('en'),
    double scale = 1,
  }) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: fullPage
        ? TokenDetailPage(store)
        : Scaffold(
            body: TokenDetailActions(
              store: store,
              token: token,
              tokenSymbol: 'MINA',
            ),
          ),
    onGenerateRoute: (settings) {
      routes.add(settings);
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const Scaffold(body: Text('Destination')),
      );
    },
  );

  testWidgets(
    'Buy and Earn appear for every mainnet account regardless of balance',
    (tester) async {
      for (final kind in [
        WalletStore.seedTypeMnemonic,
        WalletStore.seedTypePrivateKey,
        WalletStore.seedTypeLedger,
        WalletStore.seedTypeNone,
      ]) {
        store.wallet!.currentWallet.walletType = kind;
        for (final amount in [0.0, 200.0]) {
          token.tokenBaseInfo!.showBalance = amount;
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
          expect(find.text('Buy'), findsOneWidget);
          expect(find.text('Earn'), findsOneWidget);
          expect(find.text('Send'), findsOneWidget);
          expect(find.text('Receive'), findsOneWidget);
        }
      }
    },
  );

  testWidgets('network and token rules update without remounting the page', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    for (final network in [
      'mina:mainnet',
      'mina:devnet',
      'zeko:mainnet',
      'zeko:testnet',
    ]) {
      store.settings!.currentNode = helpers.node(
        network,
        'https://example.com/$network',
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Buy'),
        network == 'mina:mainnet' ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Earn'),
        network.startsWith('mina:') ? findsOneWidget : findsNothing,
      );
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Receive'), findsOneWidget);
    }
    store.settings!.currentNode = helpers.node(
      'mina:mainnet',
      'https://main.example',
    );
    token = Token(tokenBaseInfo: TokenBaseInfo(isMainToken: false));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Buy'), findsNothing);
    expect(find.text('Earn'), findsNothing);
  });

  testWidgets(
    'Buy follows available exchanges and closes the sheet when unavailable',
    (tester) async {
      store.minaExchanges.value = null;
      await tester.pumpWidget(app());
      expect(find.text('Buy'), findsNothing);
      expect(find.byType(TokenActionItem), findsNWidgets(3));

      final unavailable = <MinaExchangesConfig?>[
        null,
        const MinaExchangesConfig(enabled: true, exchanges: []),
        MinaExchangesConfig(enabled: false, exchanges: providers.exchanges),
        const MinaExchangesConfig(
          enabled: true,
          exchanges: [
            MinaExchange(
              id: 'disabled',
              enabled: false,
              name: 'Disabled exchange',
              iconUrl: 'https://example.com/icon.png',
              url: 'https://example.com',
              description: {},
            ),
          ],
        ),
      ];
      for (final config in unavailable) {
        store.minaExchanges.value = providers;
        await tester.pumpAndSettle();
        expect(find.text('Buy'), findsOneWidget);
        await tester.tap(find.text('Buy'));
        await tester.pumpAndSettle();
        expect(find.text('Get MINA From'), findsOneWidget);
        expect(find.text('First exchange'), findsOneWidget);
        expect(find.text('Second exchange'), findsOneWidget);
        expect(find.byType(Divider), findsNWidgets(2));

        // Valid provider updates also refresh an already open sheet.
        store.minaExchanges.value = MinaExchangesConfig(
          enabled: true,
          exchanges: [providers.exchanges.first],
        );
        await tester.pumpAndSettle();
        expect(find.text('First exchange'), findsOneWidget);
        expect(find.text('Second exchange'), findsNothing);

        store.minaExchanges.value = config;
        await tester.pumpAndSettle();
        expect(find.text('Buy'), findsNothing);
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.byType(TokenActionItem), findsNWidgets(3));
        expect(find.text('Earn'), findsOneWidget);
        expect(find.text('Send'), findsOneWidget);
        expect(find.text('Receive'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('removing providers before the Buy sheet builds closes it safely', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Buy'));
    store.minaExchanges.value = null;
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Buy'), findsNothing);
    expect(tester.takeException(), isNull);
    store.minaExchanges.value = providers;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(find.text('First exchange'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
  });

  for (final change in ['account', 'node', 'network']) {
    testWidgets('changing $change closes an open Buy sheet', (tester) async {
      store.minaExchanges.value = providers;
      await tester.pumpWidget(app());
      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      if (change == 'account') {
        store.wallet!.currentWalletId = 'other';
      } else {
        store.settings!.currentNode = helpers.node(
          change == 'node' ? 'mina:mainnet' : 'mina:devnet',
          'https://other.example',
        );
      }
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Earn, Send and Receive preserve their routes and arguments', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    for (final action in ['Earn', 'Send', 'Receive']) {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      final route = routes.last;
      expect(
        route.name,
        {
          'Earn': Staking.route,
          'Send': TransferPage.route,
          'Receive': ReceivePage.route,
        }[action],
      );
      if (action == 'Earn') expect(route.arguments, {'isFromRoute': true});
      if (action == 'Receive')
        expect(route.arguments, {'isFromRoute': true, 'tokenSymbol': 'MINA'});
      if (action == 'Send') expect(store.assets!.nextToken, same(token));
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('four actions fit 360px with large text in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(locale: locale, scale: 2));
      await tester.pumpAndSettle();
      expect(find.byType(TokenActionItem), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('full MINA detail shows its name without a token ID or copy action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(fullPage: true));
    await tester.pumpAndSettle();
    expect(find.byType(TokenActionItem), findsNWidgets(4));
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('Earn'), findsOneWidget);
    expect(find.text('Mina Protocol'), findsOneWidget);
    expect(find.textContaining('wSHV2S'), findsNothing);
    expect(find.descendant(of: find.byType(AppBar), matching: find.byType(InkWell)), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('custom token detail keeps its token ID and copy action', (tester) async {
    const tokenId = 'custom-token-id-for-copy-verification';
    token = Token(
      tokenAssestInfo: TokenAssetInfo(
        balance: Balance(total: '0', liquid: '0'),
        tokenId: tokenId,
        publicKey: 'account',
      ),
      tokenBaseInfo: TokenBaseInfo(isMainToken: false, decimals: '9'),
    );
    store.assets!.nextToken = token;
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied = call.arguments['text'];
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(app(fullPage: true));
    await tester.pumpAndSettle();
    expect(find.text('Mina Protocol'), findsNothing);
    expect(find.text('Buy'), findsNothing);
    expect(find.text('Earn'), findsNothing);
    expect(find.byType(TokenActionItem), findsNWidgets(2));
    await tester.tap(find.text(Fmt.address(tokenId, pad: 6)));
    await tester.pump();
    expect(copied, tokenId);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('detail updates unknown and cached balances without reopening', (
    tester,
  ) async {
    await store.assets!.clearAccountAssestCache();
    await tester.pumpWidget(app(fullPage: true));
    await tester.pumpAndSettle();
    expect(find.text('-- MINA'), findsOneWidget);
    expect(find.textContaining('≈'), findsNothing);

    store.assets!.marketPrices[ZK_DEFAULT_TOKEN_ID] = 2;
    store.assets!.updateTokenAssets([
      Token(
        tokenAssestInfo: TokenAssetInfo(
          balance: Balance(total: '7000000000', liquid: '7000000000'),
          tokenId: ZK_DEFAULT_TOKEN_ID,
          publicKey: 'account',
        ),
      ),
    ], 'account');
    await tester.pumpAndSettle();
    expect(find.text('7 MINA'), findsOneWidget);
    expect(find.textContaining('≈'), findsOneWidget);
    await tester.tap(find.text('Send'));
    expect(store.assets!.nextToken.tokenBaseInfo!.showBalance, 7);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    store.assets!.setAssetsLoading(true);
    await tester.pump();
    expect(find.text('7 MINA'), findsOneWidget);
    store.assets!.setAssetsLoading(false);
    await tester.pumpAndSettle();
    expect(find.text('7 MINA'), findsOneWidget);

    store.settings!.currentNode = helpers.node(
      'mina:mainnet',
      'https://other.example',
    );
    await tester.pumpAndSettle();
    expect(find.text('-- MINA'), findsOneWidget);
    expect(find.textContaining('≈'), findsNothing);
    store.assets!.updateTokenAssets([], 'account');
    await tester.pumpAndSettle();
    expect(find.text('0 MINA'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
