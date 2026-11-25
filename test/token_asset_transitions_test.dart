import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/tokenSelectDialog.dart';
import 'package:auro_wallet/page/assets/token/component/tokenManageDialog.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_context_test.dart' as helpers;

class _AssetsApi extends Fake implements ApiAssets {
  @override
  Future<int> fetchAccountNonceWithRetry(
    String publicKey, {
    String? gqlUrl,
    int maxAttempts = 3,
    Duration retryDelay = const Duration(seconds: 1),
    Duration queryTimeout = const Duration(seconds: 10),
  }) async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.value(null);
}

class _Api extends Fake implements Api {
  @override
  final assets = _AssetsApi();
}

void main() {
  final store = globalAppStore;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.localStorage = LocalStorage();
    helpers.init(store);
    webApi = _Api();
  });

  Future<void> render(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: page),
        routes: {TransferPage.route: (_) => TransferPage(store)},
      ),
    );
    await tester.pumpAndSettle();
  }

  Token funded(String id, String balance) => Token(
    tokenAssestInfo: TokenAssetInfo(
      balance: Balance(total: balance, liquid: balance),
      tokenId: id,
      publicKey: 'account',
    ),
    tokenNetInfo: id == ZK_DEFAULT_TOKEN_ID
        ? null
        : TokenNetInfo(tokenSymbol: 'TEST', publicKey: 'owner', zkappState: []),
  );

  testWidgets(
    'selection shows MINA for an uncached account and updates after loading',
    (tester) async {
      await render(tester, TokenSelectionDialog());
      expect(find.text('MINA'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
      expect(store.assets!.hasCurrentTokenAssets, isFalse);
      expect(store.assets!.tokenList, isEmpty);
      store.assets!.updateTokenAssets([
        funded(ZK_DEFAULT_TOKEN_ID, '7000000000'),
      ], 'account');
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
      store.settings!.currentNode = helpers.node(
        'mina:mainnet',
        'https://other.example',
      );
      await tester.pumpAndSettle();
      expect(find.text('7'), findsNothing);
      expect(find.text('--'), findsOneWidget);
      expect(find.text('MINA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'asset management hides tokens from a previous node immediately',
    (tester) async {
      store.assets!.updateTokenAssets([funded('custom-token', '7')], 'account');
      await render(tester, TokenManageDialog());
      expect(find.text('TEST'), findsOneWidget);
      store.settings!.currentNode = helpers.node(
        'mina:mainnet',
        'https://other.example',
      );
      await tester.pumpAndSettle();
      expect(find.text('TEST'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transfer keeps an unknown balance unknown and All does not crash',
    (tester) async {
      store.assets!.nextToken = Token.fromJson(defaultMINAAssets);
      await render(tester, TransferPage(store));
      expect(find.text('-- MINA'), findsOneWidget);
      final strings = AppLocalizations.of(
        tester.element(find.byType(TransferPage)),
      )!;
      await tester.tap(find.text(strings.allTransfer));
      await tester.pumpAndSettle();
      expect(find.text('-- MINA'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'transfer uses refreshed balances and hides them after a node switch',
    (tester) async {
      store.assets!.updateTokenAssets([
        funded(ZK_DEFAULT_TOKEN_ID, '7000000000'),
      ], 'account');
      store.assets!.nextToken = Token.fromJson(defaultMINAAssets);
      await render(tester, TransferPage(store));
      expect(find.text('7 MINA'), findsOneWidget);
      expect(store.assets!.nextToken.tokenBaseInfo!.showBalance, 7);
      store.assets!.updateTokenAssets([
        funded(ZK_DEFAULT_TOKEN_ID, '8000000000'),
      ], 'account');
      await tester.pumpAndSettle();
      expect(find.text('8 MINA'), findsOneWidget);
      final strings = AppLocalizations.of(
        tester.element(find.byType(TransferPage)),
      )!;
      await tester.tap(find.text(strings.allTransfer));
      await tester.pumpAndSettle();
      expect(find.text('8'), findsOneWidget);
      store.settings!.currentNode = helpers.node(
        'mina:mainnet',
        'https://other.example',
      );
      store.assets!.updateTokenAssets([
        funded(ZK_DEFAULT_TOKEN_ID, '9000000000'),
      ], 'account');
      await tester.pumpAndSettle();
      expect(find.text('-- MINA'), findsOneWidget);
      expect(find.text('9 MINA'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
