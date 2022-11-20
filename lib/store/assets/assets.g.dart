// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AssetsStore on _AssetsStore, Store {
  late final _$cacheTxsTimestampAtom =
      Atom(name: '_AssetsStore.cacheTxsTimestamp', context: context);

  @override
  int get cacheTxsTimestamp {
    _$cacheTxsTimestampAtom.reportRead();
    return super.cacheTxsTimestamp;
  }

  @override
  set cacheTxsTimestamp(int value) {
    _$cacheTxsTimestampAtom.reportWrite(value, super.cacheTxsTimestamp, () {
      super.cacheTxsTimestamp = value;
    });
  }

  late final _$isTxsLoadingAtom =
      Atom(name: '_AssetsStore.isTxsLoading', context: context);

  @override
  bool get isTxsLoading {
    _$isTxsLoadingAtom.reportRead();
    return super.isTxsLoading;
  }

  @override
  set isTxsLoading(bool value) {
    _$isTxsLoadingAtom.reportWrite(value, super.isTxsLoading, () {
      super.isTxsLoading = value;
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

  late final _$setAccountInfoAsyncAction =
      AsyncAction('_AssetsStore.setAccountInfo', context: context);

  @override
  Future<void> setAccountInfo(String pubKey, Map<dynamic, dynamic> amt,
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

  late final _$clearPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.clearPendingTxs', context: context);

  @override
  Future<void> clearPendingTxs() {
    return _$clearPendingTxsAsyncAction.run(() => super.clearPendingTxs());
  }

  late final _$addPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.addPendingTxs', context: context);

  @override
  Future<void> addPendingTxs(List<dynamic>? ls, String address) {
    return _$addPendingTxsAsyncAction
        .run(() => super.addPendingTxs(ls, address));
  }

  late final _$addTxsAsyncAction =
      AsyncAction('_AssetsStore.addTxs', context: context);

  @override
  Future<void> addTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) {
    return _$addTxsAsyncAction
        .run(() => super.addTxs(ls, address, shouldCache: shouldCache));
  }

  late final _$setFeesMapAsyncAction =
      AsyncAction('_AssetsStore.setFeesMap', context: context);

  @override
  Future<void> setFeesMap(Map<String, double> fees) {
    return _$setFeesMapAsyncAction.run(() => super.setFeesMap(fees));
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

  late final _$_AssetsStoreActionController =
      ActionController(name: '_AssetsStore', context: context);

  @override
  void setTxsLoading(bool isLoading) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setTxsLoading');
    try {
      return super.setTxsLoading(isLoading);
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
  void setMarketPrices(String token, double price) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setMarketPrices');
    try {
      return super.setMarketPrices(token, price);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cacheTxsTimestamp: ${cacheTxsTimestamp},
isTxsLoading: ${isTxsLoading},
isBalanceLoading: ${isBalanceLoading},
accountsInfo: ${accountsInfo},
tokenBalances: ${tokenBalances},
transferFees: ${transferFees},
txsCount: ${txsCount},
pendingTxs: ${pendingTxs},
txs: ${txs},
txsFilter: ${txsFilter},
marketPrices: ${marketPrices}
    ''';
  }
}
