// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StakingStore on _StakingStore, Store {
  Computed<List<ValidatorData>>? _$allValidatorsComputed;

  @override
  List<ValidatorData> get allValidators =>
      (_$allValidatorsComputed ??= Computed<List<ValidatorData>>(
        () => super.allValidators,
        name: '_StakingStore.allValidators',
      )).value;

  late final _$validatorsInfoAtom = Atom(
    name: '_StakingStore.validatorsInfo',
    context: context,
  );

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

  late final _$inactiveValidatorsInfoAtom = Atom(
    name: '_StakingStore.inactiveValidatorsInfo',
    context: context,
  );

  @override
  List<ValidatorData> get inactiveValidatorsInfo {
    _$inactiveValidatorsInfoAtom.reportRead();
    return super.inactiveValidatorsInfo;
  }

  @override
  set inactiveValidatorsInfo(List<ValidatorData> value) {
    _$inactiveValidatorsInfoAtom.reportWrite(
      value,
      super.inactiveValidatorsInfo,
      () {
        super.inactiveValidatorsInfo = value;
      },
    );
  }

  late final _$overviewDataAtom = Atom(
    name: '_StakingStore.overviewData',
    context: context,
  );

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

  late final _$stakingAPRAtom = Atom(
    name: '_StakingStore.stakingAPR',
    context: context,
  );

  @override
  double? get stakingAPR {
    _$stakingAPRAtom.reportRead();
    return super.stakingAPR;
  }

  @override
  set stakingAPR(double? value) {
    _$stakingAPRAtom.reportWrite(value, super.stakingAPR, () {
      super.stakingAPR = value;
    });
  }

  late final _$lastLoadedDataKeyAtom = Atom(
    name: '_StakingStore.lastLoadedDataKey',
    context: context,
  );

  @override
  String? get lastLoadedDataKey {
    _$lastLoadedDataKeyAtom.reportRead();
    return super.lastLoadedDataKey;
  }

  @override
  set lastLoadedDataKey(String? value) {
    _$lastLoadedDataKeyAtom.reportWrite(value, super.lastLoadedDataKey, () {
      super.lastLoadedDataKey = value;
    });
  }

  late final _$pendingNavigationRouteAtom = Atom(
    name: '_StakingStore.pendingNavigationRoute',
    context: context,
  );

  @override
  String? get pendingNavigationRoute {
    _$pendingNavigationRouteAtom.reportRead();
    return super.pendingNavigationRoute;
  }

  @override
  set pendingNavigationRoute(String? value) {
    _$pendingNavigationRouteAtom.reportWrite(
      value,
      super.pendingNavigationRoute,
      () {
        super.pendingNavigationRoute = value;
      },
    );
  }

  late final _$cachedDelegationKeyAtom = Atom(
    name: '_StakingStore.cachedDelegationKey',
    context: context,
  );

  @override
  String? get cachedDelegationKey {
    _$cachedDelegationKeyAtom.reportRead();
    return super.cachedDelegationKey;
  }

  @override
  set cachedDelegationKey(String? value) {
    _$cachedDelegationKeyAtom.reportWrite(value, super.cachedDelegationKey, () {
      super.cachedDelegationKey = value;
    });
  }

  late final _$cachedDelegationOwnerAtom = Atom(
    name: '_StakingStore.cachedDelegationOwner',
    context: context,
  );

  @override
  String? get cachedDelegationOwner {
    _$cachedDelegationOwnerAtom.reportRead();
    return super.cachedDelegationOwner;
  }

  @override
  set cachedDelegationOwner(String? value) {
    _$cachedDelegationOwnerAtom.reportWrite(
      value,
      super.cachedDelegationOwner,
      () {
        super.cachedDelegationOwner = value;
      },
    );
  }

  late final _$cachedDelegationNetworkAtom = Atom(
    name: '_StakingStore.cachedDelegationNetwork',
    context: context,
  );

  @override
  String? get cachedDelegationNetwork {
    _$cachedDelegationNetworkAtom.reportRead();
    return super.cachedDelegationNetwork;
  }

  @override
  set cachedDelegationNetwork(String? value) {
    _$cachedDelegationNetworkAtom.reportWrite(
      value,
      super.cachedDelegationNetwork,
      () {
        super.cachedDelegationNetwork = value;
      },
    );
  }

  late final _$initAsyncAction = AsyncAction(
    '_StakingStore.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$loadCacheAsyncAction = AsyncAction(
    '_StakingStore.loadCache',
    context: context,
  );

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  late final _$_StakingStoreActionController = ActionController(
    name: '_StakingStore',
    context: context,
  );

  @override
  void setOverviewInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.setOverviewInfo',
    );
    try {
      return super.setOverviewInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStakingAPR(double apr, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.setStakingAPR',
    );
    try {
      return super.setStakingAPR(apr, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearStakingAPR() {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.clearStakingAPR',
    );
    try {
      return super.clearStakingAPR();
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearOverviewData() {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.clearOverviewData',
    );
    try {
      return super.clearOverviewData();
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAccountSpecificData() {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.clearAccountSpecificData',
    );
    try {
      return super.clearAccountSpecificData();
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDelegationCache(
    String? delegationKey,
    String ownerAddress,
    String networkID, {
    bool shouldCache = true,
  }) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.setDelegationCache',
    );
    try {
      return super.setDelegationCache(
        delegationKey,
        ownerAddress,
        networkID,
        shouldCache: shouldCache,
      );
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValidatorsInfo(
    List<Map<String, dynamic>> activeData,
    List<Map<String, dynamic>> inactiveData, {
    bool shouldCache = true,
  }) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
      name: '_StakingStore.setValidatorsInfo',
    );
    try {
      return super.setValidatorsInfo(
        activeData,
        inactiveData,
        shouldCache: shouldCache,
      );
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
validatorsInfo: ${validatorsInfo},
inactiveValidatorsInfo: ${inactiveValidatorsInfo},
overviewData: ${overviewData},
stakingAPR: ${stakingAPR},
lastLoadedDataKey: ${lastLoadedDataKey},
pendingNavigationRoute: ${pendingNavigationRoute},
cachedDelegationKey: ${cachedDelegationKey},
cachedDelegationOwner: ${cachedDelegationOwner},
cachedDelegationNetwork: ${cachedDelegationNetwork},
allValidators: ${allValidators}
    ''';
  }
}
