import 'package:auro_wallet/common/consts/index.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/assets/types/feeTransferData.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/assets/types/scamInfo.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenInfoData.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:auro_wallet/utils/zkUtils.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:mobx/mobx.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(AppStore store) : super(store);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageBlocksKey = 'blocks';

  final String localStorageFeesKey = 'fees';
  final String cacheBalanceKey = 'balance';
  final String cachePriceKey = 'coin_price_v2';
  final String cacheTxsKey = 'txs';
  final String cacheFeeTxsKey = 'fee_txs';
  final String cacheScamListKey = 'scam_list';
  final scamKey = 'wallet_sacm_list';

  final String cacheZkTxsKey = 'zk_txs_v2';

  final String cacheTokensKey = 'account_token_v10';

  final String cacheTokenConfigKey = 'account_token_config_v10';

  final String cacheTokenInfoKey = 'token_info_v10';

  @observable
  bool isAssetsLoading = true;

  @observable
  bool isBalanceLoading = false;

  @observable
  ObservableMap<String, AccountInfo> accountsInfo =
      ObservableMap<String, AccountInfo>();

  @observable
  Map<String, String> tokenBalances = Map<String, String>();

  @observable
  Fees transferFees = defaultTxFees;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TransferData> pendingTxs = ObservableList<TransferData>();

  @observable
  ObservableList<TransferData> txs = ObservableList<TransferData>();

  @observable
  ObservableList<FeeTransferData> feeTxs = ObservableList<FeeTransferData>();

  @observable
  ObservableList<ScamItem> scamList = ObservableList<ScamItem>();

  @observable
  String scamAddressStr = "";

  @observable
  ObservableList<TransferData> pendingZkTxs = ObservableList<TransferData>();

  @observable
  ObservableList<TransferData> zkTxs = ObservableList<TransferData>();

  @observable
  ObservableMap<String, List<TransferData>> tokenZkTxs =
      ObservableMap<String, List<TransferData>>();

  @observable
  int txsFilter = 0;

  @observable
  ObservableList<Token> tokenList = ObservableList<Token>();

  @observable
  ObservableMap<String, double> marketPrices = ObservableMap<String, double>();

  @observable
  ObservableMap<String, dynamic> localHideTokenMap =
      ObservableMap<String, dynamic>();

  @observable
  List<String> localShowedTokenIds = ObservableList<String>();

  @observable
  Token nextToken = Token();

  @observable
  List<TokenInfoData> tokenInfoList = [];

  @action
  Future<void> setNextToken(Token token) async {
    nextToken = token;
  }

  @computed
  int get newTokenCount {
    int count = 0;
    try {
      for (var token in tokenList) {
        if (token.localConfig == null ||
            token.localConfig!.tokenShowed != true) {
          if (token.tokenAssestInfo != null &&
              token.tokenAssestInfo!.tokenId != ZK_DEFAULT_TOKEN_ID) {
            count++;
          }
        }
      }
    } catch (e) {
      print('newTokenCount calc error ${e.toString()}.');
    }
    return count;
  }

  String getTokenTotalAmount() {
    double totalShowAmount = 0;
    double tokenAmount;

    for (var token in tokenList) {
      if (token.localConfig == null || token.localConfig!.hideToken != true) {
        tokenAmount = token.tokenBaseInfo?.showAmount ?? 0;
        totalShowAmount += tokenAmount;
      }
    }

    return totalShowAmount.toString();
  }

  @computed
  Token get mainTokenNetInfo {
    Token token;
    try {
      token = tokenList.firstWhere(
          (token) => token.tokenAssestInfo?.tokenId == ZK_DEFAULT_TOKEN_ID);
      print('Found Token ID: ${token.tokenAssestInfo?.tokenId}');
      print('Token Public Key: ${token.tokenAssestInfo?.publicKey}');
    } catch (e) {
      print('Token with ID $ZK_DEFAULT_TOKEN_ID not found.');
      token = Token.fromJson(defaultMINAAssets);
    }
    return token;
  }

  List<Token> getTokenShowList() {
    return tokenList
        .where((tokenItem) => !(tokenItem.localConfig?.hideToken ?? false))
        .toList();
  }

  @action
  List<TransferData> getTotalTxs(String tokenId) {
    var gettime = (TransferData tx) {
      String dateTimeStr = '';
      dateTimeStr = tx.time ?? '';
      if (dateTimeStr.isEmpty) {
        return DateTime.now();
      }
      return Fmt.toDatetime(dateTimeStr);
    };
    List<TransferData> totals = [];
    List<TransferData> sourceTotals = [];

    List<TransferData> nextZkTx = tokenZkTxs[tokenId] ?? [];
    if (tokenId == ZK_DEFAULT_TOKEN_ID) {
      sourceTotals = [...txs, ...nextZkTx];
    } else {
      sourceTotals = [...nextZkTx];
    }
    sourceTotals.forEach((i) {
      if (rootStore.settings?.isMainnet == true) {
        var addlow = i.sender!.toLowerCase();
        i.isFromAddressScam = scamAddressStr.indexOf(addlow) != -1;
      } else {
        i.isFromAddressScam = false;
      }
    });
    totals.addAll(sourceTotals);
    totals.sort((tx1, tx2) {
      var dateTime1 = gettime(tx1);
      var dateTime2 = gettime(tx2);
      int dateTimeCompareRes = dateTime2.compareTo(dateTime1);
      if (dateTimeCompareRes != 0) {
        return dateTimeCompareRes;
      }
      int? nonce1 = tx1.nonce;
      int? nonce2 = tx2.nonce;
      if (nonce1 != null && nonce2 != null) {
        return nonce2.compareTo(nonce1);
      }
      return 0;
    });
    return totals;
  }

  @action
  List<TransferData> getTotalPendingTxs(String tokenId) {
    List<TransferData> totals = [];
    List<TransferData> sourceTotals = [...pendingTxs, ...pendingZkTxs];
    sourceTotals.forEach((i) {
      if (rootStore.settings?.isMainnet == true) {
        var addlow = i.sender!.toLowerCase();
        i.isFromAddressScam = scamAddressStr.indexOf(addlow) != -1;
      } else {
        i.isFromAddressScam = false;
      }
    });

    totals.addAll(sourceTotals);
    totals.sort((tx1, tx2) {
      int? nonce1 = tx1.nonce;
      int? nonce2 = tx2.nonce;
      if (nonce1 != null && nonce2 != null) {
        return nonce2.compareTo(nonce1);
      }
      return 0;
    });
    if (totals.isNotEmpty) {
      totals[totals.length - 1].showSpeedUp = true;
    }
    List<TransferData> nextTotals;
    if (tokenId == ZK_DEFAULT_TOKEN_ID) {
      nextTotals = totals;
    } else {
      nextTotals = tokenHistoryFilter(totals, tokenId);
    }
    return nextTotals;
  }

  @action
  Future<void> setAccountInfo(String pubKey, dynamic amt,
      {bool needCache = true}) async {
    // if (rootStore.wallet!.currentWallet.pubKey != pubKey) return;
    if (amt == null) {
      accountsInfo.remove(pubKey);
    } else {
      accountsInfo[pubKey] = AccountInfo.fromJson(amt as Map<String, dynamic>);
    }

    if (!needCache) return;
    // Map? cache = await rootStore.localStorage.getAccountCache(
    //   pubKey,
    //   cacheBalanceKey,
    // ) as Map?;
    // cache = amt;
    rootStore.localStorage.setAccountCache(
      pubKey,
      cacheBalanceKey,
      amt,
    );
  }

  @action
  void setAssetsLoading(bool isLoading) {
    isAssetsLoading = isLoading;
  }

  @action
  Future<void> clearTxs() async {
    txs.clear();
  }

  @action
  Future<void> clearZkTxs() async {
    zkTxs.clear();
    tokenZkTxs.clear();
  }

  @action
  Future<void> clearFeeTxs() async {
    feeTxs.clear();
  }

  @action
  Future<void> clearPendingTxs() async {
    pendingTxs.clear();
  }

  @action
  Future<void> clearPendingZkTxs() async {
    pendingZkTxs.clear();
  }

  @action
  Future<void> clearAllTxs() async {
    txs.clear();
    zkTxs.clear();
    pendingTxs.clear();
    pendingZkTxs.clear();
    await rootStore.localStorage.setAccountCache(
        rootStore.wallet!.currentWallet.pubKey, cacheTxsKey, []);
  }

  @action
  Future<void> addPendingTxs(List<dynamic>? ls, String address) async {
    if (rootStore.wallet!.currentAddress != address) return;
    if (ls == null) return;
    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
      TransferData tx = TransferData.fromPendingJson(i);
      pendingTxs.add(tx);
    });
    pendingTxs.sort((tx1, tx2) => tx2.nonce! - tx1.nonce!);
  }

  @action
  Future<void> addPendingZkTxs(List<dynamic>? ls, String address) async {
    if (rootStore.wallet!.currentAddress != address) return;
    if (ls == null) return;
    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
      TransferData tx = TransferData.fromZkPendingJson(i);
      pendingZkTxs.add(tx);
    });
    pendingZkTxs.sort((tx1, tx2) => tx2.nonce! - tx1.nonce!);
  }

  @action
  Future<void> addFeeTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) async {
    if (rootStore.wallet!.currentAddress != address) return;

    if (ls == null) return;

    ls.forEach((i) {
      FeeTransferData tx = FeeTransferData.fromJson(i);
      feeTxs.add(tx);
    });

    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheFeeTxsKey, ls);
    }
  }

  @action
  Future<void> addTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) async {
    if (rootStore.wallet!.currentAddress != address) return;

    if (ls == null) return;

    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
      TransferData tx = TransferData.fromGraphQLJson(i);
      tx.success = tx.status != 'failed';
      i['success'] = tx.success;
      txs.add(tx);
    });

    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheTxsKey, ls);
    }
  }

  @action
  Future<void> addZkTxs(List<dynamic> ls, String address, String tokenId,
      {bool shouldCache = false}) async {
    try {
      if (rootStore.wallet!.currentAddress != address) return;
      if (ls.isEmpty) return;
      List<TransferData> tempZkTxList = [];
      ls.forEach((i) {
        i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
        TransferData tx = TransferData.fromZkGraphQLJson(i);
        tx.success = tx.status != 'failed';
        i['success'] = tx.success;
        tempZkTxList.add(tx);
      });

      Map<String, List<TransferData>> tempTokenTx = Map.from(tokenZkTxs);
      tempTokenTx[tokenId] = tempZkTxList;
      tokenZkTxs.clear();
      tokenZkTxs.addAll(tempTokenTx);
      if (shouldCache) {
        Map<String, List<Map<String, dynamic>>> jsonMap = {};
        tokenZkTxs.forEach((key, value) {
          jsonMap[key] = value
              .map((transferData) => TransferData.toJson(transferData))
              .toList();
        });
        rootStore.localStorage.setAccountCache(
            rootStore.wallet!.currentWallet.pubKey, cacheZkTxsKey, jsonMap);
      }
    } catch (e) {
      print("addZkTxs===11=${e.toString()}");
    }
  }

  @action
  Future<void> setFeesMap(Map<String, double> fees) async {
    transferFees = Fees.fromJson(fees);
    rootStore.localStorage.setObject(localStorageFeesKey, transferFees);
  }

  @action
  void setBalanceLoading(bool isLoading) {
    isBalanceLoading = isLoading;
  }

  @action
  void setMarketPrices(String tokenId, double price) {
    marketPrices[tokenId] = price;
    rootStore.localStorage.setObject(
        cachePriceKey, marketPrices.map((key, value) => MapEntry(key, value)));
  }

  @action
  Future<void> clearMarketPrices() async {
    marketPrices.clear();
    await rootStore.localStorage.setObject(cachePriceKey, {});
  }

  @action
  Future<void> loadMultiAccountCache() async {
    for (var account in rootStore.wallet!.accountListAll) {
      Map? cache = await rootStore.localStorage
          .getAccountCache(account.pubKey, cacheBalanceKey) as Map?;
      if (cache != null) {
        setAccountInfo(account.pubKey, cache, needCache: false);
      }
    }
  }

  @action
  Future<void> loadAccountCache() async {
    String pubKey = rootStore.wallet!.currentAccountPubKey;
    if (pubKey.isEmpty) {
      return;
    }
    await loadTokenLocalConfigCache();
    List cache = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, cacheBalanceKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheFeeTxsKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheZkTxsKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTokensKey),
    ]);

    if (cache[0] != null) {
      setAccountInfo(pubKey, cache[0], needCache: false);
    }
    if (cache[1] != null) {
      txs = ObservableList.of(
          List.of(cache[1]).map((i) => TransferData.fromJson(i)).toList());
    } else {
      txs = ObservableList();
    }
    if (cache[2] != null) {
      feeTxs = ObservableList.of(
          List.of(cache[2]).map((i) => FeeTransferData.fromJson(i)).toList());
    } else {
      feeTxs = ObservableList();
    }
    if (cache[3] != null) {
      Map<String, dynamic> jsonMap = cache[3];
      ObservableMap<String, List<TransferData>> tempTokenZkTx =
          ObservableMap<String, List<TransferData>>();
      jsonMap.forEach((key, value) {
        List<TransferData> transferDataList = (value as List<dynamic>)
            .map((item) => TransferData.fromJson(item))
            .toList();
        tempTokenZkTx[key] = transferDataList;
      });
      tokenZkTxs.addAll(tempTokenZkTx);
    } else {
      tokenZkTxs = ObservableMap<String, List<TransferData>>();
    }
    if (cache[4] != null) {
      tokenList = ObservableList.of(
          List.of(cache[4]).map((i) => Token.fromJson(i)).toList());
    } else {
      tokenList = ObservableList();
    }
  }

  @action
  Future<void> loadMarketPricesCache() async {
    Map<String, dynamic>? prices = await rootStore.localStorage
        .getObject(cachePriceKey) as Map<String, dynamic>?;
    if (prices != null) {
      marketPrices
          .addAll(prices.map((key, value) => MapEntry(key, value as double)));
    }
  }

  @action
  Future<void> loadFeesCache() async {
    Map<String, dynamic>? fees = await rootStore.localStorage
        .getObject(localStorageFeesKey) as Map<String, dynamic>?;
    if (fees != null) {
      transferFees = Fees.fromJson(fees);
    } else {
      transferFees = Fees.fromDefault();
    }
  }

  @action
  Future<void> clearAccountCache() async {
    rootStore.localStorage.clearAccountsCache(cacheTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheFeeTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheBalanceKey);
    rootStore.localStorage.clearAccountsCache(cacheZkTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheTokensKey);
    txs = ObservableList();
    feeTxs = ObservableList();
    accountsInfo = ObservableMap<String, AccountInfo>();
    zkTxs = ObservableList();
    tokenList = ObservableList();

    clearTokenLocalConfigCache();
  }

  @action
  Future<void> loadCache() async {
    await loadLocalScamList();
    await loadFeesCache();
    await loadMarketPricesCache();
    await loadTokenInfoCache();
    await loadAccountCache();
    await loadMultiAccountCache();
  }

  @action
  void setLocalScamList(List<ScamItem> ls) {
    scamList.addAll(ls);

    var scamAddressStrCache = "";
    ls.forEach((scam) {
      scamAddressStrCache = scamAddressStrCache + "," + scam.address;
    });
    scamAddressStrCache = scamAddressStrCache.toLowerCase();

    scamAddressStr = scamAddressStrCache;
    rootStore.localStorage.setObject(scamKey, ls);
  }

  void clearScamList() {
    scamList = ObservableList<ScamItem>();
  }

  @action
  Future<void> loadLocalScamList() async {
    List<dynamic>? scamCacheList =
        await rootStore.localStorage.getObject(scamKey) as List<dynamic>?;
    if (scamCacheList == null) {
      scamCacheList = [];
    }
    List<ScamItem> scamList = scamCacheList.map((item) {
      return ScamItem.fromJson(item);
    }).toList();

    var scamAddressStrCache = "";
    scamList.forEach((scam) {
      scamAddressStrCache = scamAddressStrCache + "," + scam.address;
    });
    scamAddressStrCache = scamAddressStrCache.toLowerCase();
    scamAddressStr = scamAddressStrCache;
  }

  @action
  Future<void> updateTokenShowStatus(
    String address, {
    required String tokenId,
  }) async {
    if (rootStore.wallet!.currentAddress != address) return;
    List<Token> tempTokenList = [];
    tempTokenList.addAll(tokenList);

    for (Token token in tempTokenList) {
      if (token.tokenAssestInfo != null &&
          token.tokenAssestInfo!.tokenId == tokenId) {
        if (token.localConfig == null) {
          token.localConfig = TokenLocalConfig(hideToken: false);
        } else {
          token.localConfig!.hideToken =
              !(token.localConfig!.hideToken ?? false);
        }
        localHideTokenMap[tokenId] = {
          'hideToken': token.localConfig!.hideToken ?? false
        };
        break;
      }
    }
    tokenList.clear();
    tokenList = ObservableList.of(tempTokenList);

    updateTokenLocalConfig(address,
        tokenShowedList: localShowedTokenIds,
        hideTokenList: localHideTokenMap,
        shouldCache: true);
  }

  @action
  void updateNewTokenConfig(
    String address,
  ) {
    if (rootStore.wallet!.currentAddress != address) return;

    List<String> tokenShowedList = [];
    List<Token> tempTokenList = [];

    for (Token token in tokenList) {
      if (token.localConfig != null) {
        token.localConfig?.tokenShowed = true;
      } else {
        token.localConfig = TokenLocalConfig(tokenShowed: true);
      }

      if (token.localConfig?.tokenShowed == true &&
          token.tokenAssestInfo != null) {
        tokenShowedList.add(token.tokenAssestInfo!.tokenId);
      }
      tempTokenList.add(token);
    }
    tokenList.clear();
    tokenList = ObservableList.of(tempTokenList);

    updateTokenLocalConfig(address,
        tokenShowedList: tokenShowedList,
        hideTokenList: localHideTokenMap,
        shouldCache: true);
  }

  @action
  void updateTokenLocalConfig(
    String address, {
    bool shouldCache = false,
    required List<String> tokenShowedList,
    required Map<String, dynamic> hideTokenList,
  }) {
    if (rootStore.wallet!.currentAddress != address) return;
    String? networkId = rootStore.settings!.currentNode?.networkID;

    Map<String, dynamic> localConfig = {
      "localShowedTokenIds": tokenShowedList, // List<String>
      "localHideTokenList": hideTokenList // Map<String, Map<String, dynamic>>
    };

    String keys =
        '${rootStore.wallet!.currentWallet.pubKey}_${networkId}_$cacheTokenConfigKey';
    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, keys, localConfig);
    }
  }

  @action
  void updateTokenAssets(List<Token> ls, String address,
      {bool shouldCache = false}) {
    if (rootStore.wallet!.currentAddress != address) return;

    Token mainTokenDefaultConfig = Token.fromJson(defaultMINAAssets);
    if (ls.isEmpty) {
      tokenList.clear();
      tokenList.add(mainTokenDefaultConfig);
    } else {
      List<Token> nextTokenList = ls.map((tokenItem) {
        TokenLocalConfig sourceLocalConfig =
            tokenItem.localConfig ?? TokenLocalConfig();
        TokenBaseInfo sourceBaseInfo =
            tokenItem.tokenBaseInfo ?? TokenBaseInfo();

        String tokenId = tokenItem.tokenAssestInfo?.tokenId ?? "";

        TokenInfoData? foundToken;
        try {
          foundToken = tokenInfoList.firstWhere(
            (token) => token.tokenId == tokenId,
          );
        } catch (e) {
          foundToken = null;
        }

        TokenLocalConfig localConfig = TokenLocalConfig.fromJson({
          ...sourceLocalConfig.toJson(),
        });
        if (localHideTokenMap.containsKey(tokenId)) {
          Map localConfigMap = localHideTokenMap[tokenId];
          localConfig.hideToken = localConfigMap['hideToken'] ?? true;
        } else {
          localConfig.hideToken = foundToken == null;
        }
        if (tokenId == ZK_DEFAULT_TOKEN_ID) {
          // always
          localConfig.hideToken = false;
        }

        TokenBaseInfo tokenBaseInfo = TokenBaseInfo.fromJson({
          ...sourceBaseInfo.toJson(),
        });

        tokenBaseInfo.isScam = false;
        tokenBaseInfo.iconUrl = foundToken != null ? foundToken.iconUrl : "";

        String decimals = "0";
        String? sourceTotalBalance = tokenItem.tokenAssestInfo?.balance.total;
        BigInt totalBalance = sourceTotalBalance != null
            ? BigInt.parse(sourceTotalBalance)
            : BigInt.from(0);

        String? tokenNetPublicKey = tokenItem.tokenNetInfo?.publicKey ?? "";
        if (tokenNetPublicKey.isNotEmpty) {
          List<String> zkappState = tokenItem.tokenNetInfo?.zkappState ?? [];
          try {
            if (zkappState.isNotEmpty) {
              decimals = zkappState[0];
            }
            tokenBaseInfo.decimals = decimals;
            tokenBaseInfo.showBalance = double.parse(Fmt.amountDecimals(
              totalBalance.toString(),
              decimal: int.parse(decimals),
            ));
          } catch (e) {
            tokenBaseInfo.decimals = decimals;
            tokenBaseInfo.showBalance = totalBalance.toDouble();
          }
        } else {
          if (tokenId == ZK_DEFAULT_TOKEN_ID) {
            tokenBaseInfo.isMainToken = true;
            String? delegateAccount =
                tokenItem.tokenAssestInfo?.delegateAccount?.publicKey;
            tokenBaseInfo.isDelegation = delegateAccount != null &&
                delegateAccount != tokenItem.tokenAssestInfo?.publicKey;
            tokenBaseInfo.decimals = COIN.decimals.toString();
            tokenBaseInfo.showBalance = double.parse(Fmt.amountDecimals(
              totalBalance.toString(),
              decimal: COIN.decimals,
            ));
            tokenBaseInfo.iconUrl = "assets/images/stake/icon_mina_color.svg";
          } else {
            tokenBaseInfo.decimals = decimals;
            tokenBaseInfo.showBalance = double.parse(Fmt.amountDecimals(
              totalBalance.toString(),
              decimal: int.parse(decimals),
            ));
          }
        }

        double? tokenPrice = marketPrices[tokenId];
        if (tokenPrice != null) {
          tokenBaseInfo.showAmount = double.parse(
              Fmt.priceCeil(tokenBaseInfo.showBalance! * tokenPrice));
        }
        localConfig.tokenShowed = localShowedTokenIds.contains(tokenId);

        Token updatedTokenItem = Token(
          tokenAssestInfo: tokenItem.tokenAssestInfo,
          tokenNetInfo: tokenItem.tokenNetInfo,
          localConfig: localConfig,
          tokenBaseInfo: tokenBaseInfo,
        );
        return updatedTokenItem;
      }).toList();

      nextTokenList.sort(compareTokens);

      int index = nextTokenList.indexWhere(
          (token) => token.tokenAssestInfo?.tokenId == ZK_DEFAULT_TOKEN_ID);
      if (index != -1) {
        Token token = nextTokenList.removeAt(index);
        nextTokenList.insert(0, token);
      } else {
        nextTokenList.insert(0, Token.fromJson(defaultMINAAssets));
      }

      tokenList.clear();
      tokenList = ObservableList.of(nextTokenList);
    }
    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheTokensKey, tokenList);
    }
  }

  @action
  Future<void> clearRuntimeTokens() async {
    tokenList.clear();
  }

  @action
  Future<void> clearAllTokens() async {
    clearRuntimeTokens();
    rootStore.localStorage.setAccountCache(
        rootStore.wallet!.currentWallet.pubKey, cacheTokensKey, []);
  }

  @action
  Future<void> clearAssestNodeCache() async {
    clearAllTxs();
    clearMarketPrices();
    clearAllTokens();
  }

  @action
  Future<void> clearAccountAssestCache() async {
    clearTxs();
    clearZkTxs();
    clearPendingTxs();
    clearPendingZkTxs();
    clearRuntimeTokens();
  }

  @action
  void setTokenInfoData(List<TokenInfoData> ls, {bool shouldCache = true}) {
    tokenInfoList = ls;
    String? networkId = rootStore.settings!.currentNode?.networkID;
    String readableNetworkId = getReadableNetworkId(networkId ?? "");
    if (shouldCache) {
      rootStore.localStorage
          .setObject(cacheTokenInfoKey + readableNetworkId, ls);
    }
  }

  @action
  Future<void> loadTokenInfoCache() async {
    String? networkId = rootStore.settings!.currentNode?.networkID;
    String readableNetworkId = getReadableNetworkId(networkId ?? "");
    List<dynamic>? tempTokenInfo = await rootStore.localStorage
        .getObject(cacheTokenInfoKey + readableNetworkId) as List<dynamic>?;
    if (tempTokenInfo == null) {
      tempTokenInfo = [];
    }
    tokenInfoList.clear();
    tokenInfoList = ObservableList.of(tempTokenInfo
        .map((i) => TokenInfoData.fromJson(i as Map<String, dynamic>)));
  }

  @action
  Future<void> loadTokenLocalConfigCache() async {
    String pubKey = rootStore.wallet!.currentAccountPubKey;
    if (pubKey.isEmpty) {
      return;
    }
    String? networkId = rootStore.settings!.currentNode?.networkID;
    String configKey = '${pubKey}_${networkId}_$cacheTokenConfigKey';
    dynamic localConfig =
        await rootStore.localStorage.getAccountCache(pubKey, configKey);

    if (localConfig != null) {
      localShowedTokenIds = ObservableList<String>.of(
          List<String>.from(localConfig['localShowedTokenIds']));
      localHideTokenMap = ObservableMap<String, dynamic>.of(
          (localConfig['localHideTokenList']));
    }
  }

  @action
  Future<void> clearTokenLocalConfigCache() async {
    String pubKey = rootStore.wallet!.currentAccountPubKey;
    if (pubKey.isEmpty) {
      return;
    }
    String? networkId = rootStore.settings!.currentNode?.networkID;
    String configKey = '${pubKey}_${networkId}_$cacheTokenConfigKey';
    rootStore.localStorage.clearAccountsCache(configKey);

    localHideTokenMap = ObservableMap<String, dynamic>();

    localShowedTokenIds = ObservableList<String>();
  }
}
