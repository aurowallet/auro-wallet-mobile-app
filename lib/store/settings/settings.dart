import 'package:auro_wallet/store/settings/types/customNode.dart';
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
    String? value = await localStorage.getObject(localStorageEndpointKeyForGlobal) as String?;
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
  final String localStorageAboutUsKey = 'about_us';
  final String localStorageCustomNodes = 'custom_node_list';
  final String localStorageCustomNodesV2 = 'custom_node_list_v2';

  final String cacheNetworkStateKey = 'network';
  final String cacheNetworkConstKey = 'network_const';


  @observable
  bool loading = true;

  @observable
  String localeCode = '';

  @observable
  String currencyCode = 'usd';

  @observable
  String endpoint = '';

  bool get isDefaultNode {
    return GRAPH_QL_MAINNET_NODE_URL == endpoint || GRAPH_QL_TESTNET_NODE_URL == endpoint;
  }

  bool get isSupportedNode {
    if( GRAPH_QL_MAINNET_NODE_URL == endpoint || GRAPH_QL_TESTNET_NODE_URL == endpoint) {
      return true;
    }
    final targetNets = customNodeListV2.where((element) => element.url == endpoint);
    if (targetNets.isNotEmpty) {
      final targetNet = customNodeListV2.first;
      if (targetNet.networksType == '0'  || targetNet.networksType == '1') {
        return true;
      }
    }
    return false;
  }

  bool get isMainnet {
    if(GRAPH_QL_MAINNET_NODE_URL == endpoint) {
      return true;
    }
    final targetNets = customNodeListV2.where((element) => element.url == endpoint);
    if (targetNets.isNotEmpty) {
      final targetNet = customNodeListV2.first;
      if (targetNet.networksType == '0') {
        return true;
      }
    }
    return false;
  }

  @observable
  AboutUsData? aboutus;


  @observable
  List<String> customNodeList = [];

  @observable
  List<CustomNode> customNodeListV2 = [];

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
    await loadEndpoint();
    await loadAboutUs();
    await loadCustomNodeList();
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
  Future<void> setNetworkTypes(List<NetworkType> networkTypes, {shouldCache = false}) async {
    networks = networkTypes;
    if (shouldCache) { // cache data
      await rootStore.localStorage.setObject(localStorageNetworksKey, networks.map((i)=>i.toJson()).toList());
    }
  }

  @action
  Future<void> loadNetworkTypes() async {
    List<dynamic>? netList = await rootStore.localStorage.getObject(localStorageNetworksKey) as List<dynamic>?;
    if (netList != null) {
      try {
        networks = ObservableList.of(netList.map((i) => NetworkType.fromJson(i as Map<String, dynamic>)));
      } catch (e) {
        print('loadNetworkTypes failed');
        print(e);
      }
    }
  }

  @action
  Future<void> loadLocalCode() async {
    String? stored = await rootStore.localStorage.getObject(localStorageLocaleKey) as String?;
    if (stored != null) {
      localeCode = stored;
    }
  }

  @action
  Future<void> loadCurrencyCode() async {
    String? stored = await rootStore.localStorage.getObject(localStorageCurrencyKey) as String?;
    if (stored != null) {
      currencyCode = stored;
    }
  }
  @action
  Future<void> updateCustomNode(CustomNode newNode,CustomNode oldNode) async {
    var target = customNodeListV2.toList().firstWhere((element) => element.url == oldNode.url);
    target.name = newNode.name;
    target.url = newNode.url;
    target.chainId = newNode.chainId;
    target.networksType = newNode.networksType;
    setCustomNodeList(customNodeListV2);
  }
  @action
  Future<void> setCustomNodeList(List<CustomNode> nodeList) async {
    customNodeListV2 = nodeList;
    await rootStore.localStorage.setObject(localStorageCustomNodesV2, nodeList);
  }

  @action
  Future<void> loadCustomNodeList() async {
    try{
      List<dynamic>? stored = await rootStore.localStorage.getObject(localStorageCustomNodesV2) as List<dynamic>?;
      if (stored != null) {
        customNodeListV2 = stored.map((s) => CustomNode.fromJson(s)).toList();
      }
    } catch(e){
      print('loadCustomNodeList faield');
      print(e);
    }
  }

  @action
  void setNetworkLoading(bool isLoading) {
    loading = isLoading;
  }

  @action
  Future<void> setEndpoint(String value) async {
    endpoint = value;
    await rootStore.localStorage.setObject(localStorageEndpointKey, value);
  }


  @action
  Future<void> loadEndpoint() async {
    String? value = await rootStore.localStorage.getObject(localStorageEndpointKey) as String?;
    if (value == null) {
      endpoint = GRAPH_QL_MAINNET_NODE_URL;
    } else {
      endpoint = value;
    }
  }
  
  @action
  void setAboutUs(AboutUsData value) {
    aboutus = value;
    rootStore.localStorage
        .setObject(localStorageAboutUsKey, value.toJson());
  }
  
  Future<void> loadAboutUs() async {
    Map<String, dynamic>? value = await rootStore.localStorage.getObject(localStorageAboutUsKey) as Map<String, dynamic>?;
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
    List<Map<String, dynamic>> ls = await rootStore.localStorage.getContactList();
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
  AboutUsData({required this.changelog, required this.gitReponame, required this.followus});

  factory AboutUsData.fromJson(Map<String, dynamic> json) =>
      _$AboutUsDataFromJson(json);
   Map<String, dynamic> toJson() =>
      _$AboutUsDataToJson(this);
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
  String privacyPolicyZH= '';

  @JsonKey(name: 'staking_guide')
  String stakingGuide = '';

  @JsonKey(name: 'graphql_api')
  String? graphqlApi = '';

  List<FollowUsData?> followus = [];
  FollowUsData? get wechat {
    return followus.firstWhere((element) => element!.name == 'wechat', orElse: () => null);
  }
  FollowUsData? get telegram {
    return followus.firstWhere((element) => element!.name == 'telegram', orElse: () => null);
  }
  FollowUsData? get twitter {
    return followus.firstWhere((element) => element!.name == 'twitter', orElse: () => null);
  }
  FollowUsData? get website {
    return followus.firstWhere((element) => element!.name == 'website', orElse: () => null);
  }
}

@JsonSerializable()
class FollowUsData {
  String website = '';
  String name = '';
  FollowUsData({required this.website,required this.name});
  factory FollowUsData.fromJson(Map<String, dynamic> json) =>
      _$FollowUsDataFromJson(json);
   Map<String, dynamic> toJson() =>
      _$FollowUsDataToJson(this);
}