import 'dart:async';
import 'dart:math';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/addAccountPage.dart';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:auro_wallet/page/account/LockWalletPage.dart';
import 'package:auro_wallet/page/assets/token/TokenDetail.dart';
import 'package:auro_wallet/page/browser/browserSearchPage.dart';
import 'package:auro_wallet/page/browser/browserWrapperPage.dart';
import 'package:auro_wallet/page/settings/contact/contactEditPage.dart';
import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:auro_wallet/page/settings/security/PasswordVerificationPage.dart';
import 'package:auro_wallet/page/settings/zkAppConnectPage.dart';
import 'package:auro_wallet/page/settings/WalletConnectPage.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/page/test/webviewTestPage.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/index.dart';
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
import 'package:app_links/app_links.dart';

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> with WidgetsBindingObserver {
  AppStore? _appStore;
  Locale? _locale;
  ThemeData _theme = appTheme;
  bool _isDangerous = false;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  late BuildContext _homePageContext;
  Map? appLinkRouteParams;

  @override
  void initState() {
    initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectDanger();
    });
    super.initState();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  Map? extractApplinksParameters(Uri uri) {
    String? action = uri.queryParameters['action'];
    String? encodedUrl = uri.queryParameters['url'];
    String decodedURL = Uri.decodeComponent(encodedUrl ?? "");
    if (!isValidHttpUrl(decodedURL)) {
      print('Not valid URL');
      return null;
    }
    String? nextNetworkId;
    String? networkId = uri.queryParameters['networkid'];
    List<String> currentSupportChainList =
        _appStore!.settings!.getSupportNetworkIDs();
    if (currentSupportChainList.contains(networkId)) {
      String? currentNetworkID = _appStore!.settings!.currentNode?.networkID;
      if (currentNetworkID != networkId) {
        nextNetworkId = networkId;
      }
    }
    return {"action": action, "url": decodedURL, "networkId": nextNetworkId};
  }

  Map? extractParameters(Uri uri) {
    try {
      String? action = uri.queryParameters['action'];
      if (action != 'openurl') {
        print('Not support action');
        return null;
      }
      if (action == 'openurl') {
        return extractApplinksParameters(uri);
      }
      return null;
    } catch (e) {
      print('Parameter parse error: ${e.toString()}');
      return null;
    }
  }

  Future<void> openAppLink(Uri uri) async {
    String? host = uri.host;
    String? wcUri = uri.queryParameters['uri'];
    if (host == "wc" && wcUri != null && wcUri.isNotEmpty) {
      String? scheme = uri.queryParameters['scheme'];
      _appStore?.walletConnectService!.setTempScheme(scheme);
      await _appStore?.walletConnectService!
          .pair(Uri.parse(wcUri));
      
      return;
    }

    Map? res = extractParameters(uri);
    if (res != null && res['action'] == 'openurl') {
      setState(() {
        appLinkRouteParams = res;
      });
    }
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
    if (code.isNotEmpty &&
        AppLocalizations.supportedLocales
            .any((locale) => locale.languageCode == code)) {
      res = Locale(code, '');
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
      print('initializing app state');
      print('sys locale: ${Localizations.localeOf(context)}');
      await _appStore!.init(Localizations.localeOf(context).toString());
      webApi = Api(context, _appStore!);
      await webApi.init();
      // print('[aurowallet]==WidgetsBinding===2, ${_appStore?.walletConnectService}');
      if (_appStore?.walletConnectService != null) {
        // print('[aurowallet]==WidgetsBinding===3,');
        _appStore!.walletConnectService!.init(_homePageContext);
      }

      _changeLang(context, _appStore!.settings!.localeCode);
    }
    return _appStore!.wallet!.walletListAll.length;
  }

  @override
  void dispose() {
    webApi.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _doAutoRouting(BuildContext context, bool isFromLockPage) async {
    if (appLinkRouteParams != null) {
      int walletLength = _appStore!.wallet!.walletListAll.length;
      if (walletLength == 0) {
        return;
      }
      if (!isFromLockPage) {
        bool isOpen = initLockCheck();
        if (isOpen) {
          return;
        }
      }
      AppLocalizations dic = AppLocalizations.of(_homePageContext)!;
      bool? rejected = await UI.showConfirmDialog(
          context: _homePageContext,
          title: dic.zkAppTipTitle,
          contents: [appLinkRouteParams!['url'] + '\n', dic.zkAppTipContent],
          okText: dic.isee,
          cancelText: dic.cancel);
      if (rejected != true) {
        return;
      }
      bool isBrowserWrapperPageOpened = false;
      Navigator.of(_homePageContext).popUntil((route) {
        if (route.settings.name == BrowserWrapperPage.route) {
          isBrowserWrapperPageOpened = true;
        }
        return true;
      });
      if (isBrowserWrapperPageOpened) {
        Navigator.of(_homePageContext).pushReplacementNamed(
          BrowserWrapperPage.route,
          arguments: {"url": appLinkRouteParams!['url']},
        );
      } else {
        Navigator.of(_homePageContext).pushNamed(
          BrowserWrapperPage.route,
          arguments: {"url": appLinkRouteParams!['url']},
        );
      }
      String? currentNetworkID = _appStore!.settings!.currentNode?.networkID;
      if (appLinkRouteParams!['networkId'] != null &&
          currentNetworkID != appLinkRouteParams!['networkId']) {
        await UI.showSwitchChainAction(
            context: _homePageContext,
            networkID: appLinkRouteParams!['networkId'],
            url: appLinkRouteParams!['url'],
            iconUrl: null,
            onConfirm: (String networkName, String networkID) async {
              await Future.wait([
                webApi.assets.fetchAllTokenAssets(),
                webApi.assets.queryTxFees(),
              ]);
              return;
            },
            onCancel: () {});
      }
      appLinkRouteParams = null;
    }
  }

  bool initLockCheck() {
    final isAppAccessOpen = webApi.account.getAppAccessEnabled();
    return isAppAccessOpen && _appStore!.settings!.lockWalletStatus;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _doAutoRouting(context, false));
    return MaterialApp(
      title: 'Auro Wallet',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
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
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(factor)),
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _homePageContext = context;
                  });
                  if (snapshot.hasData) {
                    FlutterNativeSplash.remove();
                    if (snapshot.data! > 0) {
                      bool isOpen = initLockCheck();
                      if (isOpen) {
                        return LockWalletPage(_appStore!,
                            unLockCallBack: _doAutoRouting);
                      } else {
                        return HomePage(_appStore!);
                      }
                    } else {
                      return CreateAccountEntryPage(
                          _appStore!.settings!, _changeLang);
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
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
        AddAccountPage.route: (_) => AddAccountPage(_appStore!),
        LockWalletPage.route: (_) => LockWalletPage(_appStore!),
        TransferPage.route: (_) => TransferPage(_appStore!),
        ReceivePage.route: (_) => ReceivePage(_appStore!),
        TransactionDetailPage.route: (_) => TransactionDetailPage(_appStore!),
        TokenDetailPage.route: (_) => TokenDetailPage(_appStore!),
        AccountManagePage.route: (_) => AccountManagePage(_appStore!),
        ChangePasswordPage.route: (_) => ChangePasswordPage(_appStore!.wallet!),
        ExportResultPage.route: (_) => ExportResultPage(),
        RemoteNodeListPage.route: (_) => RemoteNodeListPage(_appStore!),
        NodeEditPage.route: (_) => NodeEditPage(_appStore!),
        AboutPage.route: (_) => AboutPage(_appStore!),
        LocalesPage.route: (_) =>
            LocalesPage(_appStore!.settings!, _changeLang),
        CurrenciesPage.route: (_) => CurrenciesPage(_appStore!.settings!),
        ContactListPage.route: (_) => ContactListPage(_appStore!.settings!),
        ContactEditPage.route: (_) => ContactEditPage(_appStore!.settings!),
        SecurityPage.route: (_) => SecurityPage(_appStore!),
        ExportMnemonicResultPage.route: (_) => ExportMnemonicResultPage(),
        PasswordVerificationPage.route: (_) =>
            PasswordVerificationPage(_appStore!),
        DelegatePage.route: (_) => DelegatePage(_appStore!),
        ValidatorsPage.route: (_) => ValidatorsPage(_appStore!),
        Staking.route: (_) => Staking(_appStore!),
        WebviewBridgeTestPage.route: (_) => WebviewBridgeTestPage(),
        BrowserWrapperPage.route: (_) => BrowserWrapperPage(_appStore!),
        BrowserSearchPage.route: (_) => BrowserSearchPage(_appStore!),
        ZkAppConnectPage.route: (_) => ZkAppConnectPage(_appStore!),
        WalletConnectPage.route: (_) => WalletConnectPage(_appStore!),
      },
    );
  }
}