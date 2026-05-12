import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/types/overviewData.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:mobx/mobx.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(AppStore store) : super(store);
}

abstract class _StakingStore with Store {
  _StakingStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageValidatorsV2Key = 'validators_v2';
  final String localStorageOverviewKey = 'staking_overview';
  final String localStorageStakingAPRKey = 'staking_apr';
  final String localStorageDelegationCacheKey = 'delegation_cache';

  @observable
  List<ValidatorData> validatorsInfo = [];

  @observable
  List<ValidatorData> inactiveValidatorsInfo = [];

  @observable
  OverviewData overviewData = OverviewData();

  @observable
  double? stakingAPR;

  /// Track the last loaded account/network key to avoid unnecessary loading
  @observable
  String? lastLoadedDataKey;

  /// Pending navigation route after staking completes
  @observable
  String? pendingNavigationRoute;

  @observable
  String? cachedDelegationKey;

  @observable
  String? cachedDelegationOwner;

  @observable
  String? cachedDelegationNetwork;

  @computed
  List<ValidatorData> get allValidators => [...validatorsInfo, ...inactiveValidatorsInfo];

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
  void setStakingAPR(double apr, {bool shouldCache = true}) {
    stakingAPR = apr;
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageStakingAPRKey, apr);
    }
  }

  @action
  void clearStakingAPR() {
    stakingAPR = null;
  }

  @action
  void clearOverviewData() {
    overviewData = OverviewData();
  }

  /// Clear all data that is specific to an account/network
  @action
  void clearAccountSpecificData() {
    overviewData = OverviewData();
    // Don't clear validators as they are network-wide, not account-specific
  }

  @action
  void setDelegationCache(String? delegationKey, String ownerAddress, String networkID, {bool shouldCache = true}) {
    cachedDelegationKey = delegationKey;
    cachedDelegationOwner = ownerAddress;
    cachedDelegationNetwork = networkID;
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageDelegationCacheKey, {
        'key': delegationKey,
        'owner': ownerAddress,
        'network': networkID,
      });
    }
  }

  /// Get cached delegation key if cache is valid for current account and network
  String? getValidDelegationKey(String currentAddress, String currentNetworkID) {
    if (cachedDelegationOwner == currentAddress && cachedDelegationNetwork == currentNetworkID) {
      return cachedDelegationKey;
    }
    return null;
  }

  /// Check if delegation cache is valid for current account and network
  bool isDelegationCacheValid(String currentAddress, String currentNetworkID) {
    return cachedDelegationOwner == currentAddress && cachedDelegationNetwork == currentNetworkID;
  }

  @action
  void setValidatorsInfo(List<Map<String, dynamic>> activeData, List<Map<String, dynamic>> inactiveData, {bool shouldCache = true}) {
    List<ValidatorData> activeList = [];
    activeData.forEach((i) {
      ValidatorData data = ValidatorData.fromJson(i);
      activeList.add(data);
    });
    validatorsInfo = activeList;

    List<ValidatorData> inactiveList = [];
    inactiveData.forEach((i) {
      ValidatorData data = ValidatorData.fromJson(i);
      inactiveList.add(data);
    });
    inactiveValidatorsInfo = inactiveList;

    // cache data with combined structure
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageValidatorsV2Key, {
        'active': activeList.map((i) => ValidatorData.toJson(i)).toList(),
        'inactive': inactiveList.map((i) => ValidatorData.toJson(i)).toList(),
      });
    }
  }

  @action
  Future<void> loadCache() async {
    List cacheData = await Future.wait([
      rootStore.localStorage.getObject(localStorageValidatorsV2Key),
      rootStore.localStorage.getObject(localStorageOverviewKey),
      rootStore.localStorage.getObject(localStorageStakingAPRKey),
      rootStore.localStorage.getObject(localStorageDelegationCacheKey),
    ]);
    if (cacheData[0] != null) {
      // Only load cached validators if on mainnet to avoid showing stale data
      if (rootStore.settings?.isMainnet == true) {
        Map<String, dynamic> validatorsData = cacheData[0] as Map<String, dynamic>;
        if (validatorsData['active'] != null) {
          List<dynamic> activeList = validatorsData['active'];
          validatorsInfo = ObservableList.of(activeList.map((i) => ValidatorData.fromJson(i as Map<String, dynamic>)));
        }
        if (validatorsData['inactive'] != null) {
          List<dynamic> inactiveList = validatorsData['inactive'];
          inactiveValidatorsInfo = ObservableList.of(inactiveList.map((i) => ValidatorData.fromJson(i as Map<String, dynamic>)));
        }
      }
    }
    if (cacheData[1] != null) {
      setOverviewInfo(cacheData[1], shouldCache: false);
    }
    final cachedApr = cacheData[2];
    if (cachedApr != null) {
      // Only load cached APR if on mainnet to avoid showing stale mainnet data.
      if (rootStore.settings?.isMainnet == true) {
        stakingAPR = (cachedApr as num).toDouble();
      }
    }
    if (cacheData[3] != null) {
      Map<String, dynamic> delegationCache = cacheData[3] as Map<String, dynamic>;
      cachedDelegationKey = delegationCache['key'] as String?;
      cachedDelegationOwner = delegationCache['owner'] as String?;
      cachedDelegationNetwork = delegationCache['network'] as String?;
    }
  }
}
