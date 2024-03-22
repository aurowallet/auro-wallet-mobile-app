import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'dart:convert';
import 'package:auro_wallet/utils/localStorage.dart';

part 'settings.g.dart';

class SettingsStore extends _SettingsStore with _$SettingsStore {
  SettingsStore(AppStore store) : super(store);

  static final String localStorageEndpointKeyForGlobal = 'endpoint';

  static Future<String> loadEndpointGlobally() async {
    LocalStorage localStorage = LocalStorage();
    String? value = await localStorage
        .getObject(localStorageEndpointKeyForGlobal) as String?;
    if (value == null) {
      return GRAPH_QL_MAINNET_NODE_URL;
    } else {
      return value;
    }
  }
}

abstract class _SettingsStore with Store {
  _SettingsStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageLocaleKey = 'locale';
  final String localStorageCurrencyKey = 'currency';
  final String localStorageNetworksKey = 'network_types';
  final String localStorageEndpointKey = 'endpoint';
  final String localStorageCurrentNodeKey = 'currentNode';
  final String localStorageAboutUsKey = 'about_us';
  final String localStorageCustomNodes = 'custom_node_list';
  final String localStorageCustomNodesV2 = 'custom_node_list_v2';
  final String localStorageCustomNodesV3 = 'custom_node_list_v3';
  final String localStorageCurrentNodeKeyV3 = 'currentNode_V3';

  final String cacheNetworkStateKey = 'network';
  final String cacheNetworkConstKey = 'network_const';

  @observable
  bool loading = true;

  @observable
  String localeCode = '';

  @observable
  String currencyCode = 'usd';

  @observable
  CustomNodeV2? currentNode;

  bool get isSupportedNode {
    if (currentNode?.id == '0' ||
        currentNode?.id == '1' ||
        currentNode?.id == '11') {
      return true;
    }
    return false;
    // if (GRAPH_QL_MAINNET_NODE_URL == endpoint ||
    //     GRAPH_QL_TESTNET_NODE_URL == endpoint) {
    //   return true;
    // }
    // final targetNets =
    //     customNodeListV2.where((element) => element.url == endpoint);
    // if (targetNets.isNotEmpty) {
    //   final targetNet = targetNets.first;
    //   if (targetNet.networksType == '0' || targetNet.networksType == '1') {
    //     return true;
    //   }
    // }
    // return false;
  }

  bool get isMainnet {
    return currentNode?.id == '0';
    // if (GRAPH_QL_MAINNET_NODE_URL == endpoint) {
    //   return true;
    // }
    // final targetNets =
    //     customNodeListV2.where((element) => element.url == endpoint);
    // if (targetNets.isNotEmpty) {
    //   final targetNet = targetNets.first;
    //   if (targetNet.networksType == '0') {
    //     return true;
    //   }
    // }
    // return false;
  }

  @observable
  AboutUsData? aboutus;

  @observable
  List<String> customNodeList = [];

  List<CustomNodeV2> get allNodes {
    return [
      netConfigMap[NetworkTypes.mainnet]!,
      netConfigMap[NetworkTypes.devnet]!,
      netConfigMap[NetworkTypes.berkeley]!,
      ...customNodeListV2
    ];
  }

  @observable
  List<CustomNodeV2> customNodeListV2 = [];

  @observable
  List<NetworkType> networks = [];

  @observable
  String networkName = '';

  @observable
  Map networkConst = Map();

  @observable
  ObservableList<ContactData> contactList = ObservableList<ContactData>();

  @action
  Future<void> init() async {
    await loadLocalCode();
    await loadCurrencyCode();
    await loadCustomNodeList();
    await loadCurrentNode();
    await loadAboutUs();
    await loadNetworkTypes();
    await loadContacts();
  }

  @action
  Future<void> setLocalCode(String code) async {
    await rootStore.localStorage.setObject(localStorageLocaleKey, code);
    localeCode = code;
  }

  @action
  Future<void> setCurrencyCode(String code) async {
    await rootStore.localStorage.setObject(localStorageCurrencyKey, code);
    currencyCode = code;
  }

  @action
  Future<void> setNetworkTypes(List<NetworkType> networkTypes,
      {shouldCache = false}) async {
    networks = networkTypes;
    if (shouldCache) {
      // cache data
      await rootStore.localStorage.setObject(
          localStorageNetworksKey, networks.map((i) => i.toJson()).toList());
    }
  }

  @action
  Future<void> loadNetworkTypes() async {
    List<dynamic>? netList = await rootStore.localStorage
        .getObject(localStorageNetworksKey) as List<dynamic>?;
    if (netList != null) {
      try {
        networks = ObservableList.of(netList
            .map((i) => NetworkType.fromJson(i as Map<String, dynamic>)));
      } catch (e) {
        print('loadNetworkTypes failed');
        print(e);
      }
    }
  }

  @action
  Future<void> loadLocalCode() async {
    String? stored = await rootStore.localStorage
        .getObject(localStorageLocaleKey) as String?;
    if (stored != null) {
      localeCode = stored;
    }
  }

  @action
  Future<void> loadCurrencyCode() async {
    String? stored = await rootStore.localStorage
        .getObject(localStorageCurrencyKey) as String?;
    if (stored != null) {
      currencyCode = stored;
    }
  }

  @action
  Future<void> updateCustomNode(
      CustomNodeV2 newNode, CustomNodeV2 oldNode) async {
    int index =
        customNodeListV2.indexWhere((element) => element.url == oldNode.url);

    if (index != -1) {
      customNodeListV2[index] = newNode;
    }
    setCustomNodeList(customNodeListV2);
  }

  @action
  Future<void> setCustomNodeList(List<CustomNodeV2> nodeList) async {
    customNodeListV2 = nodeList;
    await rootStore.localStorage.setObject(localStorageCustomNodesV3, nodeList);
  }

  @action
  Future<void> loadCustomNodeList() async {
    try {
      List<dynamic>? stored = await rootStore.localStorage
          .getObject(localStorageCustomNodesV3) as List<dynamic>?;
      if (stored != null) {
        customNodeListV2 = stored.map((s) => CustomNodeV2.fromJson(s)).toList();
      }
    } catch (e) {
      print('loadCustomNodeList faield');
      print(e);
    }
  }

  @action
  void setNetworkLoading(bool isLoading) {
    loading = isLoading;
  }

  @action
  Future<void> setCurrentNode(CustomNodeV2 value) async {
    currentNode = value;
    await rootStore.localStorage.setObject(localStorageCurrentNodeKeyV3, value);
  }

  @action
  Future<void> loadCurrentNode() async {
    String? endpoint = await rootStore.localStorage
        .getObject(localStorageEndpointKey) as String?;
    Map<String, dynamic>? value = await rootStore.localStorage
        .getObject(localStorageCurrentNodeKeyV3) as Map<String, dynamic>?;
    if (value == null) {
      if (endpoint != null) {
        if (endpoint == GRAPH_QL_MAINNET_NODE_URL) {
          currentNode = netConfigMap[NetworkTypes.mainnet]!;
        } else if (endpoint == GRAPH_QL_TESTNET_NODE_URL) {
          currentNode = netConfigMap[NetworkTypes.devnet]!;
        } else if (endpoint == GRAPH_QL_BERKELEY_NODE_URL) {
          currentNode = netConfigMap[NetworkTypes.berkeley]!;
        } else {
          final customNodes =
              customNodeListV2.where((element) => element.url == endpoint);
          if (customNodes.length > 0) {
            currentNode = customNodes.first;
          } else {
            currentNode = netConfigMap[NetworkTypes.mainnet]!;
          }
        }
      } else {
        currentNode = netConfigMap[NetworkTypes.mainnet]!;
      }
    } else {
      currentNode = CustomNodeV2.fromJson(value);
    }
  }

  @action
  void setAboutUs(AboutUsData value) {
    aboutus = value;
    rootStore.localStorage.setObject(localStorageAboutUsKey, value.toJson());
  }

  Future<void> loadAboutUs() async {
    Map<String, dynamic>? value = await rootStore.localStorage
        .getObject(localStorageAboutUsKey) as Map<String, dynamic>?;
    if (value != null) {
      try {
        aboutus = AboutUsData.fromJson(value);
      } catch (e) {
        print('load about us data failed');
      }
    }
  }

  @action
  Future<void> loadContacts() async {
    List<Map<String, dynamic>> ls =
        await rootStore.localStorage.getContactList();
    try {
      contactList = ObservableList.of(ls.map((i) => ContactData.fromJson(i)));
    } catch (e) {
      print('loadContacts failed');
      print(e);
    }
  }

  @action
  Future<void> addContact(Map<String, dynamic> con) async {
    await rootStore.localStorage.addContact(con);
    await loadContacts();
  }

  @action
  Future<void> removeContact(ContactData con) async {
    await rootStore.localStorage.removeContact(con.address);
    loadContacts();
  }

  @action
  Future<void> updateContact(ContactData contact, String address) async {
    await rootStore.localStorage.updateContact(contact.toJson(), address);
    loadContacts();
  }
}

@JsonSerializable()
class AboutUsData {
  AboutUsData(
      {required this.changelog,
      required this.gitReponame,
      required this.followus});

  factory AboutUsData.fromJson(Map<String, dynamic> json) =>
      _$AboutUsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AboutUsDataToJson(this);
  @JsonKey(name: 'changelog_app')
  String changelog = '';

  @JsonKey(name: 'gitReponame_app')
  String gitReponame = '';

  @JsonKey(name: 'staking_guide_cn')
  String stakingGuideCN = '';

  @JsonKey(name: 'terms_and_contions')
  String termsAndContionsEN = '';

  @JsonKey(name: 'privacy_policy')
  String privacyPolicyEN = '';

  @JsonKey(name: 'terms_and_contions_cn')
  String termsAndContionsZH = '';

  @JsonKey(name: 'privacy_policy_cn')
  String privacyPolicyZH = '';

  @JsonKey(name: 'staking_guide')
  String stakingGuide = '';

  @JsonKey(name: 'graphql_api')
  String? graphqlApi = '';

  List<FollowUsData?> followus = [];

  FollowUsData? get wechat {
    return followus.firstWhere((element) => element!.name == 'wechat',
        orElse: () => null);
  }

  FollowUsData? get telegram {
    return followus.firstWhere((element) => element!.name == 'telegram',
        orElse: () => null);
  }

  FollowUsData? get twitter {
    return followus.firstWhere((element) => element!.name == 'twitter',
        orElse: () => null);
  }

  FollowUsData? get website {
    return followus.firstWhere((element) => element!.name == 'website',
        orElse: () => null);
  }
}

@JsonSerializable()
class FollowUsData {
  String website = '';
  String name = '';

  FollowUsData({required this.website, required this.name});

  factory FollowUsData.fromJson(Map<String, dynamic> json) =>
      _$FollowUsDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUsDataToJson(this);
}
