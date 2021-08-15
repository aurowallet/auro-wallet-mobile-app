// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetsStore on _AssetsStore, Store {
  final _$cacheTxsTimestampAtom = Atom(name: '_AssetsStore.cacheTxsTimestamp');

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

  final _$isTxsLoadingAtom = Atom(name: '_AssetsStore.isTxsLoading');

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

  final _$submittingAtom = Atom(name: '_AssetsStore.submitting');

  @override
  bool get submitting {
    _$submittingAtom.reportRead();
    return super.submitting;
  }

  @override
  set submitting(bool value) {
    _$submittingAtom.reportWrite(value, super.submitting, () {
      super.submitting = value;
    });
  }

  final _$accountsInfoAtom = Atom(name: '_AssetsStore.accountsInfo');

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

  final _$tokenBalancesAtom = Atom(name: '_AssetsStore.tokenBalances');

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

  final _$transferFeesAtom = Atom(name: '_AssetsStore.transferFees');

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

  final _$txsCountAtom = Atom(name: '_AssetsStore.txsCount');

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

  final _$pendingTxsAtom = Atom(name: '_AssetsStore.pendingTxs');

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

  final _$txsAtom = Atom(name: '_AssetsStore.txs');

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

  final _$txsFilterAtom = Atom(name: '_AssetsStore.txsFilter');

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

  final _$marketPricesAtom = Atom(name: '_AssetsStore.marketPrices');

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

  final _$setAccountInfoAsyncAction =
      AsyncAction('_AssetsStore.setAccountInfo');

  @override
  Future<void> setAccountInfo(String pubKey, Map<dynamic, dynamic> amt,
      {bool needCache = true}) {
    return _$setAccountInfoAsyncAction
        .run(() => super.setAccountInfo(pubKey, amt, needCache: needCache));
  }

  final _$clearTxsAsyncAction = AsyncAction('_AssetsStore.clearTxs');

  @override
  Future<void> clearTxs() {
    return _$clearTxsAsyncAction.run(() => super.clearTxs());
  }

  final _$clearPendingTxsAsyncAction =
      AsyncAction('_AssetsStore.clearPendingTxs');

  @override
  Future<void> clearPendingTxs() {
    return _$clearPendingTxsAsyncAction.run(() => super.clearPendingTxs());
  }

  final _$addPendingTxsAsyncAction = AsyncAction('_AssetsStore.addPendingTxs');

  @override
  Future<void> addPendingTxs(List<dynamic>? ls, String address) {
    return _$addPendingTxsAsyncAction
        .run(() => super.addPendingTxs(ls, address));
  }

  final _$addTxsAsyncAction = AsyncAction('_AssetsStore.addTxs');

  @override
  Future<void> addTxs(List<dynamic> ls, String address,
      {bool shouldCache = false}) {
    return _$addTxsAsyncAction
        .run(() => super.addTxs(ls, address, shouldCache: shouldCache));
  }

  final _$setFeesMapAsyncAction = AsyncAction('_AssetsStore.setFeesMap');

  @override
  Future<void> setFeesMap(Map<String, double> fees) {
    return _$setFeesMapAsyncAction.run(() => super.setFeesMap(fees));
  }

  final _$loadAccountCacheAsyncAction =
      AsyncAction('_AssetsStore.loadAccountCache');

  @override
  Future<void> loadAccountCache() {
    return _$loadAccountCacheAsyncAction.run(() => super.loadAccountCache());
  }

  final _$loadCacheAsyncAction = AsyncAction('_AssetsStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_AssetsStoreActionController = ActionController(name: '_AssetsStore');

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
  void setSubmitting(bool isSubmitting) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction(
        name: '_AssetsStore.setSubmitting');
    try {
      return super.setSubmitting(isSubmitting);
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
submitting: ${submitting},
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
