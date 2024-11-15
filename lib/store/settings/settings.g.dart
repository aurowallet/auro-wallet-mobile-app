// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$loadingAtom =
      Atom(name: '_SettingsStore.loading', context: context);

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

  late final _$localeCodeAtom =
      Atom(name: '_SettingsStore.localeCode', context: context);

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

  late final _$currencyCodeAtom =
      Atom(name: '_SettingsStore.currencyCode', context: context);

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

  late final _$currentNodeAtom =
      Atom(name: '_SettingsStore.currentNode', context: context);

  @override
  CustomNode? get currentNode {
    _$currentNodeAtom.reportRead();
    return super.currentNode;
  }

  @override
  set currentNode(CustomNode? value) {
    _$currentNodeAtom.reportWrite(value, super.currentNode, () {
      super.currentNode = value;
    });
  }

  late final _$testnetShowStatusAtom =
      Atom(name: '_SettingsStore.testnetShowStatus', context: context);

  @override
  bool get testnetShowStatus {
    _$testnetShowStatusAtom.reportRead();
    return super.testnetShowStatus;
  }

  @override
  set testnetShowStatus(bool value) {
    _$testnetShowStatusAtom.reportWrite(value, super.testnetShowStatus, () {
      super.testnetShowStatus = value;
    });
  }

  late final _$lockWalletStatusAtom =
      Atom(name: '_SettingsStore.lockWalletStatus', context: context);

  @override
  bool get lockWalletStatus {
    _$lockWalletStatusAtom.reportRead();
    return super.lockWalletStatus;
  }

  @override
  set lockWalletStatus(bool value) {
    _$lockWalletStatusAtom.reportWrite(value, super.lockWalletStatus, () {
      super.lockWalletStatus = value;
    });
  }

  late final _$certExpiredCheckStatusAtom =
      Atom(name: '_SettingsStore.certExpiredCheckStatus', context: context);

  @override
  Map<String, bool> get certExpiredCheckStatus {
    _$certExpiredCheckStatusAtom.reportRead();
    return super.certExpiredCheckStatus;
  }

  @override
  set certExpiredCheckStatus(Map<String, bool> value) {
    _$certExpiredCheckStatusAtom
        .reportWrite(value, super.certExpiredCheckStatus, () {
      super.certExpiredCheckStatus = value;
    });
  }

  late final _$certificateKeyDataAtom =
      Atom(name: '_SettingsStore.certificateKeyData', context: context);

  @override
  Map<String, dynamic> get certificateKeyData {
    _$certificateKeyDataAtom.reportRead();
    return super.certificateKeyData;
  }

  @override
  set certificateKeyData(Map<String, dynamic> value) {
    _$certificateKeyDataAtom.reportWrite(value, super.certificateKeyData, () {
      super.certificateKeyData = value;
    });
  }

  late final _$aboutusAtom =
      Atom(name: '_SettingsStore.aboutus', context: context);

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

  late final _$customNodeListAtom =
      Atom(name: '_SettingsStore.customNodeList', context: context);

  @override
  List<CustomNode> get customNodeList {
    _$customNodeListAtom.reportRead();
    return super.customNodeList;
  }

  @override
  set customNodeList(List<CustomNode> value) {
    _$customNodeListAtom.reportWrite(value, super.customNodeList, () {
      super.customNodeList = value;
    });
  }

  late final _$networkNameAtom =
      Atom(name: '_SettingsStore.networkName', context: context);

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

  late final _$networkConstAtom =
      Atom(name: '_SettingsStore.networkConst', context: context);

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

  late final _$contactListAtom =
      Atom(name: '_SettingsStore.contactList', context: context);

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

  late final _$initAsyncAction =
      AsyncAction('_SettingsStore.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$setCertificatesKeysAsyncAction =
      AsyncAction('_SettingsStore.setCertificatesKeys', context: context);

  @override
  Future<void> setCertificatesKeys(CertificateKeys certType, String key) {
    return _$setCertificatesKeysAsyncAction
        .run(() => super.setCertificatesKeys(certType, key));
  }

  late final _$loadCertificatesKeysAsyncAction =
      AsyncAction('_SettingsStore.loadCertificatesKeys', context: context);

  @override
  Future<void> loadCertificatesKeys() {
    return _$loadCertificatesKeysAsyncAction
        .run(() => super.loadCertificatesKeys());
  }

  late final _$setLocalCodeAsyncAction =
      AsyncAction('_SettingsStore.setLocalCode', context: context);

  @override
  Future<void> setLocalCode(String code) {
    return _$setLocalCodeAsyncAction.run(() => super.setLocalCode(code));
  }

  late final _$setCurrencyCodeAsyncAction =
      AsyncAction('_SettingsStore.setCurrencyCode', context: context);

  @override
  Future<void> setCurrencyCode(String code) {
    return _$setCurrencyCodeAsyncAction.run(() => super.setCurrencyCode(code));
  }

  late final _$loadLocalCodeAsyncAction =
      AsyncAction('_SettingsStore.loadLocalCode', context: context);

  @override
  Future<void> loadLocalCode() {
    return _$loadLocalCodeAsyncAction.run(() => super.loadLocalCode());
  }

  late final _$loadCurrencyCodeAsyncAction =
      AsyncAction('_SettingsStore.loadCurrencyCode', context: context);

  @override
  Future<void> loadCurrencyCode() {
    return _$loadCurrencyCodeAsyncAction.run(() => super.loadCurrencyCode());
  }

  late final _$updateCustomNodeAsyncAction =
      AsyncAction('_SettingsStore.updateCustomNode', context: context);

  @override
  Future<void> updateCustomNode(CustomNode newNode, CustomNode oldNode) {
    return _$updateCustomNodeAsyncAction
        .run(() => super.updateCustomNode(newNode, oldNode));
  }

  late final _$setCustomNodeListAsyncAction =
      AsyncAction('_SettingsStore.setCustomNodeList', context: context);

  @override
  Future<void> setCustomNodeList(List<CustomNode> nodeList) {
    return _$setCustomNodeListAsyncAction
        .run(() => super.setCustomNodeList(nodeList));
  }

  late final _$loadCustomNodeListAsyncAction =
      AsyncAction('_SettingsStore.loadCustomNodeList', context: context);

  @override
  Future<void> loadCustomNodeList() {
    return _$loadCustomNodeListAsyncAction
        .run(() => super.loadCustomNodeList());
  }

  late final _$setCurrentNodeAsyncAction =
      AsyncAction('_SettingsStore.setCurrentNode', context: context);

  @override
  Future<void> setCurrentNode(CustomNode value) {
    return _$setCurrentNodeAsyncAction.run(() => super.setCurrentNode(value));
  }

  late final _$setTestnetShowStatusAsyncAction =
      AsyncAction('_SettingsStore.setTestnetShowStatus', context: context);

  @override
  Future<void> setTestnetShowStatus(bool status) {
    return _$setTestnetShowStatusAsyncAction
        .run(() => super.setTestnetShowStatus(status));
  }

  late final _$loadTestnetShowStatusAsyncAction =
      AsyncAction('_SettingsStore.loadTestnetShowStatus', context: context);

  @override
  Future<void> loadTestnetShowStatus() {
    return _$loadTestnetShowStatusAsyncAction
        .run(() => super.loadTestnetShowStatus());
  }

  late final _$loadCurrentNodeAsyncAction =
      AsyncAction('_SettingsStore.loadCurrentNode', context: context);

  @override
  Future<void> loadCurrentNode() {
    return _$loadCurrentNodeAsyncAction.run(() => super.loadCurrentNode());
  }

  late final _$loadContactsAsyncAction =
      AsyncAction('_SettingsStore.loadContacts', context: context);

  @override
  Future<void> loadContacts() {
    return _$loadContactsAsyncAction.run(() => super.loadContacts());
  }

  late final _$addContactAsyncAction =
      AsyncAction('_SettingsStore.addContact', context: context);

  @override
  Future<void> addContact(Map<String, dynamic> con) {
    return _$addContactAsyncAction.run(() => super.addContact(con));
  }

  late final _$removeContactAsyncAction =
      AsyncAction('_SettingsStore.removeContact', context: context);

  @override
  Future<void> removeContact(ContactData con) {
    return _$removeContactAsyncAction.run(() => super.removeContact(con));
  }

  late final _$updateContactAsyncAction =
      AsyncAction('_SettingsStore.updateContact', context: context);

  @override
  Future<void> updateContact(ContactData contact, String address) {
    return _$updateContactAsyncAction
        .run(() => super.updateContact(contact, address));
  }

  late final _$setLockWalletStatusAsyncAction =
      AsyncAction('_SettingsStore.setLockWalletStatus', context: context);

  @override
  Future<void> setLockWalletStatus(bool status) {
    return _$setLockWalletStatusAsyncAction
        .run(() => super.setLockWalletStatus(status));
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

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
currentNode: ${currentNode},
testnetShowStatus: ${testnetShowStatus},
lockWalletStatus: ${lockWalletStatus},
certExpiredCheckStatus: ${certExpiredCheckStatus},
certificateKeyData: ${certificateKeyData},
aboutus: ${aboutus},
customNodeList: ${customNodeList},
networkName: ${networkName},
networkConst: ${networkConst},
contactList: ${contactList}
    ''';
  }
}
