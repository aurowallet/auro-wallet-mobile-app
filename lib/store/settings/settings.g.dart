// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutUsData _$AboutUsDataFromJson(Map<String, dynamic> json) {
  return AboutUsData(
    changelog: json['changelog_app'] as String,
    gitReponame: json['gitReponame_app'] as String,
    followus: (json['followus'] as List<dynamic>)
        .map((e) =>
            e == null ? null : FollowUsData.fromJson(e as Map<String, dynamic>))
        .toList(),
  )
    ..stakingGuideCN = json['staking_guide_cn'] as String
    ..termsAndContionsEN = json['terms_and_contions'] as String
    ..privacyPolicyEN = json['privacy_policy'] as String
    ..termsAndContionsZH = json['terms_and_contions_cn'] as String
    ..privacyPolicyZH = json['privacy_policy_cn'] as String
    ..stakingGuide = json['staking_guide'] as String;
}

Map<String, dynamic> _$AboutUsDataToJson(AboutUsData instance) =>
    <String, dynamic>{
      'changelog_app': instance.changelog,
      'gitReponame_app': instance.gitReponame,
      'staking_guide_cn': instance.stakingGuideCN,
      'terms_and_contions': instance.termsAndContionsEN,
      'privacy_policy': instance.privacyPolicyEN,
      'terms_and_contions_cn': instance.termsAndContionsZH,
      'privacy_policy_cn': instance.privacyPolicyZH,
      'staking_guide': instance.stakingGuide,
      'followus': instance.followus,
    };

FollowUsData _$FollowUsDataFromJson(Map<String, dynamic> json) {
  return FollowUsData(
    website: json['website'] as String,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$FollowUsDataToJson(FollowUsData instance) =>
    <String, dynamic>{
      'website': instance.website,
      'name': instance.name,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStore, Store {
  final _$loadingAtom = Atom(name: '_SettingsStore.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$localeCodeAtom = Atom(name: '_SettingsStore.localeCode');

  @override
  String get localeCode {
    _$localeCodeAtom.reportRead();
    return super.localeCode;
  }

  @override
  set localeCode(String value) {
    _$localeCodeAtom.reportWrite(value, super.localeCode, () {
      super.localeCode = value;
    });
  }

  final _$currencyCodeAtom = Atom(name: '_SettingsStore.currencyCode');

  @override
  String get currencyCode {
    _$currencyCodeAtom.reportRead();
    return super.currencyCode;
  }

  @override
  set currencyCode(String value) {
    _$currencyCodeAtom.reportWrite(value, super.currencyCode, () {
      super.currencyCode = value;
    });
  }

  final _$endpointAtom = Atom(name: '_SettingsStore.endpoint');

  @override
  String get endpoint {
    _$endpointAtom.reportRead();
    return super.endpoint;
  }

  @override
  set endpoint(String value) {
    _$endpointAtom.reportWrite(value, super.endpoint, () {
      super.endpoint = value;
    });
  }

  final _$aboutusAtom = Atom(name: '_SettingsStore.aboutus');

  @override
  AboutUsData? get aboutus {
    _$aboutusAtom.reportRead();
    return super.aboutus;
  }

  @override
  set aboutus(AboutUsData? value) {
    _$aboutusAtom.reportWrite(value, super.aboutus, () {
      super.aboutus = value;
    });
  }

  final _$customNodeListAtom = Atom(name: '_SettingsStore.customNodeList');

  @override
  List<String> get customNodeList {
    _$customNodeListAtom.reportRead();
    return super.customNodeList;
  }

  @override
  set customNodeList(List<String> value) {
    _$customNodeListAtom.reportWrite(value, super.customNodeList, () {
      super.customNodeList = value;
    });
  }

  final _$customNodeListV2Atom = Atom(name: '_SettingsStore.customNodeListV2');

  @override
  List<CustomNode> get customNodeListV2 {
    _$customNodeListV2Atom.reportRead();
    return super.customNodeListV2;
  }

  @override
  set customNodeListV2(List<CustomNode> value) {
    _$customNodeListV2Atom.reportWrite(value, super.customNodeListV2, () {
      super.customNodeListV2 = value;
    });
  }

  final _$networkNameAtom = Atom(name: '_SettingsStore.networkName');

  @override
  String get networkName {
    _$networkNameAtom.reportRead();
    return super.networkName;
  }

  @override
  set networkName(String value) {
    _$networkNameAtom.reportWrite(value, super.networkName, () {
      super.networkName = value;
    });
  }

  final _$networkConstAtom = Atom(name: '_SettingsStore.networkConst');

  @override
  Map<dynamic, dynamic> get networkConst {
    _$networkConstAtom.reportRead();
    return super.networkConst;
  }

  @override
  set networkConst(Map<dynamic, dynamic> value) {
    _$networkConstAtom.reportWrite(value, super.networkConst, () {
      super.networkConst = value;
    });
  }

  final _$contactListAtom = Atom(name: '_SettingsStore.contactList');

  @override
  ObservableList<ContactData> get contactList {
    _$contactListAtom.reportRead();
    return super.contactList;
  }

  @override
  set contactList(ObservableList<ContactData> value) {
    _$contactListAtom.reportWrite(value, super.contactList, () {
      super.contactList = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_SettingsStore.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$setLocalCodeAsyncAction = AsyncAction('_SettingsStore.setLocalCode');

  @override
  Future<void> setLocalCode(String code) {
    return _$setLocalCodeAsyncAction.run(() => super.setLocalCode(code));
  }

  final _$setCurrencyCodeAsyncAction =
      AsyncAction('_SettingsStore.setCurrencyCode');

  @override
  Future<void> setCurrencyCode(String code) {
    return _$setCurrencyCodeAsyncAction.run(() => super.setCurrencyCode(code));
  }

  final _$loadLocalCodeAsyncAction =
      AsyncAction('_SettingsStore.loadLocalCode');

  @override
  Future<void> loadLocalCode() {
    return _$loadLocalCodeAsyncAction.run(() => super.loadLocalCode());
  }

  final _$loadCurrencyCodeAsyncAction =
      AsyncAction('_SettingsStore.loadCurrencyCode');

  @override
  Future<void> loadCurrencyCode() {
    return _$loadCurrencyCodeAsyncAction.run(() => super.loadCurrencyCode());
  }

  final _$updateCustomNodeAsyncAction =
      AsyncAction('_SettingsStore.updateCustomNode');

  @override
  Future<void> updateCustomNode(CustomNode newNode, CustomNode oldNode) {
    return _$updateCustomNodeAsyncAction
        .run(() => super.updateCustomNode(newNode, oldNode));
  }

  final _$setCustomNodeListAsyncAction =
      AsyncAction('_SettingsStore.setCustomNodeList');

  @override
  Future<void> setCustomNodeList(List<CustomNode> nodeList) {
    return _$setCustomNodeListAsyncAction
        .run(() => super.setCustomNodeList(nodeList));
  }

  final _$loadCustomNodeListAsyncAction =
      AsyncAction('_SettingsStore.loadCustomNodeList');

  @override
  Future<void> loadCustomNodeList() {
    return _$loadCustomNodeListAsyncAction
        .run(() => super.loadCustomNodeList());
  }

  final _$setEndpointAsyncAction = AsyncAction('_SettingsStore.setEndpoint');

  @override
  Future<void> setEndpoint(String value) {
    return _$setEndpointAsyncAction.run(() => super.setEndpoint(value));
  }

  final _$loadEndpointAsyncAction = AsyncAction('_SettingsStore.loadEndpoint');

  @override
  Future<void> loadEndpoint() {
    return _$loadEndpointAsyncAction.run(() => super.loadEndpoint());
  }

  final _$loadContactsAsyncAction = AsyncAction('_SettingsStore.loadContacts');

  @override
  Future<void> loadContacts() {
    return _$loadContactsAsyncAction.run(() => super.loadContacts());
  }

  final _$addContactAsyncAction = AsyncAction('_SettingsStore.addContact');

  @override
  Future<void> addContact(Map<String, dynamic> con) {
    return _$addContactAsyncAction.run(() => super.addContact(con));
  }

  final _$removeContactAsyncAction =
      AsyncAction('_SettingsStore.removeContact');

  @override
  Future<void> removeContact(ContactData con) {
    return _$removeContactAsyncAction.run(() => super.removeContact(con));
  }

  final _$updateContactAsyncAction =
      AsyncAction('_SettingsStore.updateContact');

  @override
  Future<void> updateContact(ContactData contact, String address) {
    return _$updateContactAsyncAction
        .run(() => super.updateContact(contact, address));
  }

  final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore');

  @override
  void setNetworkLoading(bool isLoading) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setNetworkLoading');
    try {
      return super.setNetworkLoading(isLoading);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAboutUs(AboutUsData value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setAboutUs');
    try {
      return super.setAboutUs(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
localeCode: ${localeCode},
currencyCode: ${currencyCode},
endpoint: ${endpoint},
aboutus: ${aboutus},
customNodeList: ${customNodeList},
customNodeListV2: ${customNodeListV2},
networkName: ${networkName},
networkConst: ${networkConst},
contactList: ${contactList}
    ''';
  }
}
