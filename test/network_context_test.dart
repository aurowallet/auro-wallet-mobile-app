import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/api/apiAssets.dart';
import 'package:auro_wallet/service/api/apiStaking.dart';
import 'package:auro_wallet/service/requestTracker.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';

CustomNode node(String id, String url, {bool isDefault = false}) => CustomNode(
  name: id,
  networkID: id,
  url: url,
  isDefaultNode: isDefault,
  txUrl: '$url/archive',
  explorerUrl: '$url/explorer',
);

class TestApi extends Fake implements Api {
  @override
  late GraphQLClient graphQLClient;
  @override
  String getTxRecordsApiUrl() => '';
}

class DelayedConfigStorage extends LocalStorage {
  final config = Completer<Object?>();
  @override
  Future<Object?> getAccountCache(String accPubKey, String key) =>
      key.endsWith('account_token_config_v1')
      ? config.future
      : super.getAccountCache(accPubKey, key);
}

class DelayedObjectStorage extends LocalStorage {
  DelayedObjectStorage(this.key);
  final String key;
  final value = Completer<Object?>();
  @override
  Future<Object?> getObject(String key) =>
      key == this.key ? value.future : super.getObject(key);
}

void init(AppStore store) {
  store.settings = SettingsStore(store)
    ..currentNode = node('mina:mainnet', 'https://main.example');
  final account = AccountData()
    ..pubKey = 'account'
    ..accountIndex = 0;
  final wallet = WalletData()
    ..id = 'wallet'
    ..accounts = [account]
    ..currentAccountIndex = 0;
  store.wallet = WalletStore(store)
    ..walletList.add(wallet)
    ..currentWalletId = 'wallet';
  store.assets = AssetsStore(store);
  store.staking = StakingStore(store);
  store.requests.invalidate();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    init(globalAppStore);
  });

  test(
    'restoring account cache does not write delegation cache or invalidate its restore',
    () async {
      final store = globalAppStore;
      final restoreCurrent = store.requests.start(
        'delegation',
        fromCache: true,
      );
      await store.assets!.setAccountInfo('account', {
        'publicKey': 'account',
        'total': '100',
        'delegate': 'validator',
      }, needCache: false);
      expect(store.staking!.cachedDelegationKey, 'validator');
      expect(restoreCurrent(), isTrue);
      expect(
        await store.localStorage.getObject(
          store.staking!.localStorageDelegationCacheKey,
        ),
        isNull,
      );
    },
  );

  test(
    'late token configuration restore cannot replace a new visibility choice',
    () async {
      final store = globalAppStore;
      final previousStorage = store.localStorage;
      final storage = DelayedConfigStorage();
      store.localStorage = storage;
      addTearDown(() => store.localStorage = previousStorage);
      final pending = store.assets!.loadTokenLocalConfigCache();
      store.assets!.tokenList.add(
        Token(
          tokenAssestInfo: TokenAssetInfo(
            tokenId: 'token',
            publicKey: 'account',
            balance: Balance(total: '1', liquid: '1'),
          ),
        ),
      );
      await store.assets!.updateTokenShowStatus('account', tokenId: 'token');
      final hidden = Map<String, dynamic>.from(store.assets!.localHideTokenMap);
      storage.config.complete({
        'localShowedTokenIds': [],
        'localHideTokenList': {},
      });
      await pending;
      expect(store.assets!.localHideTokenMap, hidden);
      expect(store.assets!.localShowedTokenIds, contains('token'));
    },
  );

  test(
    'request context rejects old account, network, node and A-B-A reads',
    () async {
      final store = globalAppStore;
      final main = store.settings!.currentNode!;
      final first = store.requests.start('history');
      final second = store.requests.start('history');
      expect(first(), isFalse);
      expect(second(), isTrue);
      await store.settings!.setCurrentNode(node('mina:devnet', main.url));
      await store.settings!.setCurrentNode(main);
      expect(second(), isFalse);
      final sameNetwork = store.requests.start('history');
      await store.settings!.setCurrentNode(
        node('mina:mainnet', 'https://other.example'),
      );
      expect(sameNetwork(), isFalse);
      final otherAccount = store.requests.start('history');
      store.wallet!.currentWalletId = 'missing';
      expect(otherAccount(), isFalse);
    },
  );

  test(
    'context reaction does not invalidate a request started inside the switch action',
    () {
      final context = Observable('A');
      final tracker = RequestTracker(() => context.value);
      addTearDown(tracker.dispose);
      final old = tracker.start('assets');
      late bool Function() latest;
      runInAction(() {
        context.value = 'B';
        latest = tracker.start('assets');
      });
      expect(old(), isFalse);
      expect(latest(), isTrue);
    },
  );

  test(
    'page reaction can start a valid request before the tracker reaction runs',
    () {
      final context = Observable('A');
      late RequestTracker tracker;
      late bool Function() latest;
      final stopPage = reaction((_) => context.value, (_) {
        latest = tracker.start('assets');
      });
      addTearDown(stopPage);
      tracker = RequestTracker(() => context.value);
      addTearDown(tracker.dispose);
      final old = tracker.start('assets');
      runInAction(() => context.value = 'B');
      expect(old(), isFalse);
      expect(latest(), isTrue);
    },
  );

  test('late price cache cannot overwrite a new network', () async {
    final store = globalAppStore;
    final previousStorage = store.localStorage;
    final storage = DelayedObjectStorage(store.assets!.cachePriceKey);
    store.localStorage = storage;
    addTearDown(() => store.localStorage = previousStorage);
    final pending = store.assets!.loadMarketPricesCache();
    await store.settings!.setCurrentNode(
      node('mina:devnet', 'https://dev.example'),
    );
    store.assets!.marketPrices.clear();
    storage.value.complete({ZK_DEFAULT_TOKEN_ID: 10.0});
    await pending;
    expect(store.assets!.marketPrices, isEmpty);
  });

  test(
    'ignored history updates do not block account cache restoration',
    () async {
      final store = globalAppStore;
      await store.localStorage.setAccountCache(
        'account',
        store.assets!.cacheFullTxsKey,
        {
          ZK_DEFAULT_TOKEN_ID: [
            TransferData.toJson(TransferData()..hash = 'cached'),
          ],
        },
      );
      final restore = store.assets!.loadAccountCache();
      await store.assets!.addFullTxs([], 'account', ZK_DEFAULT_TOKEN_ID);
      await store.assets!.addFullTxs(
        [{}],
        'other-account',
        ZK_DEFAULT_TOKEN_ID,
      );
      await restore;
      expect(
        store.assets!.tokenFullTxs[ZK_DEFAULT_TOKEN_ID]!.single.hash,
        'cached',
      );
    },
  );

  test('network caches isolate stored history', () async {
    final store = globalAppStore;
    final assets = store.assets!;
    final main = store.settings!.currentNode!;
    final mainKey = assets.cacheFullTxsKey;
    final saved = {
      ZK_DEFAULT_TOKEN_ID: [
        {'hash': 'main-history'},
      ],
    };
    await store.localStorage.setAccountCache('account', mainKey, saved);
    await store.settings!.setCurrentNode(node('mina:devnet', main.url));
    expect(assets.cacheFullTxsKey, isNot(mainKey));
    expect(
      await store.localStorage.getAccountCache(
        'account',
        assets.cacheFullTxsKey,
      ),
      isNull,
    );
    await store.settings!.setCurrentNode(main);
    expect(
      await store.localStorage.getAccountCache(
        'account',
        assets.cacheFullTxsKey,
      ),
      saved,
    );
  });

  test(
    'asset and staking cache keys isolate nodes, archive endpoints and accounts',
    () async {
      final store = globalAppStore;
      final main = store.settings!.currentNode!;
      final assets = store.assets!;
      final staking = store.staking!;
      final mainKeys = [
        assets.cacheBalanceKey,
        assets.cacheTokensKey,
        assets.cacheFullTxsKey,
        staking.localStorageOverviewKey,
        staking.localStorageDelegationCacheKey,
      ];
      for (final target in [
        node('mina:devnet', main.url),
        node('mina:mainnet', 'https://other.example'),
        node('mina:mainnet', main.url)..txUrl = 'https://other.example/archive',
      ]) {
        await store.settings!.setCurrentNode(target);
        final keys = [
          assets.cacheBalanceKey,
          assets.cacheTokensKey,
          assets.cacheFullTxsKey,
          staking.localStorageOverviewKey,
          staking.localStorageDelegationCacheKey,
        ];
        for (var i = 0; i < keys.length; i++) {
          expect(keys[i], isNot(mainKeys[i]));
        }
      }
      await store.settings!.setCurrentNode(main);
      for (final key in mainKeys.take(3)) {
        await store.localStorage.setAccountCache('account', key, {
          'owner': 'A',
        });
        await store.localStorage.setAccountCache('other', key, {'owner': 'B'});
        expect(await store.localStorage.getAccountCache('account', key), {
          'owner': 'A',
        });
        expect(await store.localStorage.getAccountCache('other', key), {
          'owner': 'B',
        });
      }
      // Recreate the store to check that isolation is stable across restarts.
      expect(AssetsStore(store).cacheTokensKey, mainKeys[1]);
      store.wallet!.walletList.add(
        WalletData()
          ..id = 'other-wallet'
          ..accounts = [
            AccountData()
              ..pubKey = 'other'
              ..accountIndex = 0,
          ]
          ..currentAccountIndex = 0,
      );
      store.wallet!.currentWalletId = 'other-wallet';
      expect(staking.localStorageDelegationCacheKey, isNot(mainKeys.last));
      store.wallet!.currentWalletId = 'wallet';
      expect(staking.localStorageDelegationCacheKey, mainKeys.last);
    },
  );

  test(
    'late balance response cannot populate the next account context',
    () async {
      final store = globalAppStore;
      final response = Completer<Response>();
      final api = TestApi()
        ..graphQLClient = GraphQLClient(
          link: Link.function((_, [__]) => Stream.fromFuture(response.future)),
          cache: GraphQLCache(),
        );
      final pending = ApiAssets(api).fetchBatchAccountsInfo(['account']);
      await Future<void>.delayed(Duration.zero);
      store.wallet!.currentWalletId = 'missing';
      response.complete(
        Response(
          response: const {},
          data: {
            'account0': {
              'publicKey': 'account',
              'balance': {'total': '999'},
              'inferredNonce': '1',
              'delegateAccount': null,
            },
          },
        ),
      );
      await pending;
      expect(store.assets!.accountsInfo, isEmpty);
      expect(
        await store.localStorage.getAccountCache(
          'account',
          store.assets!.cacheBalanceKey,
        ),
        isNull,
      );
    },
  );

  test(
    'late account cache restore cannot replace new-network assets',
    () async {
      final store = globalAppStore;
      final previousStorage = store.localStorage;
      final storage = DelayedConfigStorage();
      store.localStorage = storage;
      addTearDown(() => store.localStorage = previousStorage);
      final pending = store.assets!.loadAccountCache();
      await store.settings!.setCurrentNode(
        node('mina:devnet', 'https://dev.example'),
      );
      store.assets!.tokenList.add(
        Token(
          tokenAssestInfo: TokenAssetInfo(
            tokenId: 'new-token',
            publicKey: 'account',
            balance: Balance(total: '1', liquid: '1'),
          ),
        ),
      );
      storage.config.complete(null);
      await pending;
      expect(
        store.assets!.tokenList.single.tokenAssestInfo!.tokenId,
        'new-token',
      );
    },
  );

  test('concurrent cache writes preserve both accounts', () async {
    final storage = LocalStorage();
    await Future.wait([
      storage.setAccountCache('a', 'cache', {'balance': 1}),
      storage.setAccountCache('b', 'cache', {'balance': 2}),
    ]);
    expect(await storage.getAccountCache('a', 'cache'), {'balance': 1});
    expect(await storage.getAccountCache('b', 'cache'), {'balance': 2});
  });

  test(
    'late pending response cannot restore old-network transactions',
    () async {
      final api = TestApi();
      final response = Completer<Response>();
      api.graphQLClient = GraphQLClient(
        link: Link.function((_, [__]) => Stream.fromFuture(response.future)),
        cache: GraphQLCache(),
      );
      final pending = ApiAssets(api).fetchPendingTransactions('account');
      await Future<void>.delayed(Duration.zero);
      await globalAppStore.settings!.setCurrentNode(
        node('mina:devnet', 'https://main.example'),
      );
      globalAppStore.assets!.pendingTxs.add(
        TransferData()..hash = 'new-network',
      );
      response.complete(
        Response(response: const {}, data: {'pooledUserCommands': []}),
      );
      await pending;
      expect(globalAppStore.assets!.pendingTxs.single.hash, 'new-network');
    },
  );

  test(
    'staking overview pins both queries and ignores a late daemon response',
    () async {
      final api = TestApi();
      final response = Completer<Response>();
      var oldQueries = 0;
      api.graphQLClient = GraphQLClient(
        link: Link.function((_, [__]) {
          oldQueries++;
          return Stream.fromFuture(response.future);
        }),
        cache: GraphQLCache(),
      );
      final pending = ApiStaking(api).fetchStakingOverview();
      await Future<void>.delayed(Duration.zero);
      await globalAppStore.settings!.setCurrentNode(
        node('mina:devnet', 'https://dev.example'),
      );
      response.complete(
        Response(
          response: const {},
          data: {
            'daemonStatus': {
              'stateHash': 'old',
              'blockchainLength': '99',
              'consensusConfiguration': {
                'slotsPerEpoch': 7140,
                'slotDuration': 90000,
                'epochDuration': 642600000,
              },
            },
          },
        ),
      );
      await pending;
      expect(oldQueries, 1);
      expect(globalAppStore.staking!.overviewData.stateHash, isEmpty);
    },
  );

  test('cache clear is ordered between earlier and later writes', () async {
    final storage = LocalStorage();
    await Future.wait([
      storage.setAccountCache('before', 'cache', 1),
      storage.clearAccountsCache('cache'),
      storage.setAccountCache('after', 'cache', 2),
    ]);
    expect(await storage.getAccountCache('before', 'cache'), isNull);
    expect(await storage.getAccountCache('after', 'cache'), 2);
  });

  test('missing token config cannot retain another context', () async {
    final store = globalAppStore;
    store.assets!.localShowedTokenIds.add('old');
    await store.assets!.loadTokenLocalConfigCache();
    expect(store.assets!.localShowedTokenIds, isEmpty);
  });

  test(
    'late token metadata cannot overwrite assets or loading after a switch',
    () async {
      await globalAppStore.settings!.setCurrentNode(
        node('mina:devnet', 'https://dev.example'),
      );
      final api = TestApi();
      final metadata = Completer<Response>();
      final metadataStarted = Completer<void>();
      api.graphQLClient = GraphQLClient(
        link: Link.function((request, [_]) {
          if (request.variables.containsKey('publicKey')) {
            return Stream.value(
              Response(
                response: const {},
                data: {
                  'accounts': [
                    {
                      'balance': {'total': '100', 'liquid': '100'},
                      'inferredNonce': '0',
                      'delegateAccount': null,
                      'tokenId': 'testToken',
                      'publicKey': 'account',
                      'zkappUri': null,
                    },
                  ],
                },
              ),
            );
          }
          metadataStarted.complete();
          return Stream.fromFuture(metadata.future);
        }),
        cache: GraphQLCache(),
      );
      final pending = ApiAssets(api).fetchAllTokenAssets(showIndicator: true);
      await metadataStarted.future;
      await globalAppStore.settings!.setCurrentNode(
        node('mina:devnet', 'https://new.example'),
      );
      globalAppStore.assets!.setAssetsLoading(true);
      metadata.complete(
        Response(response: const {}, data: {'testToken': null}),
      );
      await pending;
      expect(globalAppStore.assets!.tokenList, isEmpty);
      expect(globalAppStore.assets!.isAssetsLoading, isTrue);
    },
  );

  test(
    'cache restore cannot cancel an active asset refresh or retain loading',
    () async {
      final store = globalAppStore;
      await store.settings!.setCurrentNode(
        node('mina:devnet', 'https://dev.example'),
      );
      final response = Completer<Response>();
      final api = TestApi()
        ..graphQLClient = GraphQLClient(
          link: Link.function((_, [__]) => Stream.fromFuture(response.future)),
          cache: GraphQLCache(),
        );
      final pending = ApiAssets(api).fetchAllTokenAssets(showIndicator: true);
      await store.assets!.loadAccountCache();
      response.complete(Response(response: const {}, data: {'accounts': []}));
      await pending;
      expect(store.assets!.tokenList, hasLength(1));
      expect(store.assets!.isAssetsLoading, isFalse);
      // Even a later cache restore must not replace data already refreshed.
      await store.localStorage.setAccountCache(
        'account',
        store.assets!.cacheTokensKey,
        [],
      );
      await store.assets!.loadAccountCache();
      expect(store.assets!.tokenList, hasLength(1));
    },
  );

  test(
    'staking cache restore never supersedes a started node request',
    () async {
      final store = globalAppStore;
      final isCurrent = store.requests.start('staking-overview');
      store.staking!.setOverviewInfo({
        'epoch': 42,
        'slot': 1,
        'slotsPerEpoch': 7140,
        'slotDuration': 90000,
      }, shouldCache: false);
      await store.localStorage.setObject(
        store.staking!.localStorageOverviewKey,
        {'epoch': 1, 'slot': 1, 'slotsPerEpoch': 7140, 'slotDuration': 90000},
      );
      await store.staking!.loadCache();
      expect(isCurrent(), isTrue);
      expect(store.staking!.overviewData.epoch, 42);
    },
  );

  test('developer asset query does not invalidate a normal refresh', () async {
    final store = globalAppStore;
    await store.settings!.setCurrentNode(
      node('mina:devnet', 'https://dev.example'),
    );
    final response = Completer<Response>();
    final api = TestApi()
      ..graphQLClient = GraphQLClient(
        link: Link.function((_, [__]) => Stream.fromFuture(response.future)),
        cache: GraphQLCache(),
      );
    final assets = ApiAssets(api);
    final normal = assets.fetchAllTokenAssets(showIndicator: true);
    final diagnostic = assets.fetchAllTokenAssets(isDev: true);
    response.complete(Response(response: const {}, data: {'accounts': []}));
    await Future.wait([normal, diagnostic]);
    expect(store.assets!.tokenList, hasLength(1));
    expect(store.assets!.isAssetsLoading, isFalse);
  });

  test(
    'older nonce pending response cannot overwrite the latest token list',
    () async {
      final firstResponse = Completer<http.Response>();
      final secondResponse = Completer<http.Response>();
      final client = MockClient((request) {
        final body = jsonDecode(request.body) as Map;
        return body['nonce'] == 1
            ? firstResponse.future
            : secondResponse.future;
      });
      await http.runWithClient(() async {
        final assets = ApiAssets(TestApi());
        final first = assets.fetchPendingTokenList('account', '1');
        final second = assets.fetchPendingTokenList('account', '2');
        secondResponse.complete(
          http.Response(
            jsonEncode({
              'list': [
                {
                  'sender': 'account',
                  'network': 'mina:mainnet',
                  'nonce': 2,
                  'timestamp': '0',
                  'amount': '1',
                  'tokenaddress': 'token',
                  'receiver': 'to',
                },
              ],
            }),
            200,
          ),
        );
        await second;
        firstResponse.complete(http.Response('{"list":[]}', 200));
        await first;
        expect(
          globalAppStore.assets!.tokenPendingTxList['account']!.single.nonce,
          2,
        );
      }, () => client);
    },
  );

  test(
    'non-mainnet validator refresh preserves the mainnet disk cache',
    () async {
      final store = globalAppStore;
      final cacheKey = store.staking!.localStorageValidatorsV2Key;
      final cached = {
        'active': [
          {'public_key': 'validator', 'fee': 0, 'delegations': 0},
        ],
        'inactive': [],
      };
      await store.localStorage.setObject(cacheKey, cached);
      await store.settings!.setCurrentNode(
        node('mina:devnet', 'https://dev.example'),
      );
      await ApiStaking(TestApi()).fetchValidators();
      expect(store.staking!.validatorsInfo, isEmpty);
      expect(await store.localStorage.getObject(cacheKey), cached);
      await store.settings!.setCurrentNode(
        node('mina:mainnet', 'https://main.example'),
      );
      await store.staking!.loadCache();
      expect(store.staking!.validatorsInfo.single.address, 'validator');
    },
  );
}
