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
  Computed<Token>? _$mainTokenNetInfoComputed;

  @override
  Token get mainTokenNetInfo => (_$mainTokenNetInfoComputed ??= Computed<Token>(
          () => super.mainTokenNetInfo,
          name: '_AssetsStore.mainTokenNetInfo'))
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

  late final _$tokenFullTxsAtom =
      Atom(name: '_AssetsStore.tokenFullTxs', context: context);

  @override
  ObservableMap<String, List<TransferData>> get tokenFullTxs {
    _$tokenFullTxsAtom.reportRead();
    return super.tokenFullTxs;
  }

  @override
  set tokenFullTxs(ObservableMap<String, List<TransferData>> value) {
    _$tokenFullTxsAtom.reportWrite(value, super.tokenFullTxs, () {
      super.tokenFullTxs = value;
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

  late final _$localHideTokenMapAtom =
      Atom(name: '_AssetsStore.localHideTokenMap', context: context);

  @override
  ObservableMap<String, dynamic> get localHideTokenMap {
    _$localHideTokenMapAtom.reportRead();
    return super.localHideTokenMap;
  }

  @override
  set localHideTokenMap(ObservableMap<String, dynamic> value) {
    _$localHideTokenMapAtom.reportWrite(value, super.localHideTokenMap, () {
      super.localHideTokenMap = value;
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

  late final _$tokenInfoListAtom =
      Atom(name: '_AssetsStore.tokenInfoList', context: context);

  @override
  List<TokenInfoData> get tokenInfoList {
    _$tokenInfoListAtom.reportRead();
    return super.tokenInfoList;
  }

  @override
  set tokenInfoList(List<TokenInfoData> value) {
    _$tokenInfoListAtom.reportWrite(value, super.tokenInfoList, () {
      super.tokenInfoList = value;
    });
  }

  late final _$tokenBuildTxListAtom =
      Atom(name: '_AssetsStore.tokenBuildTxList', context: context);

  @override
  ObservableMap<String, List<TransferData>> get tokenBuildTxList {
    _$tokenBuildTxListAtom.reportRead();
    return super.tokenBuildTxList;
  }

  @override
  set tokenBuildTxList(ObservableMap<String, List<TransferData>> value) {
    _$tokenBuildTxListAtom.reportWrite(value, super.tokenBuildTxList, () {
      super.tokenBuildTxList = value;
    });
  }

  late final _$tokenPendingTxListAtom =
      Atom(name: '_AssetsStore.tokenPendingTxList', context: context);

  @override
  ObservableMap<String, List<TokenPendingTx>> get tokenPendingTxList {
    _$tokenPendingTxListAtom.reportRead();
    return super.tokenPendingTxList;
  }

  @override
  set tokenPendingTxList(ObservableMap<String, List<TokenPendingTx>> value) {
    _$tokenPendingTxListAtom.reportWrite(value, super.tokenPendingTxList, () {
      super.tokenPendingTxList = value;
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

  late final _$addTokenBuildTxsAsyncAction =
      AsyncAction('_AssetsStore.addTokenBuildTxs', context: context);

  @override
  Future<void> addTokenBuildTxs(
      List<dynamic> ls, String address, String tokenAddress) {
    return _$addTokenBuildTxsAsyncAction
        .run(() => super.addTokenBuildTxs(ls, address, tokenAddress));
  }

  late final _$addTokenPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.addTokenPendingTxs', context: context);

  @override
  Future<void> addTokenPendingTxs(List<dynamic> ls, String address) {
    return _$addTokenPendingTxsAsyncAction
        .run(() => super.addTokenPendingTxs(ls, address));
  }

  late final _$addFullTxsAsyncAction =
      AsyncAction('_AssetsStore.addFullTxs', context: context);

  @override
  Future<void> addFullTxs(List<dynamic> ls, String address, String tokenId,
      {bool shouldCache = false}) {
    return _$addFullTxsAsyncAction.run(
        () => super.addFullTxs(ls, address, tokenId, shouldCache: shouldCache));
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

  late final _$loadTokenInfoCacheAsyncAction =
      AsyncAction('_AssetsStore.loadTokenInfoCache', context: context);

  @override
  Future<void> loadTokenInfoCache() {
    return _$loadTokenInfoCacheAsyncAction
        .run(() => super.loadTokenInfoCache());
  }

  late final _$loadTokenLocalConfigCacheAsyncAction =
      AsyncAction('_AssetsStore.loadTokenLocalConfigCache', context: context);

  @override
  Future<void> loadTokenLocalConfigCache() {
    return _$loadTokenLocalConfigCacheAsyncAction
        .run(() => super.loadTokenLocalConfigCache());
  }

  late final _$clearTokenLocalConfigCacheAsyncAction =
      AsyncAction('_AssetsStore.clearTokenLocalConfigCache', context: context);

  @override
  Future<void> clearTokenLocalConfigCache() {
    return _$clearTokenLocalConfigCacheAsyncAction
        .run(() => super.clearTokenLocalConfigCache());
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
  void updateNewTokenConfig(String address) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.updateNewTokenConfig');
    try {
      return super.updateNewTokenConfig(address);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTokenLocalConfig(String address,
      {bool shouldCache = false,
      required List<String> tokenShowedList,
      required Map<String, dynamic> hideTokenList}) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.updateTokenLocalConfig');
    try {
      return super.updateTokenLocalConfig(address,
          shouldCache: shouldCache,
          tokenShowedList: tokenShowedList,
          hideTokenList: hideTokenList);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTokenAssets(List<Token> ls, String address,
      {bool shouldCache = false}) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.updateTokenAssets');
    try {
      return super.updateTokenAssets(ls, address, shouldCache: shouldCache);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTokenInfoData(List<TokenInfoData> ls, {bool shouldCache = true}) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setTokenInfoData');
    try {
      return super.setTokenInfoData(ls, shouldCache: shouldCache);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isAssetsLoading: ${isAssetsLoading},
accountsInfo: ${accountsInfo},
transferFees: ${transferFees},
pendingTxs: ${pendingTxs},
scamList: ${scamList},
scamAddressStr: ${scamAddressStr},
pendingZkTxs: ${pendingZkTxs},
tokenFullTxs: ${tokenFullTxs},
tokenList: ${tokenList},
marketPrices: ${marketPrices},
localHideTokenMap: ${localHideTokenMap},
localShowedTokenIds: ${localShowedTokenIds},
nextToken: ${nextToken},
tokenInfoList: ${tokenInfoList},
tokenBuildTxList: ${tokenBuildTxList},
tokenPendingTxList: ${tokenPendingTxList},
newTokenCount: ${newTokenCount},
mainTokenNetInfo: ${mainTokenNetInfo}
    ''';
  }
}
