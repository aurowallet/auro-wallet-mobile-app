import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/index.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AssetsApi extends Fake implements ApiAssets {
  int calls = 0;
  @override
  Future<dynamic> fetchAllTokenAssets({
    bool showIndicator = false,
    isDev = false,
  }) async {
    calls++;
  }
}

class _Api extends Fake implements Api {
  @override
  final _AssetsApi assets = _AssetsApi();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppStore store;
  late _Api api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = AppStore();
    store.settings = SettingsStore(store)
      ..currentNode = CustomNode(
        name: 'Mainnet',
        networkID: 'mina:mainnet',
        url: 'https://example.com',
      );
    final account = AccountData()
      ..pubKey = 'B62qaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      ..name = 'Account'
      ..accountIndex = 0;
    final wallet = WalletData()
      ..id = 'wallet'
      ..walletType = WalletStore.seedTypeMnemonic
      ..accounts = [account]
      ..currentAccountIndex = 0;
    store.wallet = WalletStore(store)
      ..walletList.add(wallet)
      ..currentWalletId = 'wallet';
    store.assets = AssetsStore(store)
      ..updateTokenAssets(
        [],
        'B62qaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      )
      ..setAssetsLoading(false);
    api = _Api();
    webApi = api;
  });

  Future<void> render(
    WidgetTester tester,
    Size size, {
    bool settle = true,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await http.runWithClient(
      () async {
        await store.minaExchanges.initialize();
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: Assets(store)),
          ),
        );
        if (settle) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump(const Duration(milliseconds: 100));
        }
      },
      () => MockClient(
        (_) async => http.Response(
          jsonEncode({
            'schemaVersion': 1,
            'enabled': true,
            'exchanges': [
              {
                'id': 'test',
                'enabled': true,
                'name': 'Exchange',
                'iconUrl': '/icon.png',
                'url': 'https://example.com',
                'description': {},
              },
            ],
          }),
          200,
        ),
      ),
    );
  }

  tearDown(() => store.minaExchanges.dispose());

  testWidgets('app configuration survives leaving and reopening the asset page', (
    tester,
  ) async {
    var requests = 0;
    final response = Completer<http.Response>();
    await http.runWithClient(
      () async {
        // Start the app-owned load before the asset page is mounted.
        final initialized = store.minaExchanges.initialize();
        Widget page() => MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Assets(store)),
        );
        await tester.pumpWidget(page());
        await tester.pumpAndSettle();
        expect(find.text('获取 MINA'), findsNothing);
        await tester.pumpWidget(const SizedBox());

        // Leaving the page must not dispose the shared service or discard its reply.
        response.complete(
          http.Response(
            jsonEncode({
              'schemaVersion': 1,
              'enabled': true,
              'exchanges': [
                {
                  'id': 'test',
                  'enabled': true,
                  'name': 'Exchange',
                  'iconUrl': '/icon.png',
                  'url': 'https://example.com',
                  'description': {},
                },
              ],
            }),
            200,
          ),
        );
        await initialized;
        expect(store.minaExchanges.value!.available, hasLength(1));
        final cached =
            await store.localStorage.getObject(MinaExchanges.cacheKey) as Map;
        expect(cached['config']['exchanges'], hasLength(1));

        for (var i = 0; i < 3; i++) {
          await tester.pumpWidget(page());
          await tester.pumpAndSettle();
          expect(find.text('获取 MINA'), findsOneWidget);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pumpAndSettle();
          await tester.pumpWidget(const SizedBox());
        }
        expect(requests, 1);
        expect(tester.takeException(), isNull);
      },
      () => MockClient((_) {
        requests++;
        return response.future;
      }),
    );
  });

  testWidgets('keeps cached assets visible during a foreground refresh', (
    tester,
  ) async {
    await render(tester, const Size(393, 800));
    store.assets!.setAssetsLoading(true);
    await tester.pump();
    expect(find.text('MINA'), findsOneWidget);
    expect(find.byType(LoadingCircle), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cleared assets show loading during a request and stop on failure', (tester) async {
    await render(tester, const Size(393, 800));
    store.wallet!.currentWalletId = 'other';
    store.assets!.clearStaleTokenAssets();
    store.assets!.setAssetsLoading(true);
    await tester.pump();
    expect(find.byType(LoadingCircle), findsOneWidget);
    expect(find.text('MINA'), findsNothing);
    expect(find.text('获取 MINA'), findsNothing);
    store.assets!.setAssetsLoading(false);
    await tester.pumpAndSettle();
    expect(find.byType(LoadingCircle), findsNothing);
    expect(find.text('MINA'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('compact screen scrolls the card and keeps Get MINA fixed', (
    tester,
  ) async {
    await render(tester, const Size(360, 420));
    final footer = find.text('获取 MINA');
    expect(footer, findsOneWidget);
    final footerY = tester.getCenter(footer).dy;
    final card = find.text('Account');
    final cardY = tester.getCenter(card).dy;
    final scroll = find.byType(Scrollable).first;
    await tester.drag(scroll, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getCenter(card).dy, lessThan(cardY));
    expect(tester.getCenter(footer).dy, footerY);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'initial loading fills the viewport until a known balance arrives',
    (tester) async {
      await store.assets!.clearAccountAssestCache();
      store.assets!.setAssetsLoading(true);
      await render(tester, const Size(360, 420), settle: false);
      expect(find.byType(LoadingCircle), findsOneWidget);
      expect(find.text('获取 MINA'), findsNothing);
      expect(tester.takeException(), isNull);
      store.assets!.updateTokenAssets([], store.wallet!.currentAddress);
      store.assets!.setAssetsLoading(false);
      await tester.pumpAndSettle();
      expect(find.byType(LoadingCircle), findsNothing);
      expect(find.text('获取 MINA'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('pull to refresh works with only one asset', (tester) async {
    await render(tester, const Size(393, 800));
    final before = api.assets.calls;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(api.assets.calls, greaterThan(before));
    await tester.pumpWidget(const SizedBox());
  });
}
