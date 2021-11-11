import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/store/wallet/types/newWalletParams.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/encryption.dart';
import 'package:auro_wallet/store/wallet/types/seedData.dart';

part 'wallet.g.dart';

class WalletStore extends _WalletStore with _$WalletStore {
  WalletStore(AppStore appStore) : super(appStore);
  static const String seedTypeMnemonic = 'mnemonic';
  static const String seedTypePrivateKey = 'priKey';
  static const String seedTypeNone = 'none';
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
    Map<String, WalletData> wallets =  Map<String, WalletData>();
    walletList.forEach((wallet) {
      wallets[wallet.id] = wallet;
    });
    return wallets;
  }

  @computed
  List<AccountData> get accountListAll {
    List<AccountData> accountList = [];
    walletList.where((wallet) => wallet.walletType != WalletStore.seedTypeNone).forEach((wallet) {
      accountList.addAll(wallet.accounts);
    });
    return accountList;
  }

  @computed
  List<AccountData> get watchModeAccountListAll {
    List<AccountData> accountList = [];
    walletList.where((wallet) => wallet.walletType == WalletStore.seedTypeNone).forEach((wallet) {
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
    return (walletList as List<WalletData?>).firstWhere((element) => element!.walletType == WalletStore.seedTypeMnemonic, orElse: ()=> null);
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
    WalletData wallet = walletList.firstWhere((w) => w.accounts.indexWhere((account) => account.pubKey == pubKey) >= 0);
    var account = wallet.accounts.firstWhere((acc)=>acc.pubKey == pubKey);
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
    WalletData wallet = walletList.firstWhere((wallet) => wallet.id == newAccount.walletId);
    int index = wallet.accounts.indexWhere((account)=>account.pubKey == newAccount.pubKey);
    wallet.accounts.removeAt(index);
    wallet.accounts.insert(index, newAccount);
    await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    await loadWallet();
  }
  @action
  Future<void> clearWallets() async {
    await rootStore.localStorage.clearWallets();
    await rootStore.localStorage.setCurrentAccount('');
    await rootStore.localStorage.setCurrentWallet('');
    await rootStore.secureStorage.clearSeeds();
    await loadWallet();
  }
  @action
  Future<void> addAccount(Map<String, dynamic> acc, String accountName, WalletData wallet) async {
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
    await rootStore.localStorage.setCurrentAccount(pubKey);
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
    if (wallet.walletType == WalletStore.seedTypeMnemonic){
      return decryptSeed(wallet.id,  WalletStore.seedTypeMnemonic, password);
    } else {
      return null;
    }
  }

  Future<String?> getPrivateKey(WalletData wallet, String password) async {
    var pri =  await decryptSeed(wallet.id,  WalletStore.seedTypePrivateKey, password);
    return pri;
  }

  int getNextWalletIndexOfType(String walletType) {
    int index = 0;
    var typeWallets = walletList.where((w) => w.walletType == walletType).toList();
    typeWallets.forEach((w) {
      if (w.walletTypeIndex >= index) {
        index = w.walletTypeIndex + 1;
      }
    });
    return index;
  }

  @action
  Future<WalletResult> addWallet(Map<String, dynamic> walletInfo, String? password, {
    required BuildContext context,
    required String seedType,
    required String? walletSource,
  }) async {
    String pubKey = walletInfo['pubKey'];
    int hdIndex = walletInfo.containsKey('hdIndex') ? walletInfo['hdIndex'] : 0;
    String? name =  walletInfo['name'];
    String source = walletSource != null && walletSource.isNotEmpty ? walletSource : WalletSource.inside;
    int index = walletList.indexWhere((i) => i.pubKey == pubKey);
    if (index >= 0) {
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
    } else if(seedType == WalletStore.seedTypePrivateKey){
      await saveSeed(WalletStore.seedTypePrivateKey);
    }
    walletInfo.remove(WalletStore.seedTypeMnemonic);
    walletInfo.remove(WalletStore.seedTypePrivateKey);
    
    var accountData = new AccountData()
      ..pubKey = pubKey
      ..name = name ?? ""
      ..walletId = pubKey
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..accountIndex = hdIndex;
    
    var walletData = new WalletData()
      ..walletType = seedType
      ..walletTypeIndex = walletList.where((w) => w.walletType == seedType).toList().length
      ..id = pubKey
      ..source = source
      ..createTime = DateTime.now().millisecondsSinceEpoch
      ..accounts = [
        accountData
      ]
      ..currentAccountIndex = 0;

    await rootStore.localStorage.addWallet(WalletData.toJson(walletData));
    await rootStore.localStorage.setCurrentWallet(pubKey);

    await loadWallet();
    return WalletResult.success;
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    WalletData wallet = walletList.firstWhere((wallet) => wallet.id == acc.walletId);
    wallet.accounts.removeWhere((account) => account.pubKey == acc.pubKey);

    // delete wallet if no account left
    if (wallet.accounts.length == 0) {
      // remove encrypted seed after removing account
      await rootStore.localStorage.removeWallet(wallet.id);
      deleteSeed(WalletStore.seedTypeMnemonic, wallet.id);
      deleteSeed(WalletStore.seedTypePrivateKey, wallet.id);
      if (walletList.length > 0) {
        rootStore.localStorage.setCurrentWallet(walletList[0].id);
      }
    } else {
      wallet.currentAccountIndex = wallet.accounts[0].accountIndex;
      await rootStore.localStorage.updateWallet(WalletData.toJson(wallet));
    }
    await loadWallet();
  }

  @action
  Future<void> loadWallet() async {
    List<Map<String, dynamic>> accList = await rootStore.localStorage.getWalletList();
    walletList = ObservableList.of(accList.map((i) => WalletData.fromJson(i)));
    var _currentWalletId = await rootStore.localStorage.getCurrentWallet();
    if (_currentWalletId != null) {
      currentWalletId = _currentWalletId;
    } else if(walletList.length > 0){
      currentWalletId = walletList[0].id;
    }
    loading = false;
  }


  @action
  Future<void> encryptSeed(
      String pubKey, String seed, String seedType, String password) async {
    var encryption = Encryption();
    Map<String, dynamic> encryptedSeed = await encryption.encrypt(content: seed, password: password);
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    stored[pubKey] = encryptedSeed;
    rootStore.secureStorage.setSeeds(seedType, stored);
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
    String? decryptedStr = await encryption.decrypt(data: encrypted, password:password);
    var seedData = SeedData.fromJson(encrypted);
    if (decryptedStr != null && seedData.version != 2) {
      await encryptSeed(pubKey, decryptedStr, seedType, password);
    }
    return decryptedStr;
  }

  @action
  Future<bool> checkSeedExist(String seedType, String pubKey) async {
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    String? encrypted = stored[pubKey];
    return encrypted != null;
  }



  @action
  Future<bool> checkPassword(String pubKey, String seedType, String password) async {
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

  Future<void> updateAllWalletSeed(String passwordOld, String passwordNew) async {
    try {
      for (var i = 0; i < walletList.length; i++) {
        var wallet = walletList[i];
        await updateSeed(wallet.id, passwordOld, passwordNew);
      }
    } catch(x) {
      print('111');
      print(x);
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
    String? seed = await encryption.decrypt(data: encryptedSeed!, password: passwordOld);
    if (seed != null) {
      encryptSeed(pubKey, seed, seedType, passwordNew);
    }
  }

  @action
  Future<void> deleteSeed(String seedType, String pubKey) async {
    Map stored = await rootStore.secureStorage.getSeeds(seedType);
    if (stored[pubKey] != null) {
      stored.remove(pubKey);
      rootStore.secureStorage.setSeeds(seedType, stored);
    }
  }

  bool hasWatchModeWallet() {
    return  walletList.any((element) => element.walletType == WalletStore.seedTypeNone);
  }

}




