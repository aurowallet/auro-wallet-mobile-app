// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StakingStore on _StakingStore, Store {
  final _$validatorsInfoAtom = Atom(name: '_StakingStore.validatorsInfo');

  @override
  List<ValidatorData> get validatorsInfo {
    _$validatorsInfoAtom.reportRead();
    return super.validatorsInfo;
  }

  @override
  set validatorsInfo(List<ValidatorData> value) {
    _$validatorsInfoAtom.reportWrite(value, super.validatorsInfo, () {
      super.validatorsInfo = value;
    });
  }

  final _$overviewDataAtom = Atom(name: '_StakingStore.overviewData');

  @override
  OverviewData get overviewData {
    _$overviewDataAtom.reportRead();
    return super.overviewData;
  }

  @override
  set overviewData(OverviewData value) {
    _$overviewDataAtom.reportWrite(value, super.overviewData, () {
      super.overviewData = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_StakingStore.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$loadCacheAsyncAction = AsyncAction('_StakingStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_StakingStoreActionController =
      ActionController(name: '_StakingStore');

  @override
  void setOverviewInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setOverviewInfo');
    try {
      return super.setOverviewInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidatorsInfo(List<Map<String, dynamic>> data,
      {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setValidatorsInfo');
    try {
      return super.setValidatorsInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
validatorsInfo: ${validatorsInfo},
overviewData: ${overviewData}
    ''';
  }
}
