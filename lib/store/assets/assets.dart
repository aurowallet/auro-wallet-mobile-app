import 'package:auro_wallet/common/consts/index.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/store/assets/types/scamInfo.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenInfoData.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
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

  final String cacheScamListKey = 'wallet_sacm_list';
  final String cacheFullTxsKey = 'accounts_full_txs';

  final String cacheTokensKey = 'account_token_v1';

  final String cacheTokenConfigKey = 'account_token_config_v1';

  final String cacheTokenInfoKey = 'token_info_v1';

  @observable
  bool isAssetsLoading = true;

  @observable
  ObservableMap<String, AccountInfo> accountsInfo =
      ObservableMap<String, AccountInfo>();

  @observable
  Fees transferFees = defaultTxFees;

  @observable
  ObservableList<TransferData> pendingTxs = ObservableList<TransferData>();

  @observable
  ObservableList<ScamItem> scamList = ObservableList<ScamItem>();

  @observable
  String scamAddressStr = "";

  @observable
  ObservableList<TransferData> pendingZkTxs = ObservableList<TransferData>();

  @observable
  ObservableMap<String, List<TransferData>> tokenFullTxs =
      ObservableMap<String, List<TransferData>>();

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

  @observable
  ObservableMap<String, List<TransferData>> tokenBuildTxList =
      ObservableMap<String, List<TransferData>>();

  @observable
  ObservableMap<String, List<TokenPendingTx>> tokenPendingTxList =
      ObservableMap<String, List<TokenPendingTx>>();

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
    } catch (e) {
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
    List<TransferData> sourceTotals = tokenFullTxs[tokenId] ?? [];
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
  Future<void> addPendingTxs(List<dynamic>? ls, String address) async {
    pendingTxs.clear();
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
    pendingZkTxs.clear();
    if (rootStore.wallet!.currentAddress != address) return;
    if (ls == null) return;
    ls.forEach((i) {
      try {
        if (i['zkappCommand'] != null && i['zkappCommand']['memo'] != null) {
          i['memo'] = bs58Decode(i['zkappCommand']['memo']);
        } else {
          i['memo'] = "";
        }
      } catch (e) {
        i['memo'] = "";
      }

      TransferData tx = TransferData.fromZkPendingJson(i);
      pendingZkTxs.add(tx);
    });
    pendingZkTxs.sort((tx1, tx2) => tx2.nonce! - tx1.nonce!);
  }

  @action
  Future<void> addTokenBuildTxs(
      List<dynamic> ls, String address, String tokenAddress) async {
    if (rootStore.wallet!.currentAddress != address) return;
    List<TransferData> tempZkTxList = [];
    ls.forEach((i) {
      i['memo'] = i['memo'] != null ? i['memo'] : '';
      TransferData tx = TransferData.fromJson(i);
      i['status'] = "pending";
      tx.success = tx.status == 'applied';
      if (i['zk_failure'] != null) {
        tx.failureReason = i['zk_failure'];
      }
      tx.time = i['timestamp'];
      tempZkTxList.add(tx);
    });
    tokenBuildTxList[tokenAddress] = tempZkTxList;
  }

  @action
  Future<void> addTokenPendingTxs(List<dynamic> ls, String address) async {
    if (rootStore.wallet!.currentAddress != address) return;
    List<TokenPendingTx> tempTxList = ls.map((item) {
      return TokenPendingTx.fromJson(item);
    }).toList();
    tokenPendingTxList[address] = tempTxList;
  }

  // @action
  // Future<void> addTxs(List<dynamic> ls, String address,
  //     {bool shouldCache = false}) async {
  //   txs.clear();
  //   if (rootStore.wallet!.currentAddress != address) return;

  //   ls.forEach((i) {
  //     i['memo'] = i['memo'] != null ? bs58Decode(i['memo']) : '';
  //     TransferData tx = TransferData.fromGraphQLJson(i);
  //     tx.success = tx.status != 'failed';
  //     i['success'] = tx.success;
  //     txs.add(tx);
  //   });

  //   if (shouldCache) {
  //     rootStore.localStorage.setAccountCache(
  //         rootStore.wallet!.currentWallet.pubKey, cacheTxsKey, ls);
  //   }
  // }

  // @action
  // Future<void> addZkTxs(List<dynamic> ls, String address, String tokenId,
  //     {bool shouldCache = false}) async {
  //   try {
  //     // zkTxs.clear();
  //     if (rootStore.wallet!.currentAddress != address) return;
  //     if (ls.isEmpty) return;
  //     List<TransferData> tempZkTxList = [];
  //     ls.forEach((i) {
  //       try {
  //         if (i['zkappCommand'] != null && i['zkappCommand']['memo'] != null) {
  //           i['memo'] = bs58Decode(i['zkappCommand']['memo']);
  //         } else {
  //           i['memo'] = "";
  //         }
  //       } catch (e) {
  //         i['memo'] = "";
  //       }
  //       TransferData tx = TransferData.fromZkGraphQLJson(i);
  //       tx.success = tx.status != 'failed';
  //       i['success'] = tx.success;
  //       tempZkTxList.add(tx);
  //     });

  //     tokenFullTxs[tokenId] = tempZkTxList;
  //     if (shouldCache) {
  //       Map<String, List<Map<String, dynamic>>> jsonMap = {};
  //       tokenFullTxs.forEach((key, value) {
  //         jsonMap[key] = value
  //             .map((transferData) => TransferData.toJson(transferData))
  //             .toList();
  //       });
  //       rootStore.localStorage.setAccountCache(
  //           rootStore.wallet!.currentWallet.pubKey, cacheZkTxsKey, jsonMap);
  //     }
  //   } catch (e) {
  //     print("addZkTxs===e=${e.toString()}");
  //   }
  // }
  @action
  Future<void> addFullTxs(List<dynamic> ls, String address, String tokenId,
      {bool shouldCache = false}) async {
    try {
      if (rootStore.wallet!.currentAddress != address) return;
      if (ls.isEmpty) return;
      List<TransferData> tempZkTxList = [];
      ls.forEach((i) {
        if(i['kind'] == "zkApp"){
          dynamic realZkBody = i['zkAppBody'];
          try {
            if (realZkBody['zkappCommand'] != null && realZkBody['zkappCommand']['memo'] != null) {
              realZkBody['memo'] = bs58Decode(realZkBody['zkappCommand']['memo']);
            } else {
              realZkBody['memo'] = "";
            }
          } catch (e) {
            realZkBody['memo'] = "";
          }
          realZkBody['failureReason'] = realZkBody['failureReasons'];
          TransferData tx = TransferData.fromZkGraphQLJson(realZkBody);
          tx.success = tx.status != 'failed';
          realZkBody['success'] = tx.success;
          tempZkTxList.add(tx);
        }else{
          dynamic realTxBody = i['body'];
            realTxBody['memo'] = realTxBody['memo'] != null ? bs58Decode(realTxBody['memo']) : '';
            TransferData tx = TransferData.fromGraphQLJson(realTxBody);
            tx.success = tx.status != 'failed';
            realTxBody['success'] = tx.success;
            tempZkTxList.add(tx);
        }
      });
      tokenFullTxs[tokenId] = tempZkTxList;
      if (shouldCache) {
        Map<String, List<Map<String, dynamic>>> jsonMap = {};
        tokenFullTxs.forEach((key, value) {
          jsonMap[key] = value
              .map((transferData) => TransferData.toJson(transferData))
              .toList();
        });
        rootStore.localStorage.setAccountCache(
            rootStore.wallet!.currentWallet.pubKey, cacheFullTxsKey, jsonMap);
      }
    } catch (e) {
      print("addZkTxs===e=${e.toString()}");
    }
  }

  @action
  Future<void> setFeesMap(Map<String, double> fees) async {
    transferFees = Fees.fromJson(fees);
    rootStore.localStorage.setObject(localStorageFeesKey, transferFees);
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
      rootStore.localStorage.getAccountCache(pubKey, cacheTokensKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheFullTxsKey),
    ]);

    if (cache[0] != null) {
      setAccountInfo(pubKey, cache[0], needCache: false);
    }
    if (cache[1] != null) {
      tokenList.clear();
      List<Token> ls = List.of(cache[1]).map((i) => Token.fromJson(i)).toList();
      updateTokenAssets(ls, pubKey);
    } else {
      tokenList = ObservableList<Token>();
    }
    if (cache[2] != null) {
      tokenFullTxs.clear();
      Map<String, dynamic> jsonMap = cache[2];
      ObservableMap<String, List<TransferData>> tempTokenZkTx =
          ObservableMap<String, List<TransferData>>();
      jsonMap.forEach((key, value) {
        List<TransferData> transferDataList = (value as List<dynamic>)
            .map((item) => TransferData.fromJson(item))
            .toList();
        tempTokenZkTx[key] = transferDataList;
      });
      tokenFullTxs.addAll(tempTokenZkTx);
    } else {
      tokenFullTxs = ObservableMap<String, List<TransferData>>();
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
    rootStore.localStorage.clearAccountsCache(cacheFullTxsKey);
    rootStore.localStorage.clearAccountsCache(cacheBalanceKey);
    rootStore.localStorage.clearAccountsCache(cacheTokensKey);
    accountsInfo = ObservableMap<String, AccountInfo>();
    tokenFullTxs = ObservableMap<String, List<TransferData>>();
    tokenList = ObservableList<Token>();

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
    scamList.clear();
    scamAddressStr = "";

    scamList.addAll(ls);

    var scamAddressStrCache = "";
    ls.forEach((scam) {
      scamAddressStrCache = scamAddressStrCache + "," + scam.address;
    });
    scamAddressStrCache = scamAddressStrCache.toLowerCase();

    scamAddressStr = scamAddressStrCache;
    rootStore.localStorage.setObject(cacheScamListKey, ls);
  }

  @action
  Future<void> loadLocalScamList() async {
    List<dynamic>? scamCacheList = await rootStore.localStorage
        .getObject(cacheScamListKey) as List<dynamic>?;
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
    tokenList.clear();
    if (rootStore.wallet!.currentAddress != address) return;
    if (ls.isEmpty) {
      Token mainTokenDefaultConfig = Token.fromJson(defaultMINAAssets);
      tokenList = ObservableList.of([mainTokenDefaultConfig]);
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
              (tokenBaseInfo.showBalance! * tokenPrice).toStringAsFixed(2));
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

      tokenList = ObservableList.of(nextTokenList);
    }
    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.wallet!.currentWallet.pubKey, cacheTokensKey, tokenList);
    }
  }

  @action
  Future<void> clearAssestNodeCache() async {
    accountsInfo.clear();

    pendingTxs.clear();
    pendingZkTxs.clear();
    tokenFullTxs.clear();
    tokenBuildTxList.clear();
    tokenPendingTxList.clear();

    clearMarketPrices();

    tokenList.clear();

    localHideTokenMap.clear();
    localShowedTokenIds.clear();
    tokenInfoList.clear();

    rootStore.localStorage.setAccountCache(
        rootStore.wallet!.currentWallet.pubKey, cacheFullTxsKey, {});
    rootStore.localStorage.setAccountCache(
        rootStore.wallet!.currentWallet.pubKey, cacheTokensKey, []);
  }

  @action
  Future<void> clearAccountAssestCache() async {


    pendingTxs.clear();

    pendingZkTxs.clear();

    tokenFullTxs.clear();
    tokenBuildTxList.clear();
    tokenPendingTxList.clear();

    tokenList.clear();

    localHideTokenMap.clear();
    localShowedTokenIds.clear();
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
