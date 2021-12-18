import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/common/components/willPopScopWrapper.dart';
import 'package:auro_wallet/common/components/splashScreen.dart';
import 'package:auro_wallet/common/consts/settings.dart';
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
import 'package:auro_wallet/page/settings/remoteNodeListPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/service/notification.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/theme.dart';

import 'utils/i18n/index.dart';
import 'common/theme.dart';

import 'package:auro_wallet/page/homePage.dart';
import 'package:auro_wallet/page/account/setNewWalletPasswordPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicPage.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicTipsPage.dart';
import 'package:auro_wallet/page/account/import/importMnemonicPage.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:auro_wallet/page/account/createAccountEntryPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/contactListPage.dart';
import 'package:auro_wallet/page/settings/security/securityPage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/page/staking/delegatePage.dart';
import 'package:auro_wallet/page/account/termPage.dart';
import 'package:auro_wallet/page/account/import/importWatchedAccountPage.dart';
import 'package:auro_wallet/page/rootAlertPage.dart';
import 'package:trust_fall/trust_fall.dart';





class WalletApp extends StatefulWidget {
  const WalletApp();
  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  _WalletAppState();
  AppStore? _appStore;
  Locale _locale = const Locale('en', '');

  ThemeData _theme = appTheme;
  bool _isDangerous = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
      isJailBroken = await TrustFall.isJailBroken;
      isRealDevice = await TrustFall.isRealDevice;
    } catch(e) {
      isJailBroken = true;
    }
    if(isJailBroken || !isRealDevice) {
      setState((){
        _isDangerous = true;
      });
    }
  }

  void _changeLang(BuildContext context, String code) {
    Locale res;
    switch (code) {
      case 'zh':
        res = const Locale('zh', '');
        break;
      case 'en':
        res = const Locale('en', '');
        break;
      default:
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
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> dic = I18n.of(context).main;
        return CupertinoAlertDialog(
          title: Container(),
          content: Text('${dic['copySuccess']!}'),
        );
      },
    );

    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    webApi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auro Wallet',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizationsDelegate(_locale),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      initialRoute: HomePage.route,
      theme: _theme,
      builder: EasyLoading.init(builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: _isDangerous ? RootAlertPage() : child ?? Container(),
          ),
        );
      }),
      routes: {
        HomePage.route: (context) => WillPopScopWrapper(
          child: FutureBuilder<int>(
            future: _initStore(context),
            builder: (_, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data! > 0 ? HomePage(_appStore!) : CreateAccountEntryPage(_appStore!.settings!, _changeLang);
              } else {
                return SplashScreen();
              }
            },
          ),
        ),

        // wallet
        CreateAccountEntryPage.route: (_) => CreateAccountEntryPage(_appStore!.settings!, _changeLang),
        SetNewWalletPasswordPage.route: (_) => SetNewWalletPasswordPage(_appStore!),
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
        TermPage.route: (_) => TermPage(_appStore!),
        ImportWatchedAccountPage.route: (_) => ImportWatchedAccountPage(_appStore!),

        // assets
        TransferPage.route: (_) => TransferPage(_appStore!),
        ReceivePage.route: (_) => ReceivePage(_appStore!),
        TransactionDetailPage.route: (_) => TransactionDetailPage(_appStore!),

        // setting
        AccountManagePage.route: (_) => AccountManagePage(_appStore!),
        ChangePasswordPage.route: (_) => ChangePasswordPage(_appStore!.wallet!),
        ExportResultPage.route: (_) => ExportResultPage(),
        RemoteNodeListPage.route: (_) => RemoteNodeListPage(_appStore!.settings!),
        AboutPage.route: (_) => AboutPage(_appStore!),
        LocalesPage.route: (_) => LocalesPage(_appStore!.settings!, _changeLang),
        CurrenciesPage.route: (_) => CurrenciesPage(_appStore!.settings!),
        ContactListPage.route: (_) => ContactListPage(_appStore!.settings!),
        SecurityPage.route: (_) => SecurityPage(_appStore!),
        ExportMnemonicResultPage.route: (_) => ExportMnemonicResultPage(),

        // staking
        DelegatePage.route: (_) => DelegatePage(_appStore!),
        ValidatorsPage.route: (_) => ValidatorsPage(_appStore!),
      },
    );
  }
}
