// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssetsStore on _AssetsStore, Store {
  Computed<int>? _$newTokenCountComputed;

  @override
  int get newTokenCount =>
      (_$newTokenCountComputed ??= Computed<int>(() => super.newTokenCount,
              name: '_AssetsStore.newTokenCount'))
          .value;
  Computed<String>? _$tokenTotalAmountComputed;

  @override
  String get tokenTotalAmount => (_$tokenTotalAmountComputed ??=
          Computed<String>(() => super.tokenTotalAmount,
              name: '_AssetsStore.tokenTotalAmount'))
      .value;
  Computed<Token>? _$mainTokenNetInfoComputed;

  @override
  Token get mainTokenNetInfo => (_$mainTokenNetInfoComputed ??= Computed<Token>(
          () => super.mainTokenNetInfo,
          name: '_AssetsStore.mainTokenNetInfo'))
      .value;
  Computed<List<Token>>? _$tokenShowListComputed;

  @override
  List<Token> get tokenShowList => (_$tokenShowListComputed ??=
          Computed<List<Token>>(() => super.tokenShowList,
              name: '_AssetsStore.tokenShowList'))
      .value;

  late final _$isAssetsLoadingAtom =
      Atom(name: '_AssetsStore.isAssetsLoading', context: context);

  @override
  bool get isAssetsLoading {
    _$isAssetsLoadingAtom.reportRead();
    return super.isAssetsLoading;
  }

  @override
  set isAssetsLoading(bool value) {
    _$isAssetsLoadingAtom.reportWrite(value, super.isAssetsLoading, () {
      super.isAssetsLoading = value;
    });
  }

  late final _$isBalanceLoadingAtom =
      Atom(name: '_AssetsStore.isBalanceLoading', context: context);

  @override
  bool get isBalanceLoading {
    _$isBalanceLoadingAtom.reportRead();
    return super.isBalanceLoading;
  }

  @override
  set isBalanceLoading(bool value) {
    _$isBalanceLoadingAtom.reportWrite(value, super.isBalanceLoading, () {
      super.isBalanceLoading = value;
    });
  }

  late final _$accountsInfoAtom =
      Atom(name: '_AssetsStore.accountsInfo', context: context);

  @override
  ObservableMap<String, AccountInfo> get accountsInfo {
    _$accountsInfoAtom.reportRead();
    return super.accountsInfo;
  }

  @override
  set accountsInfo(ObservableMap<String, AccountInfo> value) {
    _$accountsInfoAtom.reportWrite(value, super.accountsInfo, () {
      super.accountsInfo = value;
    });
  }

  late final _$tokenBalancesAtom =
      Atom(name: '_AssetsStore.tokenBalances', context: context);

  @override
  Map<String, String> get tokenBalances {
    _$tokenBalancesAtom.reportRead();
    return super.tokenBalances;
  }

  @override
  set tokenBalances(Map<String, String> value) {
    _$tokenBalancesAtom.reportWrite(value, super.tokenBalances, () {
      super.tokenBalances = value;
    });
  }

  late final _$transferFeesAtom =
      Atom(name: '_AssetsStore.transferFees', context: context);

  @override
  Fees get transferFees {
    _$transferFeesAtom.reportRead();
    return super.transferFees;
  }

  @override
  set transferFees(Fees value) {
    _$transferFeesAtom.reportWrite(value, super.transferFees, () {
      super.transferFees = value;
    });
  }

  late final _$txsCountAtom =
      Atom(name: '_AssetsStore.txsCount', context: context);

  @override
  int get txsCount {
    _$txsCountAtom.reportRead();
    return super.txsCount;
  }

  @override
  set txsCount(int value) {
    _$txsCountAtom.reportWrite(value, super.txsCount, () {
      super.txsCount = value;
    });
  }

  late final _$pendingTxsAtom =
      Atom(name: '_AssetsStore.pendingTxs', context: context);

  @override
  ObservableList<TransferData> get pendingTxs {
    _$pendingTxsAtom.reportRead();
    return super.pendingTxs;
  }

  @override
  set pendingTxs(ObservableList<TransferData> value) {
    _$pendingTxsAtom.reportWrite(value, super.pendingTxs, () {
      super.pendingTxs = value;
    });
  }

  late final _$txsAtom = Atom(name: '_AssetsStore.txs', context: context);

  @override
  ObservableList<TransferData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TransferData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  late final _$feeTxsAtom = Atom(name: '_AssetsStore.feeTxs', context: context);

  @override
  ObservableList<FeeTransferData> get feeTxs {
    _$feeTxsAtom.reportRead();
    return super.feeTxs;
  }

  @override
  set feeTxs(ObservableList<FeeTransferData> value) {
    _$feeTxsAtom.reportWrite(value, super.feeTxs, () {
      super.feeTxs = value;
    });
  }

  late final _$scamListAtom =
      Atom(name: '_AssetsStore.scamList', context: context);

  @override
  ObservableList<ScamItem> get scamList {
    _$scamListAtom.reportRead();
    return super.scamList;
  }

  @override
  set scamList(ObservableList<ScamItem> value) {
    _$scamListAtom.reportWrite(value, super.scamList, () {
      super.scamList = value;
    });
  }

  late final _$scamAddressStrAtom =
      Atom(name: '_AssetsStore.scamAddressStr', context: context);

  @override
  String get scamAddressStr {
    _$scamAddressStrAtom.reportRead();
    return super.scamAddressStr;
  }

  @override
  set scamAddressStr(String value) {
    _$scamAddressStrAtom.reportWrite(value, super.scamAddressStr, () {
      super.scamAddressStr = value;
    });
  }

  late final _$pendingZkTxsAtom =
      Atom(name: '_AssetsStore.pendingZkTxs', context: context);

  @override
  ObservableList<TransferData> get pendingZkTxs {
    _$pendingZkTxsAtom.reportRead();
    return super.pendingZkTxs;
  }

  @override
  set pendingZkTxs(ObservableList<TransferData> value) {
    _$pendingZkTxsAtom.reportWrite(value, super.pendingZkTxs, () {
      super.pendingZkTxs = value;
    });
  }

  late final _$zkTxsAtom = Atom(name: '_AssetsStore.zkTxs', context: context);

  @override
  ObservableList<TransferData> get zkTxs {
    _$zkTxsAtom.reportRead();
    return super.zkTxs;
  }

  @override
  set zkTxs(ObservableList<TransferData> value) {
    _$zkTxsAtom.reportWrite(value, super.zkTxs, () {
      super.zkTxs = value;
    });
  }

  late final _$tokenZkTxsAtom =
      Atom(name: '_AssetsStore.tokenZkTxs', context: context);

  @override
  ObservableMap<String, List<TransferData>> get tokenZkTxs {
    _$tokenZkTxsAtom.reportRead();
    return super.tokenZkTxs;
  }

  @override
  set tokenZkTxs(ObservableMap<String, List<TransferData>> value) {
    _$tokenZkTxsAtom.reportWrite(value, super.tokenZkTxs, () {
      super.tokenZkTxs = value;
    });
  }

  late final _$txsFilterAtom =
      Atom(name: '_AssetsStore.txsFilter', context: context);

  @override
  int get txsFilter {
    _$txsFilterAtom.reportRead();
    return super.txsFilter;
  }

  @override
  set txsFilter(int value) {
    _$txsFilterAtom.reportWrite(value, super.txsFilter, () {
      super.txsFilter = value;
    });
  }

  late final _$tokenListAtom =
      Atom(name: '_AssetsStore.tokenList', context: context);

  @override
  ObservableList<Token> get tokenList {
    _$tokenListAtom.reportRead();
    return super.tokenList;
  }

  @override
  set tokenList(ObservableList<Token> value) {
    _$tokenListAtom.reportWrite(value, super.tokenList, () {
      super.tokenList = value;
    });
  }

  late final _$marketPricesAtom =
      Atom(name: '_AssetsStore.marketPrices', context: context);

  @override
  ObservableMap<String, double> get marketPrices {
    _$marketPricesAtom.reportRead();
    return super.marketPrices;
  }

  @override
  set marketPrices(ObservableMap<String, double> value) {
    _$marketPricesAtom.reportWrite(value, super.marketPrices, () {
      super.marketPrices = value;
    });
  }

  late final _$localHideTokenListAtom =
      Atom(name: '_AssetsStore.localHideTokenList', context: context);

  @override
  List<String> get localHideTokenList {
    _$localHideTokenListAtom.reportRead();
    return super.localHideTokenList;
  }

  @override
  set localHideTokenList(List<String> value) {
    _$localHideTokenListAtom.reportWrite(value, super.localHideTokenList, () {
      super.localHideTokenList = value;
    });
  }

  late final _$localShowedTokenIdsAtom =
      Atom(name: '_AssetsStore.localShowedTokenIds', context: context);

  @override
  List<String> get localShowedTokenIds {
    _$localShowedTokenIdsAtom.reportRead();
    return super.localShowedTokenIds;
  }

  @override
  set localShowedTokenIds(List<String> value) {
    _$localShowedTokenIdsAtom.reportWrite(value, super.localShowedTokenIds, () {
      super.localShowedTokenIds = value;
    });
  }

  late final _$nextTokenAtom =
      Atom(name: '_AssetsStore.nextToken', context: context);

  @override
  Token get nextToken {
    _$nextTokenAtom.reportRead();
    return super.nextToken;
  }

  @override
  set nextToken(Token value) {
    _$nextTokenAtom.reportWrite(value, super.nextToken, () {
      super.nextToken = value;
    });
  }

  late final _$setNextTokenAsyncAction =
      AsyncAction('_AssetsStore.setNextToken', context: context);

  @override
  Future<void> setNextToken(Token token) {
    return _$setNextTokenAsyncAction.run(() => super.setNextToken(token));
  }

  late final _$setAccountInfoAsyncAction =
      AsyncAction('_AssetsStore.setAccountInfo', context: context);

  @override
  Future<void> setAccountInfo(String pubKey, dynamic amt,
      {bool needCache = true}) {
    return _$setAccountInfoAsyncAction
        .run(() => super.setAccountInfo(pubKey, amt, needCache: needCache));
  }

  late final _$clearTxsAsyncAction =
      AsyncAction('_AssetsStore.clearTxs', context: context);

  @override
  Future<void> clearTxs() {
    return _$clearTxsAsyncAction.run(() => super.clearTxs());
  }

  late final _$clearZkTxsAsyncAction =
      AsyncAction('_AssetsStore.clearZkTxs', context: context);

  @override
  Future<void> clearZkTxs() {
    return _$clearZkTxsAsyncAction.run(() => super.clearZkTxs());
  }

  late final _$clearFeeTxsAsyncAction =
      AsyncAction('_AssetsStore.clearFeeTxs', context: context);

  @override
  Future<void> clearFeeTxs() {
    return _$clearFeeTxsAsyncAction.run(() => super.clearFeeTxs());
  }

  late final _$clearPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.clearPendingTxs', context: context);

  @override
  Future<void> clearPendingTxs() {
    return _$clearPendingTxsAsyncAction.run(() => super.clearPendingTxs());
  }

  late final _$clearPendingZkTxsAsyncAction =
      AsyncAction('_AssetsStore.clearPendingZkTxs', context: context);

  @override
  Future<void> clearPendingZkTxs() {
    return _$clearPendingZkTxsAsyncAction.run(() => super.clearPendingZkTxs());
  }

  late final _$clearAllTxsAsyncAction =
      AsyncAction('_AssetsStore.clearAllTxs', context: context);

  @override
  Future<void> clearAllTxs() {
    return _$clearAllTxsAsyncAction.run(() => super.clearAllTxs());
  }

  late final _$addPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.addPendingTxs', context: context);

  @override
  Future<void> addPendingTxs(List<dynamic>? ls, String address) {
    return _$addPendingTxsAsyncAction
        .run(() => super.addPendingTxs(ls, address));
  }

  late final _$addPendingZkTxsAsyncAction =
      AsyncAction('_AssetsStore.addPendingZkTxs', context: context);

  @override
  Future<void> addPendingZkTxs(List<dynamic>? ls, String address) {
    return _$addPendingZkTxsAsyncAction
        .run(() => super.addPendingZkTxs(ls, address));
  }

  late final _$addFeeTxsAsyncAction =
      AsyncAction('_AssetsStore.addFeeTxs', context: context);

  @override
  Future<void> addFeeTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) {
    return _$addFeeTxsAsyncAction
        .run(() => super.addFeeTxs(ls, address, shouldCache: shouldCache));
  }

  late final _$addTxsAsyncAction =
      AsyncAction('_AssetsStore.addTxs', context: context);

  @override
  Future<void> addTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) {
    return _$addTxsAsyncAction
        .run(() => super.addTxs(ls, address, shouldCache: shouldCache));
  }

  late final _$addZkTxsAsyncAction =
      AsyncAction('_AssetsStore.addZkTxs', context: context);

  @override
  Future<void> addZkTxs(List<dynamic> ls, String address, String tokenId,
      {bool shouldCache = false}) {
    return _$addZkTxsAsyncAction.run(
        () => super.addZkTxs(ls, address, tokenId, shouldCache: shouldCache));
  }

  late final _$setFeesMapAsyncAction =
      AsyncAction('_AssetsStore.setFeesMap', context: context);

  @override
  Future<void> setFeesMap(Map<String, double> fees) {
    return _$setFeesMapAsyncAction.run(() => super.setFeesMap(fees));
  }

  late final _$clearMarketPricesAsyncAction =
      AsyncAction('_AssetsStore.clearMarketPrices', context: context);

  @override
  Future<void> clearMarketPrices() {
    return _$clearMarketPricesAsyncAction.run(() => super.clearMarketPrices());
  }

  late final _$loadMultiAccountCacheAsyncAction =
      AsyncAction('_AssetsStore.loadMultiAccountCache', context: context);

  @override
  Future<void> loadMultiAccountCache() {
    return _$loadMultiAccountCacheAsyncAction
        .run(() => super.loadMultiAccountCache());
  }

  late final _$loadAccountCacheAsyncAction =
      AsyncAction('_AssetsStore.loadAccountCache', context: context);

  @override
  Future<void> loadAccountCache() {
    return _$loadAccountCacheAsyncAction.run(() => super.loadAccountCache());
  }

  late final _$loadMarketPricesCacheAsyncAction =
      AsyncAction('_AssetsStore.loadMarketPricesCache', context: context);

  @override
  Future<void> loadMarketPricesCache() {
    return _$loadMarketPricesCacheAsyncAction
        .run(() => super.loadMarketPricesCache());
  }

  late final _$loadFeesCacheAsyncAction =
      AsyncAction('_AssetsStore.loadFeesCache', context: context);

  @override
  Future<void> loadFeesCache() {
    return _$loadFeesCacheAsyncAction.run(() => super.loadFeesCache());
  }

  late final _$clearAccountCacheAsyncAction =
      AsyncAction('_AssetsStore.clearAccountCache', context: context);

  @override
  Future<void> clearAccountCache() {
    return _$clearAccountCacheAsyncAction.run(() => super.clearAccountCache());
  }

  late final _$loadCacheAsyncAction =
      AsyncAction('_AssetsStore.loadCache', context: context);

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  late final _$loadLocalScamListAsyncAction =
      AsyncAction('_AssetsStore.loadLocalScamList', context: context);

  @override
  Future<void> loadLocalScamList() {
    return _$loadLocalScamListAsyncAction.run(() => super.loadLocalScamList());
  }

  late final _$updateTokenShowStatusAsyncAction =
      AsyncAction('_AssetsStore.updateTokenShowStatus', context: context);

  @override
  Future<void> updateTokenShowStatus(String address,
      {required String tokenId}) {
    return _$updateTokenShowStatusAsyncAction
        .run(() => super.updateTokenShowStatus(address, tokenId: tokenId));
  }

  late final _$updateNewTokenConfigAsyncAction =
      AsyncAction('_AssetsStore.updateNewTokenConfig', context: context);

  @override
  Future<void> updateNewTokenConfig(String address) {
    return _$updateNewTokenConfigAsyncAction
        .run(() => super.updateNewTokenConfig(address));
  }

  late final _$updateTokenLocalConfigAsyncAction =
      AsyncAction('_AssetsStore.updateTokenLocalConfig', context: context);

  @override
  Future<void> updateTokenLocalConfig(String address,
      {bool shouldCache = false,
      required List<String> tokenShowedList,
      required List<String> hideTokenList}) {
    return _$updateTokenLocalConfigAsyncAction.run(() => super
        .updateTokenLocalConfig(address,
            shouldCache: shouldCache,
            tokenShowedList: tokenShowedList,
            hideTokenList: hideTokenList));
  }

  late final _$updateTokenAssetsAsyncAction =
      AsyncAction('_AssetsStore.updateTokenAssets', context: context);

  @override
  Future<void> updateTokenAssets(List<Token> ls, String address,
      {bool shouldCache = false}) {
    return _$updateTokenAssetsAsyncAction.run(
        () => super.updateTokenAssets(ls, address, shouldCache: shouldCache));
  }

  late final _$clearRuntimeTokensAsyncAction =
      AsyncAction('_AssetsStore.clearRuntimeTokens', context: context);

  @override
  Future<void> clearRuntimeTokens() {
    return _$clearRuntimeTokensAsyncAction
        .run(() => super.clearRuntimeTokens());
  }

  late final _$clearAllTokensAsyncAction =
      AsyncAction('_AssetsStore.clearAllTokens', context: context);

  @override
  Future<void> clearAllTokens() {
    return _$clearAllTokensAsyncAction.run(() => super.clearAllTokens());
  }

  late final _$clearAssestNodeCacheAsyncAction =
      AsyncAction('_AssetsStore.clearAssestNodeCache', context: context);

  @override
  Future<void> clearAssestNodeCache() {
    return _$clearAssestNodeCacheAsyncAction
        .run(() => super.clearAssestNodeCache());
  }

  late final _$clearAccountAssestCacheAsyncAction =
      AsyncAction('_AssetsStore.clearAccountAssestCache', context: context);

  @override
  Future<void> clearAccountAssestCache() {
    return _$clearAccountAssestCacheAsyncAction
        .run(() => super.clearAccountAssestCache());
  }

  late final _$_AssetsStoreActionController =
      ActionController(name: '_AssetsStore', context: context);

  @override
  List<TransferData> getTotalTxs(String tokenId) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.getTotalTxs');
    try {
      return super.getTotalTxs(tokenId);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<TransferData> getTotalPendingTxs(String tokenId) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.getTotalPendingTxs');
    try {
      return super.getTotalPendingTxs(tokenId);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAssetsLoading(bool isLoading) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setAssetsLoading');
    try {
      return super.setAssetsLoading(isLoading);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBalanceLoading(bool isLoading) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setBalanceLoading');
    try {
      return super.setBalanceLoading(isLoading);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMarketPrices(String tokenId, double price) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setMarketPrices');
    try {
      return super.setMarketPrices(tokenId, price);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLocalScamList(List<ScamItem> ls) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setLocalScamList');
    try {
      return super.setLocalScamList(ls);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isAssetsLoading: ${isAssetsLoading},
isBalanceLoading: ${isBalanceLoading},
accountsInfo: ${accountsInfo},
tokenBalances: ${tokenBalances},
transferFees: ${transferFees},
txsCount: ${txsCount},
pendingTxs: ${pendingTxs},
txs: ${txs},
feeTxs: ${feeTxs},
scamList: ${scamList},
scamAddressStr: ${scamAddressStr},
pendingZkTxs: ${pendingZkTxs},
zkTxs: ${zkTxs},
tokenZkTxs: ${tokenZkTxs},
txsFilter: ${txsFilter},
tokenList: ${tokenList},
marketPrices: ${marketPrices},
localHideTokenList: ${localHideTokenList},
localShowedTokenIds: ${localShowedTokenIds},
nextToken: ${nextToken},
newTokenCount: ${newTokenCount},
tokenTotalAmount: ${tokenTotalAmount},
mainTokenNetInfo: ${mainTokenNetInfo},
tokenShowList: ${tokenShowList}
    ''';
  }
}
