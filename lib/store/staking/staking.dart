import 'package:auro_wallet/store/staking/types/delegatedValidator.dart';
import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'dart:convert';
import 'package:auro_wallet/utils/localStorage.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(AppStore store) : super(store);
}

abstract class _StakingStore with Store {
  _StakingStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageValidatorsKey = 'validator_list';
  final String localStorageOverviewKey = 'staking_overview';
  final String localStorageDelegatedValidatorKey = 'delegated_validator_detail';

  @observable
  List<ValidatorData> validatorsInfo = [];

  @observable
  OverviewData overviewData = OverviewData();
  @observable
  DelegatedValidator? delegatedValidator;

  @action
  Future<void> init() async {
    await loadCache();
  }
  @action
  void setOverviewInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    overviewData = OverviewData.fromJson(data);
    // cache data
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageOverviewKey, data);
    }
  }

  @action
  void setDelegatedInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    delegatedValidator = DelegatedValidator.fromJson(data);
    // cache data
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageDelegatedValidatorKey, data);
    }
  }

  @action
  void setValidatorsInfo(List<Map<String, dynamic>> data, {bool shouldCache = true}) {
    List<ValidatorData> ls = [];
    data.forEach((i) {
      ValidatorData data = ValidatorData.fromJson(i);
      ls.add(data);
    });
    validatorsInfo = ls;
    // cache data
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageValidatorsKey, ls.map((i)=>ValidatorData.toJson(i)).toList());
    }
  }

  @action
  Future<void> loadCache() async {
    List cacheOverview = await Future.wait([
      rootStore.localStorage.getObject(localStorageValidatorsKey),
      rootStore.localStorage.getObject(localStorageOverviewKey),
      rootStore.localStorage.getObject(localStorageDelegatedValidatorKey),
    ]);
    if (cacheOverview[0] != null) {
      List<dynamic> accList = cacheOverview[0];
      validatorsInfo = ObservableList.of(accList.map((i) => ValidatorData.fromJson(i as Map<String, dynamic>)));
    }
    if (cacheOverview[1] != null) {
      setOverviewInfo(cacheOverview[1], shouldCache: false);
    }
    if (cacheOverview[3] != null) {
      setOverviewInfo(cacheOverview[1], shouldCache: false);
    }
  }
}