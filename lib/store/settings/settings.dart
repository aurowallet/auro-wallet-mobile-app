import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'settings.g.dart';

class SettingsStore extends _SettingsStore with _$SettingsStore {
  SettingsStore(AppStore store) : super(store);
}

abstract class _SettingsStore with Store {
  _SettingsStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageLocaleKey = 'locale';
  final String localStorageCurrencyKey = 'currency';
  final String localStorageAboutUsKey = 'about_us';
  final String localStorageCustomNodeList = 'custom_node_list';

  final String cacheTestnetShowStatusKey = 'network_testnet_status';

  @observable
  bool loading = true;

  @observable
  String localeCode = '';

  @observable
  String currencyCode = 'usd';

  @observable
  CustomNode? currentNode;

  @observable
  bool testnetShowStatus = false;

  bool get isSupportTxHistory {
    return currentNode?.txUrl != null && currentNode!.txUrl!.isNotEmpty;
  }

  List<String> getSupportNetworkIDs() {
    return allNodes.map((node) => node.networkID).toList();
  }

  bool get isMainnet {
    return currentNode?.networkID == networkIDMap.mainnet;
  }

  @observable
  AboutUsData? aboutus;

  @observable
  List<CustomNode> customNodeList = [];

  List<CustomNode> get allNodes {
    return [...defaultNetworkList, ...customNodeList];
  }

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
    await loadTestnetShowStatus();
    await loadAboutUs();
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
  Future<void> updateCustomNode(CustomNode newNode, CustomNode oldNode) async {
    int index =
        customNodeList.indexWhere((element) => element.url == oldNode.url);
    if (index != -1) {
      customNodeList[index] = newNode;
    }
    setCustomNodeList(customNodeList);
  }

  @action
  Future<void> setCustomNodeList(List<CustomNode> nodeList) async {
    customNodeList = nodeList;
    await rootStore.localStorage
        .setObject(localStorageCustomNodeList, nodeList);
  }

  @action
  Future<void> loadCustomNodeList() async {
    try {
      List<dynamic>? stored = await rootStore.localStorage
          .getObject(localStorageCustomNodeList) as List<dynamic>?;
      if (stored != null) {
        customNodeList = stored.map((s) => CustomNode.fromJson(s)).toList();
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
  Future<void> setCurrentNode(CustomNode value) async {
    currentNode = value;
    await rootStore.localStorage.setObject(localStorageCustomNodeList, value);
  }

  @action
  Future<void> setTestnetShowStatus(bool status) async {
    testnetShowStatus = status;
    await rootStore.localStorage.setObject(cacheTestnetShowStatusKey, status);
  }

  @action
  Future<void> loadTestnetShowStatus() async {
    bool? showStatus = await rootStore.localStorage
        .getObject(cacheTestnetShowStatusKey) as bool?;
    testnetShowStatus = showStatus == true;
  }

  @action
  Future<void> loadCurrentNode() async {
    Map<String, dynamic>? cacheNode = await rootStore.localStorage
        .getObject(localStorageCustomNodeList) as Map<String, dynamic>?;
    CustomNode mainnetConfig = defaultNetworkList
        .firstWhere((network) => network.networkID == networkIDMap.mainnet);
    if (cacheNode == null) {
      currentNode = mainnetConfig;
    } else {
      try {
        // if parse error , use default
        currentNode = CustomNode.fromJson(cacheNode);
      } catch (e) {
        print('loadCurrentNode error ${e.toString()}');
        currentNode = mainnetConfig;
      }
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
