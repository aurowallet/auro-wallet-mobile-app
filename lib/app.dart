import 'dart:math';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:auro_wallet/page/settings/contact/contactEditPage.dart';
import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:auro_wallet/common/components/willPopScopWrapper.dart';
import 'package:auro_wallet/page/account/scanPage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/page/account/import/importPrivateKeyPage.dart';
import 'package:auro_wallet/page/account/import/importWaysPage.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/transactionDetail/transactionDetailPage.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/settings/aboutPage.dart';
import 'package:auro_wallet/page/account/accountNamePage.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';
import 'package:auro_wallet/page/settings/security/changePasswordPage.dart';
import 'package:auro_wallet/page/account/import/importKeyStorePage.dart';
import 'package:auro_wallet/page/account/exportResultPage.dart';
import 'package:auro_wallet/page/settings/nodes/remoteNodeListPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/common/theme.dart';


import 'package:auro_wallet/page/homePage.dart';
import 'package:auro_wallet/page/account/setNewWalletPasswordPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicTipsPage.dart';
import 'package:auro_wallet/page/account/import/importMnemonicPage.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/page/account/createAccountEntryPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/contact/contactListPage.dart';
import 'package:auro_wallet/page/settings/security/securityPage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/page/staking/delegatePage.dart';
import 'package:auro_wallet/page/account/import/importWatchedAccountPage.dart';
import 'package:auro_wallet/page/rootAlertPage.dart';
import 'package:safe_device/safe_device.dart';

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  _WalletAppState();

  AppStore? _appStore;
  Locale? _locale;

  ThemeData _theme = appTheme;
  bool _isDangerous = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectDanger();
    });
    super.initState();
  }

  void _detectDanger() async {
    if (!Foundation.kReleaseMode) {
      return;
    }
    bool isJailBroken = false;
    bool isRealDevice = true;
    try {
      isJailBroken = await SafeDevice.isJailBroken;
      isRealDevice = await SafeDevice.isRealDevice;
    } catch (e) {
      isJailBroken = true;
    }
    if (isJailBroken || !isRealDevice) {
      setState(() {
        _isDangerous = true;
      });
    }
  }

  void _changeLang(BuildContext context, String code) {
    Locale res;
    if (code.isNotEmpty && AppLocalizations.supportedLocales.any((locale) => locale.languageCode == code)) {
      res = new Locale(code, '');
    } else {
      res = Localizations.localeOf(context);
    }
    setState(() {
      _locale = res;
    });
  }

  Future<int> _initStore(BuildContext context) async {
    if (_appStore == null) {
      _appStore = globalAppStore;
      print('initailizing app state');
      print('sys locale: ${Localizations.localeOf(context)}');
      await _appStore!.init(Localizations.localeOf(context).toString());
      // init webApi after store initiated
      webApi = Api(context, _appStore!);
      webApi.init();
      _changeLang(context, _appStore!.settings!.localeCode);
    }
    return _appStore!.wallet!.walletListAll.length;
  }

  @override
  void dispose() {
    webApi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auro Wallet',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: HomePage.route,
      theme: _theme,
      builder: EasyLoading.init(builder: (BuildContext context, Widget? child) {
        final size = MediaQuery.of(context).size;
        final factor = max(min(size.width / 375, 2.0), 1.0);
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: TooltipVisibility(
            visible: false,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: factor),
              child: _isDangerous ? RootAlertPage() : child ?? Container(),
            ),
          ),
        );
      }),
      routes: {
        HomePage.route: (context) => WillPopScopWrapper(
              child: FutureBuilder<int>(
                future: _initStore(context),
                builder: (_, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData) {
                    FlutterNativeSplash.remove();
                    return snapshot.data! > 0
                        ? HomePage(_appStore!)
                        : CreateAccountEntryPage(
                            _appStore!.settings!, _changeLang);
                  } else {
                    return Container();
                    // return SplashScreen();
                  }
                },
              ),
            ),

        // wallet
        CreateAccountEntryPage.route: (_) =>
            CreateAccountEntryPage(_appStore!.settings!, _changeLang),
        SetNewWalletPasswordPage.route: (_) =>
            SetNewWalletPasswordPage(_appStore!),
        BackupMnemonicTipsPage.route: (_) => BackupMnemonicTipsPage(_appStore!),
        WalletManagePage.route: (_) => WalletManagePage(_appStore!),
        ImportPrivateKeyPage.route: (_) => ImportPrivateKeyPage(_appStore!),
        ImportKeyStorePage.route: (_) => ImportKeyStorePage(_appStore!),
        ImportWaysPage.route: (_) => ImportWaysPage(_appStore!),
        AccountNamePage.route: (_) => AccountNamePage(_appStore!),
        BackupMnemonicPage.route: (_) => BackupMnemonicPage(_appStore!),
        ImportMnemonicPage.route: (_) => ImportMnemonicPage(_appStore!),
        ImportSuccessPage.route: (_) => ImportSuccessPage(_appStore!),
        ScanPage.route: (_) => ScanPage(),
        ImportWatchedAccountPage.route: (_) =>
            ImportWatchedAccountPage(_appStore!),
        LedgerAccountNamePage.route: (_) => LedgerAccountNamePage(_appStore!),

        // assets
        TransferPage.route: (_) => TransferPage(_appStore!),
        ReceivePage.route: (_) => ReceivePage(_appStore!),
        TransactionDetailPage.route: (_) => TransactionDetailPage(_appStore!),

        // setting
        AccountManagePage.route: (_) => AccountManagePage(_appStore!),
        ChangePasswordPage.route: (_) => ChangePasswordPage(_appStore!.wallet!),
        ExportResultPage.route: (_) => ExportResultPage(),
        RemoteNodeListPage.route: (_) => RemoteNodeListPage(_appStore!),
        NodeEditPage.route: (_) => NodeEditPage(_appStore!.settings!),
        AboutPage.route: (_) => AboutPage(_appStore!),
        LocalesPage.route: (_) =>
            LocalesPage(_appStore!.settings!, _changeLang),
        CurrenciesPage.route: (_) => CurrenciesPage(_appStore!.settings!),
        ContactListPage.route: (_) => ContactListPage(_appStore!.settings!),
        ContactEditPage.route: (_) => ContactEditPage(_appStore!.settings!),
        SecurityPage.route: (_) => SecurityPage(_appStore!),
        ExportMnemonicResultPage.route: (_) => ExportMnemonicResultPage(),
        // staking
        DelegatePage.route: (_) => DelegatePage(_appStore!),
        ValidatorsPage.route: (_) => ValidatorsPage(_appStore!),
      },
    );
  }
}
