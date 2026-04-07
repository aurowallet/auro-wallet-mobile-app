import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/newWalletParams.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/utils/encryption.dart';
import 'package:auro_wallet/store/wallet/types/seedData.dart';
import 'package:auro_wallet/store/wallet/types/uiKeyring.dart';
import 'package:collection/collection.dart';

part 'wallet.g.dart';

class WalletStore extends _WalletStore with _$WalletStore {
  WalletStore(AppStore appStore) : super(appStore);
  static const String seedTypeMnemonic = 'mnemonic';
  static const String seedTypePrivateKey = 'priKey';
  static const String seedTypeLedger = 'ledger';
  static const String seedTypeNone = 'none';
  
  // Keyring type constants for UI grouping
  static const String keyringTypeHD = 'hd';
  static const String keyringTypeImported = 'imported';
  static const String keyringTypeLedger = 'ledger';
  static const String keyringTypeWatch = 'watch';
  
  // Keyring group name constants
  static const String keyringGroupImported = 'Imported';
  static const String keyringGroupLedger = 'Ledger';

  /// Default account name for HD wallets: "Account 1", "Account 2", etc.
  static String defaultAccountName(int index) => 'Account $index';
}

abstract class _WalletStore with Store {
  _WalletStore(this.rootStore);

  final AppStore rootStore;

  @observable
  bool loading = true;

  @observable
  String txStatus = '';

  @observable
  NewWalletParams newWalletParams = NewWalletParams();

  @observable
  late String currentWalletId = '';

  @observable
  ObservableList<WalletData> walletList = ObservableList<WalletData>();

  String runtimePwd = "";

  @computed
  WalletData get currentWallet {
    int i = walletList.indexWhere((i) => i.id == currentWalletId);
    if (i < 0) {
      return WalletData();
    }
    return walletListAll[i];
  }

  @computed
  Map<String, WalletData> get walletsMap {
    Map<String, WalletData> wallets = Map<String, WalletData>();
    walletList.forEach((wallet) {
      wallets[wallet.id] = wallet;
    });
    return wallets;
  }

  @computed
  List<AccountData> get accountListAll {
    List<AccountData> accountList = [];
    walletList
        .where((wallet) => wallet.walletType != WalletStore.seedTypeNone)
        .forEach((wallet) {
      accountList.addAll(wallet.accounts);
    });
    return accountList;
  }

  @computed
  List<AccountData> get watchModeAccountListAll {
    List<AccountData> accountList = [];
    walletList
        .where((wallet) => wallet.walletType == WalletStore.seedTypeNone)
        .forEach((wallet) {
      accountList.addAll(wallet.accounts);
    });
    return accountList;
  }

  @computed
  List<WalletData> get walletListAll {
    List<WalletData> accList = walletList.toList();
    return accList;
  }

  @computed
  WalletData? get mnemonicWallet {
    // there is only one mnemonic wallet in the app
    return walletList.firstWhereOrNull(
        (element) => element.walletType == WalletStore.seedTypeMnemonic);
  }

  @computed
  String get currentAddress {
    return currentWallet.address;
  }

  @computed
  String get currentAccountPubKey {
    return currentWallet.pubKey;
  }

  @action
  void setNewAccount(String password) {
    newWalletParams.password = password;
  }

  @action
  void setNewWalletName(String name) {
    newWalletParams.name = name;
  }

  @action
  void setNewWalletSeed(String seed, String seedType) {
    newWalletParams.seed = seed;
    newWalletParams.seedType = seedType;
  }

  @action
  void resetNewWallet() {
    newWalletParams = NewWalletParams();
  }

  @action
  Future<void> setCurrentAccount(String pubKey) async {
    final wallet = walletList.firstWhereOrNull((w) =>
        w.accounts.indexWhere((account) => account.pubKey == pubKey) >= 0);
    if (wallet == null) {
      return;
    }
    final account = wallet.accounts.firstWhereOrNull((acc) => acc.pubKey == pubKey);
    if (account == null) {
      return;
    }
    wallet.currentAccountIndex = account.accountIndex;
    await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    await rootStore.localStorage.setCurrentWallet(wallet.id);
    await loadWallet();
  }

  @action
  Future<void> updateAccountName(AccountData account, String name) async {
    Map<String, dynamic> acc = account.toJson();
    acc['name'] = name;
    await updateAccount(acc);
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> acc) async {
    AccountData newAccount = AccountData.fromJson(acc);
    final wallet = walletList.firstWhereOrNull((w) => w.id == newAccount.walletId);
    if (wallet == null) {
      return;
    }
    int index = wallet.accounts
        .indexWhere((account) => account.pubKey == newAccount.pubKey);
    if (index < 0) {
      return;
    }
    wallet.accounts.removeAt(index);
    wallet.accounts.insert(index, newAccount);
    await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    await loadWallet();
  }

  @action
  Future<void> clearWallets() async {
    await rootStore.localStorage.clearWallets();
    await rootStore.localStorage.setCurrentWallet('');
    await rootStore.secureStorage.clearSeeds();
    await loadWallet();
    rootStore.walletConnectService?.clearAllPairings();
    // Reset new wallet params to ensure clean state
    resetNewWallet();
  }

  @action
  Future<void> addAccount(
      Map<String, dynamic> acc, String accountName, WalletData wallet) async {
    String pubKey = acc['pubKey'];
    int hdIndex = acc['hdIndex'];
    AccountData accountData = new AccountData()
      ..pubKey = pubKey
      ..name = accountName
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..walletId = wallet.id
      ..accountIndex = hdIndex;

    wallet.accounts.add(accountData);
    wallet.currentAccountIndex = hdIndex;
    await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    await rootStore.localStorage.setCurrentWallet(wallet.id);
    await loadWallet();
  }

  int getNextWalletAccountIndex(WalletData? wallet) {
    if (wallet == null) {
      return 0;
    }
    int nextAccountIndex = 0;
    wallet.accounts.forEach((account) {
      if (account.accountIndex > nextAccountIndex) {
        nextAccountIndex = account.accountIndex;
      }
    });
    nextAccountIndex++;
    return nextAccountIndex;
  }

  Future<String?> getMnemonic(WalletData wallet, String password) async {
    if (wallet.walletType == WalletStore.seedTypeMnemonic) {
      return decryptSeed(wallet.id, WalletStore.seedTypeMnemonic, password);
    } else {
      return null;
    }
  }

  Future<String?> getPrivateKey(WalletData wallet, String password) async {
    var pri =
        await decryptSeed(wallet.id, WalletStore.seedTypePrivateKey, password);
    return pri;
  }

  int getNextWalletIndexOfType(String walletType) {
    int index = 0;
    var typeWallets =
        walletList.where((w) => w.walletType == walletType).toList();
    typeWallets.forEach((w) {
      if (w.walletTypeIndex >= index) {
        index = w.walletTypeIndex + 1;
      }
    });
    return index;
  }
  bool isPubKeyExist(String pubKey) {
    int index = walletList.indexWhere((item) {
      List<AccountData> accountList = item.accounts;
      return accountList.indexWhere((account) => account.pubKey == pubKey) !=
          -1;
    });
    return index != -1;
  }

  @action
  Future<WalletResult> addWallet(
    Map<String, dynamic> walletInfo,
    String? password, {
    required BuildContext context,
    required String seedType,
    required String? walletSource,
  }) async {
    String pubKey = walletInfo['pubKey'];
    int hdIndex = walletInfo.containsKey('hdIndex') ? walletInfo['hdIndex'] : 0;
    String? name = walletInfo['name'];
    String source = walletSource != null && walletSource.isNotEmpty
        ? walletSource
        : WalletSource.inside;
    if (isPubKeyExist(pubKey)) {
      return WalletResult.addressExisted;
    }
    // save seed and remove it before add account
    Future<void> saveSeed(String seedType) async {
      String? seed = walletInfo[seedType];
      if (seed != null && seed.isNotEmpty) {
        await encryptSeed(pubKey, walletInfo[seedType], seedType, password!);
      }
    }

    if (seedType == WalletStore.seedTypeMnemonic) {
      await saveSeed(WalletStore.seedTypeMnemonic);
    } else if (seedType == WalletStore.seedTypePrivateKey) {
      await saveSeed(WalletStore.seedTypePrivateKey);
    } else if (seedType == WalletStore.seedTypeLedger) {
      String ledgerContent = jsonEncode({
        "pubKey": pubKey,
        "hdIndex": hdIndex,
      });
      await encryptSeed(pubKey, ledgerContent, seedType, password!);
    }
    walletInfo.remove(WalletStore.seedTypeMnemonic);
    walletInfo.remove(WalletStore.seedTypePrivateKey);

    var accountData = new AccountData()
      ..pubKey = pubKey
      ..name = seedType == WalletStore.seedTypeMnemonic ? WalletStore.defaultAccountName(1) : (name ?? "")
      ..walletId = pubKey
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..accountIndex = hdIndex;

    var walletData = new WalletData()
      ..walletType = seedType
      ..walletTypeIndex =
          walletList.where((w) => w.walletType == seedType).toList().length
      ..id = pubKey
      ..source = source
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..accounts = [accountData]
      ..currentAccountIndex = hdIndex;

    await rootStore.localStorage.addWallet(WalletData.toJson(walletData));
    await rootStore.localStorage.setCurrentWallet(pubKey);

    await loadWallet();
    return WalletResult.success;
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    final wallet = walletList.firstWhereOrNull((w) => w.id == acc.walletId);
    if (wallet == null) {
      return;
    }
    wallet.accounts.removeWhere((account) => account.pubKey == acc.pubKey);

    // delete wallet if no account left
    if (wallet.accounts.length == 0) {
      // remove encrypted seed after removing account
      await rootStore.localStorage.removeWallet(wallet.id);
      await deleteSeed(WalletStore.seedTypeMnemonic, wallet.id);
      await deleteSeed(WalletStore.seedTypePrivateKey, wallet.id);
      final newCurrent = walletList.firstWhereOrNull((w) => w.id != wallet.id && w.accounts.isNotEmpty);
      if (newCurrent != null) {
        newCurrent.currentAccountIndex = newCurrent.accounts[0].accountIndex;
        await rootStore.localStorage.updateWallet(WalletData.toJson(newCurrent));
        await rootStore.localStorage.setCurrentWallet(newCurrent.id);
        if(rootStore.wallet!.currentAddress != newCurrent.currentAccount.pubKey){
          rootStore.walletConnectService?.emitAccountsChanged(newCurrent.currentAccount.pubKey);
        }
      } else {
        await rootStore.localStorage.setCurrentWallet('');
      }
    } else {
      wallet.currentAccountIndex = wallet.accounts[0].accountIndex;
      await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    }
    await loadWallet();
  }

  @action
  Future<void> loadWallet() async {
    List<Map<String, dynamic>> accList =
        await rootStore.localStorage.getWalletList();
    walletList = ObservableList.of(accList.map((i) => WalletData.fromJson(i)));
    var _currentWalletId = await rootStore.localStorage.getCurrentWallet();
    if (_currentWalletId != null) {
      currentWalletId = _currentWalletId;
    } else if (walletList.length > 0) {
      currentWalletId = walletList[0].id;
    }
    loading = false;
  }

  @action
  Future<void> encryptSeed(
      String pubKey, String seed, String seedType, String password) async {
    var encryption = Encryption();
    Map<String, dynamic> encryptedSeed =
        await encryption.encrypt(content: seed, password: password);
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    stored[pubKey] = encryptedSeed;
    await rootStore.secureStorage.setSeeds(seedType, stored);
  }

  @action
  Future<String?> decryptSeed(
      String pubKey, String seedType, String password) async {
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    Map<String, dynamic>? encrypted = stored[pubKey];
    if (encrypted == null) {
      return null;
    }
    var encryption = Encryption();
    String? decryptedStr =
        await encryption.decrypt(data: encrypted, password: password);
    var seedData = SeedData.fromJson(encrypted);
    if (decryptedStr != null && seedData.version != 3) {
      await encryptSeed(pubKey, decryptedStr, seedType, password);
    }
    return decryptedStr;
  }

  @action
  Future<bool> checkSeedExist(String seedType, String pubKey) async {
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    dynamic encrypted = stored[pubKey];
    return encrypted != null;
  }

  @action
  Future<bool> checkPassword(
      String pubKey, String seedType, String password) async {
    try {
      String? res = await decryptSeed(pubKey, seedType, password);
      if (res == null) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateAllWalletSeed(
      String passwordOld, String passwordNew) async {
    try {
      for (var i = 0; i < walletList.length; i++) {
        var wallet = walletList[i];
        await updateSeed(wallet.id, passwordOld, passwordNew);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSeed(
      String pubKey, String passwordOld, String passwordNew) async {
    Map storedMnemonics =
        await rootStore.secureStorage.getSeeds(WalletStore.seedTypeMnemonic);
    Map storedRawSeeds =
        await rootStore.secureStorage.getSeeds(WalletStore.seedTypePrivateKey);
    Map<String, dynamic>? encryptedSeed;
    String seedType = '';
    if (storedMnemonics[pubKey] != null) {
      encryptedSeed = storedMnemonics[pubKey];
      seedType = WalletStore.seedTypeMnemonic;
    } else if (storedRawSeeds[pubKey] != null) {
      encryptedSeed = storedRawSeeds[pubKey];
      seedType = WalletStore.seedTypePrivateKey;
    } else {
      return;
    }
    var encryption = Encryption();
    String? seed =
        await encryption.decrypt(data: encryptedSeed!, password: passwordOld);
    if (seed != null) {
      await encryptSeed(pubKey, seed, seedType, passwordNew);
    }
  }

  @action
  Future<void> deleteSeed(String seedType, String pubKey) async {
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    if (stored[pubKey] != null) {
      stored.remove(pubKey);
      await rootStore.secureStorage.setSeeds(seedType, stored);
    }
  }

  bool hasWatchModeWallet() {
    return walletList
        .any((element) => element.walletType == WalletStore.seedTypeNone);
  }

  @action
  Future<void> deleteWatchModeWallets() async {
    bool isCurrentWalletAWatchMode = false;
    List<WalletData> noneWatchModeWallets = [];
    final wallets = walletList.where((wallet) {
      if (!isCurrentWalletAWatchMode && wallet.id == currentWalletId) {
        isCurrentWalletAWatchMode = true;
      }
      var isWatchMode = wallet.walletType == WalletStore.seedTypeNone;
      if (!isWatchMode) {
        noneWatchModeWallets.add(wallet);
      }
      return isWatchMode;
    });

    if (wallets.length > 0) {
      for (final wallet in wallets) {
        await rootStore.localStorage.removeWallet(wallet.id);
      }
      if (noneWatchModeWallets.length > 0) {
        await rootStore.localStorage
            .setCurrentWallet(noneWatchModeWallets[0].id);
      } else {
        await rootStore.localStorage.setCurrentWallet('');
      }
      await loadWallet();
    }
  }

  void setRuntimePwd(String pwd) {
    runtimePwd = pwd;
  }

  void clearRuntimePwd() {
    runtimePwd = "";
  }

  // ============ Multi-Wallet UI Logic ============

  /// Get wallet list sorted by creation time
  @computed
  List<WalletData> get sortedWalletList {
    final list = walletList.toList();
    list.sort((a, b) => a.createTime.compareTo(b.createTime));
    return list;
  }

  /// Get all HD wallet list
  @computed
  List<WalletData> get hdWalletList {
    return sortedWalletList
        .where((w) => w.walletType == WalletStore.seedTypeMnemonic)
        .toList();
  }

  /// Get all imported private key wallet list
  @computed
  List<WalletData> get importedWalletList {
    return sortedWalletList
        .where((w) => w.walletType == WalletStore.seedTypePrivateKey)
        .toList();
  }

  /// Get all Ledger wallet list
  @computed
  List<WalletData> get ledgerWalletList {
    return sortedWalletList
        .where((w) => w.walletType == WalletStore.seedTypeLedger)
        .toList();
  }

  /// Get all watch wallet list
  @computed
  List<WalletData> get watchWalletList {
    return sortedWalletList
        .where((w) => w.walletType == WalletStore.seedTypeNone)
        .toList();
  }

  /// Get HD wallet count
  int get hdWalletCount => hdWalletList.length;

  /// Get next HD wallet default name
  String getNextHDWalletName() {
    final nextIndex = getNextWalletIndexOfType(WalletStore.seedTypeMnemonic);
    return 'Wallet ${nextIndex + 1}';
  }

  /// Convert to UI Keyring list (matching React display logic)
  /// HD wallets: each is a separate group
  /// Imported wallets: all merged into one "Imported" group  
  /// Ledger wallets: all merged into one "Ledger" group
  /// All groups sorted by creation time
  List<UIKeyring> getKeyringsList() {
    final keyrings = <UIKeyring>[];

    // 1. Add all HD wallets (each HD wallet is an independent Keyring)
    for (final wallet in hdWalletList) {
      keyrings.add(_walletToUIKeyring(wallet, WalletStore.keyringTypeHD));
    }

    // 2. Merge all imported wallets into one "Imported" group
    if (importedWalletList.isNotEmpty) {
      keyrings.add(_mergeWalletsToUIKeyring(importedWalletList, WalletStore.keyringTypeImported, WalletStore.keyringGroupImported));
    }

    // 3. Merge all Ledger wallets into one "Ledger" group
    if (ledgerWalletList.isNotEmpty) {
      keyrings.add(_mergeWalletsToUIKeyring(ledgerWalletList, WalletStore.keyringTypeLedger, WalletStore.keyringGroupLedger));
    }

    // 4. Watch wallets (each separate, or could merge - keeping separate for now)
    for (final wallet in watchWalletList) {
      keyrings.add(_walletToUIKeyring(wallet, WalletStore.keyringTypeWatch));
    }

    // 5. Sort all keyrings by creation time (earliest first)
    keyrings.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return keyrings;
  }

  /// Merge multiple wallets into a single UIKeyring group
  UIKeyring _mergeWalletsToUIKeyring(List<WalletData> wallets, String type, String groupName) {
    final allAccounts = <UIKeyringAccount>[];
    int earliestCreatedAt = wallets.first.createTime;
    
    for (final wallet in wallets) {
      if (wallet.createTime < earliestCreatedAt) {
        earliestCreatedAt = wallet.createTime;
      }
      for (final acc in wallet.accounts) {
        allAccounts.add(UIKeyringAccount(
          address: acc.pubKey,
          name: acc.name.isNotEmpty ? acc.name : getWalletDisplayName(wallet),
          hdIndex: acc.accountIndex,
          type: _getAccountType(wallet.walletType),
          walletId: wallet.id,
        ));
      }
    }
    
    return UIKeyring(
      id: '${type}_group',
      type: type,
      name: groupName,
      createdAt: earliestCreatedAt,
      canAddAccount: false,
      currentAddress: null,
      accounts: allAccounts,
    );
  }

  UIKeyring _walletToUIKeyring(WalletData wallet, String type) {
    // Safe access to currentAccount - returns empty string if no accounts
    final currentAddr = wallet.accounts.isNotEmpty 
        ? wallet.currentAccount.pubKey 
        : null;
    
    return UIKeyring(
      id: wallet.id,
      type: type,
      name: getWalletDisplayName(wallet),
      createdAt: wallet.createTime,
      canAddAccount: wallet.walletType == WalletStore.seedTypeMnemonic,
      currentAddress: currentAddr,
      accounts: wallet.accounts
          .map((acc) => UIKeyringAccount(
                address: acc.pubKey,
                name: acc.name,
                hdIndex: acc.accountIndex,
                type: _getAccountType(wallet.walletType),
                walletId: wallet.id,
              ))
          .toList(),
    );
  }

  String _getAccountType(String walletType) {
    switch (walletType) {
      case 'mnemonic':
        return 'WALLET_INSIDE';
      case 'priKey':
        return 'WALLET_OUTSIDE';
      case 'ledger':
        return 'WALLET_LEDGER';
      case 'none':
        return 'WALLET_WATCH';
      default:
        return 'WALLET_INSIDE';
    }
  }

  /// Get wallet display name
  String getWalletDisplayName(WalletData wallet) {
    // If has custom name, use custom name
    if (wallet.meta['name'] != null) {
      return wallet.meta['name'];
    }

    // Otherwise generate default name based on type
    switch (wallet.walletType) {
      case 'mnemonic':
        return 'Wallet ${wallet.walletTypeIndex + 1}';
      case 'priKey':
        return 'Imported ${wallet.walletTypeIndex + 1}';
      case 'ledger':
        return 'Ledger ${wallet.walletTypeIndex + 1}';
      case 'none':
        return 'Watch ${wallet.walletTypeIndex + 1}';
      default:
        return 'Wallet ${wallet.walletTypeIndex + 1}';
    }
  }

  /// Rename wallet
  @action
  Future<bool> renameWallet(String walletId, String newName) async {
    try {
      final wallet = walletList.firstWhereOrNull((w) => w.id == walletId);
      if (wallet == null) return false;

      wallet.meta['name'] = newName;

      await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
      await loadWallet();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete entire wallet (including all accounts)
  @action
  Future<bool> deleteWallet(String walletId, String password) async {
    try {
      final wallet = walletList.firstWhereOrNull((w) => w.id == walletId);
      if (wallet == null) return false;

      // Verify password (Watch wallet doesn't need password)
      if (wallet.walletType != WalletStore.seedTypeNone) {
        final isValid =
            await checkPassword(wallet.id, wallet.walletType, password);
        if (!isValid) return false;
      }

      // Delete seed data
      await deleteSeed(wallet.walletType, wallet.id);

      // Remove wallet from storage
      await rootStore.localStorage.removeWallet(wallet.id);

      if (walletId == currentWalletId) {
        final newCurrent =
            walletList.firstWhereOrNull((w) => w.id != walletId && w.accounts.isNotEmpty);
        if (newCurrent != null) {
          newCurrent.currentAccountIndex = newCurrent.accounts[0].accountIndex;
          await rootStore.localStorage.updateWallet(WalletData.toJson(newCurrent));
          await rootStore.localStorage.setCurrentWallet(newCurrent.id);
        } else {
          await rootStore.localStorage.setCurrentWallet('');
        }
      }

      await loadWallet();

      // Notify DApp of address change (only if wallet still exists)
      if (walletList.isNotEmpty && currentWallet.id.isNotEmpty) {
        rootStore.walletConnectService
            ?.emitAccountsChanged(currentWallet.currentAccount.pubKey);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get mnemonic for specified wallet
  Future<String?> getWalletMnemonic(String walletId, String password) async {
    final wallet = walletList.firstWhereOrNull((w) => w.id == walletId);
    if (wallet == null || wallet.walletType != WalletStore.seedTypeMnemonic) {
      return null;
    }
    return await decryptSeed(walletId, WalletStore.seedTypeMnemonic, password);
  }

  /// Add new account to specified HD wallet
  /// Returns derivation params for caller to handle
  @action
  Future<Map<String, dynamic>?> addAccountToWallet(
    String walletId,
    String accountName,
    String password,
  ) async {
    try {
      final wallet = walletList.firstWhereOrNull((w) => w.id == walletId);
      if (wallet == null || wallet.walletType != WalletStore.seedTypeMnemonic) {
        return null;
      }

      // Verify password
      final isValid =
          await checkPassword(walletId, WalletStore.seedTypeMnemonic, password);
      if (!isValid) return null;

      // Get mnemonic
      final mnemonic =
          await decryptSeed(walletId, WalletStore.seedTypeMnemonic, password);
      if (mnemonic == null) return null;

      // Calculate next HD index
      final nextIndex = getNextWalletAccountIndex(wallet);

      // Return derivation result for caller to handle
      return {
        'walletId': walletId,
        'mnemonic': mnemonic,
        'nextIndex': nextIndex,
        'accountName': accountName.isEmpty
            ? WalletStore.defaultAccountName(wallet.accounts.length + 1)
            : accountName,
      };
    } catch (_) {
      return null;
    }
  }

  /// Check if address exists in any wallet
  bool isAddressExist(String address) {
    return walletList
        .any((wallet) => wallet.accounts.any((acc) => acc.pubKey == address));
  }

  /// Find wallet by account address
  WalletData? findWalletByAddress(String address) {
    return walletList.firstWhereOrNull((wallet) =>
        wallet.accounts.any((acc) => acc.pubKey == address));
  }

  /// Get current keyring ID (wallet ID)
  String? get currentKeyringId => currentWalletId;
}
