import 'dart:async';

import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_context_test.dart' as helpers;

class _DelayedCacheStorage extends LocalStorage {
  final config = Completer<Object?>();

  @override
  Future<Object?> getAccountCache(String address, String key) =>
      key.endsWith('account_token_config_v1')
      ? config.future
      : super.getAccountCache(address, key);
}

Token fundedToken(String address, String balance) => Token(
  tokenAssestInfo: TokenAssetInfo(
    balance: Balance(total: balance, liquid: balance),
    tokenId: ZK_DEFAULT_TOKEN_ID,
    publicKey: address,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = globalAppStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store.localStorage = LocalStorage();
    helpers.init(store);
    await store.settings!.setCurrentNode(
      helpers.node('mina:devnet', 'https://dev.example'),
    );
    await store.localStorage.addWallet(
      WalletData.toJson(store.wallet!.currentWallet),
    );
    await store.localStorage.setCurrentWallet('wallet');
    store.assets!.updateTokenAssets(
      [fundedToken('account', '1000000000')],
      'account',
      shouldCache: true,
    );
    await store.assets!.setNextToken(store.assets!.mainTokenNetInfo);
  });

  void expectUnknownAssets() {
    expect(store.assets!.tokenList, isEmpty);
    expect(store.assets!.hasTokenAssets, isFalse);
    expect(store.assets!.hasCurrentTokenAssets, isFalse);
    expect(store.assets!.nextToken.tokenAssestInfo, isNull);
  }

  test(
    'adding an uncached account clears old assets before cache loading',
    () async {
      await store.wallet!.addAccount(
        {'pubKey': 'new-account', 'hdIndex': 1},
        'New account',
        store.wallet!.currentWallet,
      );
      expect(store.wallet!.currentAddress, 'new-account');
      expectUnknownAssets();
      await store.assets!.loadAccountCache();
      expectUnknownAssets();
    },
  );

  test(
    'loading an imported wallet clears the previous wallet assets',
    () async {
      final imported = WalletData()
        ..id = 'imported'
        ..accounts = [
          AccountData()
            ..pubKey = 'imported'
            ..accountIndex = 0,
        ]
        ..currentAccountIndex = 0;
      await store.localStorage.addWallet(WalletData.toJson(imported));
      await store.localStorage.setCurrentWallet('imported');
      await store.wallet!.loadWallet();
      expect(store.wallet!.currentAddress, 'imported');
      expectUnknownAssets();
    },
  );

  test(
    'removing the current account clears its assets for the remaining account',
    () async {
      final wallet = store.wallet!.currentWallet;
      final removed = wallet.accounts.single..walletId = wallet.id;
      wallet.accounts.add(
        AccountData()
          ..pubKey = 'remaining'
          ..walletId = wallet.id
          ..accountIndex = 1,
      );
      await store.localStorage.updateWallet(WalletData.toJson(wallet));
      await store.wallet!.removeAccount(removed);
      expect(store.wallet!.currentAddress, 'remaining');
      expectUnknownAssets();
    },
  );

  test(
    'cache loading clears a different context before its first await',
    () async {
      final delayed = _DelayedCacheStorage();
      store.localStorage = delayed;
      await store.settings!.setCurrentNode(
        helpers.node('mina:devnet', 'https://other.example'),
      );
      final loading = store.assets!.loadAccountCache();
      expectUnknownAssets();
      // A fresh result arriving during the cache read must survive its completion.
      store.assets!.updateTokenAssets([
        fundedToken('account', '2000000000'),
      ], 'account');
      delayed.config.complete(null);
      await loading;
      expect(
        store.assets!.mainTokenNetInfo.tokenAssestInfo!.balance.total,
        '2000000000',
      );
      expect(store.assets!.hasCurrentTokenAssets, isTrue);
    },
  );

  test(
    'failed refresh drops different-context assets but preserves same-context assets',
    () async {
      final api = helpers.TestApi()
        ..graphQLClient = GraphQLClient(
          link: Link.function(
            (_, [__]) => Stream.value(
              Response(
                response: const {},
                errors: [GraphQLError(message: 'offline')],
              ),
            ),
          ),
          cache: GraphQLCache(),
        );
      final assets = ApiAssets(api);
      await assets.fetchAllTokenAssets(showIndicator: true);
      expect(
        store.assets!.mainTokenNetInfo.tokenAssestInfo!.balance.total,
        '1000000000',
      );
      expect(store.assets!.hasCurrentTokenAssets, isTrue);

      await store.settings!.setCurrentNode(
        helpers.node('mina:devnet', 'https://other.example'),
      );
      await assets.fetchAllTokenAssets(showIndicator: true);
      expectUnknownAssets();
      expect(store.assets!.isAssetsLoading, isFalse);
    },
  );

  test('default refresh shows loading only when assets are unavailable', () async {
    store.assets!.setAssetsLoading(false);
    final responses = <Completer<Response>>[];
    final api = helpers.TestApi()
      ..graphQLClient = GraphQLClient(
        link: Link.function((_, [__]) {
          final response = Completer<Response>();
          responses.add(response);
          return Stream.fromFuture(response.future);
        }),
        cache: GraphQLCache(),
      );
    final assets = ApiAssets(api);
    final sameAccount = assets.fetchAllTokenAssets();
    expect(store.assets!.isAssetsLoading, isFalse);
    expect(store.assets!.hasCurrentTokenAssets, isTrue);
    await Future<void>.delayed(Duration.zero);
    responses.last.complete(Response(
      response: const {},
      errors: [GraphQLError(message: 'offline')],
    ));
    await sameAccount;

    await store.settings!.setCurrentNode(
      helpers.node('mina:devnet', 'https://other.example'),
    );
    final changedContext = assets.fetchAllTokenAssets();
    expectUnknownAssets();
    expect(store.assets!.isAssetsLoading, isTrue);
    await Future<void>.delayed(Duration.zero);
    responses.last.complete(Response(
      response: const {},
      errors: [GraphQLError(message: 'offline')],
    ));
    await changedContext;
    expect(store.assets!.isAssetsLoading, isFalse);
    expectUnknownAssets();
  });

  test(
    'switching to a cached account displays its balance without deleting either cache',
    () async {
      final cacheKey = store.assets!.cacheTokensKey;
      await store.localStorage.setAccountCache('cached-account', cacheKey, [
        fundedToken('cached-account', '7000000000').toJson(),
      ]);
      final originalCache = await store.localStorage.getAccountCache(
        'account',
        cacheKey,
      );
      final destinationCache = await store.localStorage.getAccountCache(
        'cached-account',
        cacheKey,
      );
      await store.wallet!.addAccount(
        {'pubKey': 'cached-account', 'hdIndex': 1},
        'Cached account',
        store.wallet!.currentWallet,
      );
      expectUnknownAssets();
      await store.assets!.loadAccountCache();
      expect(store.assets!.hasCurrentTokenAssets, isTrue);
      final displayed = store.assets!.mainTokenNetInfo.tokenAssestInfo!;
      expect(displayed.publicKey, 'cached-account');
      expect(displayed.balance.total, '7000000000');
      expect(
        await store.localStorage.getAccountCache('account', cacheKey),
        originalCache,
      );
      expect(
        await store.localStorage.getAccountCache('cached-account', cacheKey),
        destinationCache,
      );
    },
  );

  test(
    'returning to an account restores its own cache and reload preserves selection',
    () async {
      await store.wallet!.addAccount(
        {'pubKey': 'new-account', 'hdIndex': 1},
        'New account',
        store.wallet!.currentWallet,
      );
      await store.wallet!.setCurrentAccount('account');
      await store.assets!.loadAccountCache();
      expect(
        store.assets!.mainTokenNetInfo.tokenAssestInfo!.balance.total,
        '1000000000',
      );
      expect(store.assets!.hasCurrentTokenAssets, isTrue);
      await store.assets!.setNextToken(store.assets!.mainTokenNetInfo);
      final selected = store.assets!.nextToken;
      await store.wallet!.loadWallet();
      expect(store.assets!.nextToken, same(selected));
      expect(store.assets!.hasCurrentTokenAssets, isTrue);
    },
  );
}
