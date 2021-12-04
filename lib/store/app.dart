import 'package:mobx/mobx.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/assets/assets.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:auro_wallet/utils/secureStorage.dart';

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
  bool isReady = false;

  SecureStorage secureStorage = SecureStorage();

  LocalStorage localStorage = LocalStorage();

  _AppStore() {
    localStorage.setSecureStorage(secureStorage);
  }

  @action
  Future<void> init(String sysLocaleCode) async {
    await localStorage.checkMigrate();

    // wait settings store loaded
    try {
      settings = SettingsStore(this as AppStore);
      await settings!.init();
    } catch (e) {
      print(e);
    }

    staking = StakingStore(this as AppStore);
    try{
      await staking!.init();
    } catch(e) {
      print(e);
    }

    wallet = WalletStore(this as AppStore);
    await wallet!.loadWallet();

    assets = AssetsStore(this as AppStore);

    await assets!.loadCache();

    isReady = true;
  }
}
