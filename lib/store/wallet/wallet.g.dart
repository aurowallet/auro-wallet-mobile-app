// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WalletStore on _WalletStore, Store {
  Computed<WalletData>? _$currentWalletComputed;

  @override
  WalletData get currentWallet => (_$currentWalletComputed ??=
          Computed<WalletData>(() => super.currentWallet,
              name: '_WalletStore.currentWallet'))
      .value;
  Computed<Map<String, WalletData>>? _$walletsMapComputed;

  @override
  Map<String, WalletData> get walletsMap => (_$walletsMapComputed ??=
          Computed<Map<String, WalletData>>(() => super.walletsMap,
              name: '_WalletStore.walletsMap'))
      .value;
  Computed<List<AccountData>>? _$accountListAllComputed;

  @override
  List<AccountData> get accountListAll => (_$accountListAllComputed ??=
          Computed<List<AccountData>>(() => super.accountListAll,
              name: '_WalletStore.accountListAll'))
      .value;
  Computed<List<AccountData>>? _$watchModeAccountListAllComputed;

  @override
  List<AccountData> get watchModeAccountListAll =>
      (_$watchModeAccountListAllComputed ??= Computed<List<AccountData>>(
              () => super.watchModeAccountListAll,
              name: '_WalletStore.watchModeAccountListAll'))
          .value;
  Computed<List<WalletData>>? _$walletListAllComputed;

  @override
  List<WalletData> get walletListAll => (_$walletListAllComputed ??=
          Computed<List<WalletData>>(() => super.walletListAll,
              name: '_WalletStore.walletListAll'))
      .value;
  Computed<WalletData?>? _$mnemonicWalletComputed;

  @override
  WalletData? get mnemonicWallet => (_$mnemonicWalletComputed ??=
          Computed<WalletData?>(() => super.mnemonicWallet,
              name: '_WalletStore.mnemonicWallet'))
      .value;
  Computed<String>? _$currentAddressComputed;

  @override
  String get currentAddress =>
      (_$currentAddressComputed ??= Computed<String>(() => super.currentAddress,
              name: '_WalletStore.currentAddress'))
          .value;
  Computed<String>? _$currentAccountPubKeyComputed;

  @override
  String get currentAccountPubKey => (_$currentAccountPubKeyComputed ??=
          Computed<String>(() => super.currentAccountPubKey,
              name: '_WalletStore.currentAccountPubKey'))
      .value;

  late final _$loadingAtom =
      Atom(name: '_WalletStore.loading', context: context);

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

  late final _$txStatusAtom =
      Atom(name: '_WalletStore.txStatus', context: context);

  @override
  String get txStatus {
    _$txStatusAtom.reportRead();
    return super.txStatus;
  }

  @override
  set txStatus(String value) {
    _$txStatusAtom.reportWrite(value, super.txStatus, () {
      super.txStatus = value;
    });
  }

  late final _$newWalletParamsAtom =
      Atom(name: '_WalletStore.newWalletParams', context: context);

  @override
  NewWalletParams get newWalletParams {
    _$newWalletParamsAtom.reportRead();
    return super.newWalletParams;
  }

  @override
  set newWalletParams(NewWalletParams value) {
    _$newWalletParamsAtom.reportWrite(value, super.newWalletParams, () {
      super.newWalletParams = value;
    });
  }

  late final _$currentWalletIdAtom =
      Atom(name: '_WalletStore.currentWalletId', context: context);

  @override
  String get currentWalletId {
    _$currentWalletIdAtom.reportRead();
    return super.currentWalletId;
  }

  @override
  set currentWalletId(String value) {
    _$currentWalletIdAtom.reportWrite(value, super.currentWalletId, () {
      super.currentWalletId = value;
    });
  }

  late final _$walletListAtom =
      Atom(name: '_WalletStore.walletList', context: context);

  @override
  ObservableList<WalletData> get walletList {
    _$walletListAtom.reportRead();
    return super.walletList;
  }

  @override
  set walletList(ObservableList<WalletData> value) {
    _$walletListAtom.reportWrite(value, super.walletList, () {
      super.walletList = value;
    });
  }

  late final _$setCurrentAccountAsyncAction =
      AsyncAction('_WalletStore.setCurrentAccount', context: context);

  @override
  Future<void> setCurrentAccount(String pubKey) {
    return _$setCurrentAccountAsyncAction
        .run(() => super.setCurrentAccount(pubKey));
  }

  late final _$updateAccountNameAsyncAction =
      AsyncAction('_WalletStore.updateAccountName', context: context);

  @override
  Future<void> updateAccountName(AccountData account, String name) {
    return _$updateAccountNameAsyncAction
        .run(() => super.updateAccountName(account, name));
  }

  late final _$updateAccountAsyncAction =
      AsyncAction('_WalletStore.updateAccount', context: context);

  @override
  Future<void> updateAccount(Map<String, dynamic> acc) {
    return _$updateAccountAsyncAction.run(() => super.updateAccount(acc));
  }

  late final _$clearWalletsAsyncAction =
      AsyncAction('_WalletStore.clearWallets', context: context);

  @override
  Future<void> clearWallets() {
    return _$clearWalletsAsyncAction.run(() => super.clearWallets());
  }

  late final _$addAccountAsyncAction =
      AsyncAction('_WalletStore.addAccount', context: context);

  @override
  Future<void> addAccount(
      Map<String, dynamic> acc, String accountName, WalletData wallet) {
    return _$addAccountAsyncAction
        .run(() => super.addAccount(acc, accountName, wallet));
  }

  late final _$addWalletAsyncAction =
      AsyncAction('_WalletStore.addWallet', context: context);

  @override
  Future<WalletResult> addWallet(
      Map<String, dynamic> walletInfo, String? password,
      {required BuildContext context,
      required String seedType,
      required String? walletSource}) {
    return _$addWalletAsyncAction.run(() => super.addWallet(
        walletInfo, password,
        context: context, seedType: seedType, walletSource: walletSource));
  }

  late final _$removeAccountAsyncAction =
      AsyncAction('_WalletStore.removeAccount', context: context);

  @override
  Future<void> removeAccount(AccountData acc) {
    return _$removeAccountAsyncAction.run(() => super.removeAccount(acc));
  }

  late final _$loadWalletAsyncAction =
      AsyncAction('_WalletStore.loadWallet', context: context);

  @override
  Future<void> loadWallet() {
    return _$loadWalletAsyncAction.run(() => super.loadWallet());
  }

  late final _$encryptSeedAsyncAction =
      AsyncAction('_WalletStore.encryptSeed', context: context);

  @override
  Future<void> encryptSeed(
      String pubKey, String seed, String seedType, String password) {
    return _$encryptSeedAsyncAction
        .run(() => super.encryptSeed(pubKey, seed, seedType, password));
  }

  late final _$decryptSeedAsyncAction =
      AsyncAction('_WalletStore.decryptSeed', context: context);

  @override
  Future<String?> decryptSeed(String pubKey, String seedType, String password) {
    return _$decryptSeedAsyncAction
        .run(() => super.decryptSeed(pubKey, seedType, password));
  }

  late final _$checkSeedExistAsyncAction =
      AsyncAction('_WalletStore.checkSeedExist', context: context);

  @override
  Future<bool> checkSeedExist(String seedType, String pubKey) {
    return _$checkSeedExistAsyncAction
        .run(() => super.checkSeedExist(seedType, pubKey));
  }

  late final _$checkPasswordAsyncAction =
      AsyncAction('_WalletStore.checkPassword', context: context);

  @override
  Future<bool> checkPassword(String pubKey, String seedType, String password) {
    return _$checkPasswordAsyncAction
        .run(() => super.checkPassword(pubKey, seedType, password));
  }

  late final _$deleteSeedAsyncAction =
      AsyncAction('_WalletStore.deleteSeed', context: context);

  @override
  Future<void> deleteSeed(String seedType, String pubKey) {
    return _$deleteSeedAsyncAction
        .run(() => super.deleteSeed(seedType, pubKey));
  }

  late final _$deleteWatchModeWalletsAsyncAction =
      AsyncAction('_WalletStore.deleteWatchModeWallets', context: context);

  @override
  Future<void> deleteWatchModeWallets() {
    return _$deleteWatchModeWalletsAsyncAction
        .run(() => super.deleteWatchModeWallets());
  }

  late final _$_WalletStoreActionController =
      ActionController(name: '_WalletStore', context: context);

  @override
  void setNewAccount(String password) {
    final _$actionInfo = _$_WalletStoreActionController.startAction(
        name: '_WalletStore.setNewAccount');
    try {
      return super.setNewAccount(password);
    } finally {
      _$_WalletStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewWalletSeed(String seed, String seedType) {
    final _$actionInfo = _$_WalletStoreActionController.startAction(
        name: '_WalletStore.setNewWalletSeed');
    try {
      return super.setNewWalletSeed(seed, seedType);
    } finally {
      _$_WalletStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNewWallet() {
    final _$actionInfo = _$_WalletStoreActionController.startAction(
        name: '_WalletStore.resetNewWallet');
    try {
      return super.resetNewWallet();
    } finally {
      _$_WalletStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
txStatus: ${txStatus},
newWalletParams: ${newWalletParams},
currentWalletId: ${currentWalletId},
walletList: ${walletList},
currentWallet: ${currentWallet},
walletsMap: ${walletsMap},
accountListAll: ${accountListAll},
watchModeAccountListAll: ${watchModeAccountListAll},
walletListAll: ${walletListAll},
mnemonicWallet: ${mnemonicWallet},
currentAddress: ${currentAddress},
currentAccountPubKey: ${currentAccountPubKey}
    ''';
  }
}
