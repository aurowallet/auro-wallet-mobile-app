// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$settingsAtom =
      Atom(name: '_AppStore.settings', context: context);

  @override
  SettingsStore? get settings {
    _$settingsAtom.reportRead();
    return super.settings;
  }

  @override
  set settings(SettingsStore? value) {
    _$settingsAtom.reportWrite(value, super.settings, () {
      super.settings = value;
    });
  }

  late final _$walletAtom = Atom(name: '_AppStore.wallet', context: context);

  @override
  WalletStore? get wallet {
    _$walletAtom.reportRead();
    return super.wallet;
  }

  @override
  set wallet(WalletStore? value) {
    _$walletAtom.reportWrite(value, super.wallet, () {
      super.wallet = value;
    });
  }

  late final _$assetsAtom = Atom(name: '_AppStore.assets', context: context);

  @override
  AssetsStore? get assets {
    _$assetsAtom.reportRead();
    return super.assets;
  }

  @override
  set assets(AssetsStore? value) {
    _$assetsAtom.reportWrite(value, super.assets, () {
      super.assets = value;
    });
  }

  late final _$stakingAtom = Atom(name: '_AppStore.staking', context: context);

  @override
  StakingStore? get staking {
    _$stakingAtom.reportRead();
    return super.staking;
  }

  @override
  set staking(StakingStore? value) {
    _$stakingAtom.reportWrite(value, super.staking, () {
      super.staking = value;
    });
  }

  late final _$ledgerAtom = Atom(name: '_AppStore.ledger', context: context);

  @override
  LedgerStore? get ledger {
    _$ledgerAtom.reportRead();
    return super.ledger;
  }

  @override
  set ledger(LedgerStore? value) {
    _$ledgerAtom.reportWrite(value, super.ledger, () {
      super.ledger = value;
    });
  }

  late final _$browserAtom = Atom(name: '_AppStore.browser', context: context);

  @override
  BrowserStore? get browser {
    _$browserAtom.reportRead();
    return super.browser;
  }

  @override
  set browser(BrowserStore? value) {
    _$browserAtom.reportWrite(value, super.browser, () {
      super.browser = value;
    });
  }

  late final _$walletConnectServiceAtom =
      Atom(name: '_AppStore.walletConnectService', context: context);

  @override
  WalletConnectService? get walletConnectService {
    _$walletConnectServiceAtom.reportRead();
    return super.walletConnectService;
  }

  @override
  set walletConnectService(WalletConnectService? value) {
    _$walletConnectServiceAtom.reportWrite(value, super.walletConnectService,
        () {
      super.walletConnectService = value;
    });
  }

  late final _$isReadyAtom = Atom(name: '_AppStore.isReady', context: context);

  @override
  bool get isReady {
    _$isReadyAtom.reportRead();
    return super.isReady;
  }

  @override
  set isReady(bool value) {
    _$isReadyAtom.reportWrite(value, super.isReady, () {
      super.isReady = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_AppStore.init', context: context);

  @override
  Future<void> init(String sysLocaleCode) {
    return _$initAsyncAction.run(() => super.init(sysLocaleCode));
  }

  @override
  String toString() {
    return '''
settings: ${settings},
wallet: ${wallet},
assets: ${assets},
staking: ${staking},
ledger: ${ledger},
browser: ${browser},
walletConnectService: ${walletConnectService},
isReady: ${isReady}
    ''';
  }
}
