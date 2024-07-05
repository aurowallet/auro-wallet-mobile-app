import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/store/browser/browser.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:auro_wallet/utils/secureStorage.dart';

import 'ledger/ledger.dart';

part 'app.g.dart';

final AppStore globalAppStore = AppStore();

class AppStore extends _AppStore with _$AppStore {}

abstract class _AppStore with Store {
  @observable
  SettingsStore? settings;

  @observable
  WalletStore? wallet;

  @observable
  AssetsStore? assets;

  @observable
  StakingStore? staking;

  @observable
  LedgerStore? ledger;

  @observable
  BrowserStore? browser;

  @observable
  bool isReady = false;

  SecureStorage secureStorage = SecureStorage();

  LocalStorage localStorage = LocalStorage();

  @action
  Future<void> init(String sysLocaleCode) async {
    try {
      settings = SettingsStore(this as AppStore);
      await settings!.init();
    } catch (e) {
      print(e);
    }

    staking = StakingStore(this as AppStore);
    try {
      await staking!.init();
    } catch (e) {
      print(e);
    }

    wallet = WalletStore(this as AppStore);
    await wallet!.loadWallet();

    ledger = LedgerStore();

    assets = AssetsStore(this as AppStore);

    browser = BrowserStore(this as AppStore);

    try {
      await browser!.init();
    } catch (e) {
      print(e);
    }

    await assets!.loadCache();

    isReady = true;
  }
}