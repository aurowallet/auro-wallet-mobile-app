import 'dart:async';
import 'dart:math';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/addAccountPage.dart';
import 'package:auro_wallet/page/account/ledgerAccountNamePage.dart';
import 'package:auro_wallet/page/account/connectHardwareWalletIntroPage.dart';
import 'package:auro_wallet/page/account/selectHDPathPage.dart';
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
import 'package:auro_wallet/service/tx_status_monitor.dart';
import 'package:auro_wallet/service/notification_service.dart';
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
import 'package:auro_wallet/page/account/walletDetailsPage.dart';
import 'package:auro_wallet/page/account/addWalletPage.dart';
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
import 'package:auro_wallet/page/settings/Dev/devPage.dart';
import 'package:auro_wallet/page/settings/Dev/TransactionPage.dart';
import 'package:auro_wallet/page/settings/contact/contactListPage.dart';
import 'package:auro_wallet/page/settings/security/securityPage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/staking/validatorsPage.dart';
import 'package:auro_wallet/page/staking/delegatePage.dart';
import 'package:auro_wallet/page/account/import/importWatchedAccountPage.dart';
import 'package:auro_wallet/page/rootAlertPage.dart';
import 'package:safe_device/safe_device.dart';
import 'package:app_links/app_links.dart';
import 'package:auro_wallet/page/settings/preferences/preferencesPage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mobx/mobx.dart' as mobx;

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
  BuildContext? _homePageContext;
  bool _storeReady = false;
  bool _pendingNotificationConsumed = false;
  bool _isNavigatingToTxDetail = false;
  Timer? _navigatingResetTimer;
  Map<String, String>? _deferredLockedPayload;
  Map? appLinkRouteParams;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _lockPagePushed = false;
  bool _inlineLockShowing = false;
  DateTime? _lastPausedTime;
  static const int _lockThresholdSeconds = 3;
  Future<int>? _initFuture;
  mobx.ReactionDisposer? _walletEmptyReaction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectDanger();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_storeReady) return;
    if (state == AppLifecycleState.paused) {
      if (_appStore?.settings != null && !webApi.account.isBiometricInProgress) {
        _lastPausedTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null && _appStore?.settings != null && !webApi.account.isBiometricInProgress) {
        final elapsed = DateTime.now().difference(_lastPausedTime!).inSeconds;
        if (elapsed >= _lockThresholdSeconds) {
          _appStore!.wallet!.clearRuntimePwd();
          if (webApi.account.getAppAccessEnabled()) {
            _appStore!.settings!.setLockWalletStatus(true);
          }
        }
        _lastPausedTime = null;
      }
      final lockCheck = initLockCheck();
      final biometricActive = webApi.account.isBiometricInProgress;
      if (lockCheck && !_lockPagePushed && !_inlineLockShowing && !biometricActive) {
        _lockPagePushed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nav = _navigatorKey.currentState;
          if (nav != null) {
            try {
              nav.pushNamed(LockWalletPage.route).then((_) {
                _lockPagePushed = false;
              }).catchError((e) {
                _lockPagePushed = false;
              });
            } catch (e) {
              _lockPagePushed = false;
            }
          } else {
            _lockPagePushed = false;
          }
        });
      }
    }
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
    if (_appStore?.settings == null) {
      return {"action": action, "url": decodedURL, "networkId": null};
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
    bool isWalletConnectLink = false;
    String? scheme;
    if (host == "wc" && wcUri != null && wcUri.isNotEmpty) {
      scheme = uri.queryParameters['scheme'];
      isWalletConnectLink = true;
    } else if (uri.scheme == 'https' &&
        host.endsWith(
            '.aurowallet.com') && 
        uri.queryParameters['action'] == 'wc' &&
        wcUri != null &&
        wcUri.isNotEmpty) {
      scheme = uri.queryParameters['scheme'];
      isWalletConnectLink = true;
    }
    if (isWalletConnectLink && wcUri != null) {
      _appStore?.walletConnectService!.setTempScheme(scheme);
      await _appStore?.walletConnectService!.pair(Uri.parse(wcUri));
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
      await _appStore!.init(Localizations.localeOf(context).toString());
      _appStore!.walletConnectService!.setContext(context);
      webApi = Api(context, _appStore!);
      await webApi.init();
      TxStatusMonitor().ensureLifecycleObserving();
      _changeLang(context, _appStore!.settings!.localeCode);
      _storeReady = true;
      if (webApi.account.getAppAccessEnabled()) {
        _appStore!.settings!.setLockWalletStatus(true);
      }
      NotificationService().onNotificationTap = _handleNotificationTap;
      _walletEmptyReaction = mobx.reaction(
        (_) => _appStore!.wallet!.walletList.isEmpty,
        (bool isEmpty) {
          if (isEmpty && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await webApi.account.resetAllSecurityFlags();
              _appStore!.wallet!.clearRuntimePwd();
              _appStore!.settings!.setLockWalletStatus(false);
              _appStore!.walletConnectService?.clearAllPairings();
              if (mounted) Phoenix.rebirth(context);
            });
          }
        },
      );
    }
    return _appStore!.wallet!.walletListAll.length;
  }

  void _handleNotificationTap(Map<String, String> payload, [int attempt = 0]) {
    const maxAttempts = 10;
    final txHash = payload['hash'];
    if (txHash == null || txHash.isEmpty) return;
    if (!isValidMinaTxHash(txHash)) return;
    if (!_storeReady || _appStore == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final homeCtx = _homePageContext;
      if (homeCtx == null || !homeCtx.mounted) {
        if (attempt < maxAttempts) {
          _handleNotificationTap(payload, attempt + 1);
        }
        return;
      }

      if (initLockCheck()) {
        _deferredLockedPayload = payload;
        return;
      }

      _navigateToTxDetail(homeCtx, payload);
    });
  }

  void _navigateToTxDetail(BuildContext ctx, Map<String, String> payload) {
    final txHash = payload['hash'];
    if (txHash == null || txHash.isEmpty) return;
    if (!ctx.mounted) return;
    if (_isNavigatingToTxDetail) {
      NotificationService().cancelNotification(NotificationService.notificationIdForHash(txHash));
      return;
    }
    _isNavigatingToTxDetail = true;
    _navigatingResetTimer?.cancel();
    _navigatingResetTimer = Timer(const Duration(seconds: 10), () {
      _isNavigatingToTxDetail = false;
    });

    NotificationService().cancelNotification(NotificationService.notificationIdForHash(txHash));

    try {
      Navigator.of(ctx).pushNamed(
        TransactionDetailPage.route,
        arguments: {
          'txHash': txHash,
          if (payload['txUrl'] != null && payload['txUrl']!.isNotEmpty)
            'txUrl': payload['txUrl'],
          if (payload['explorerUrl'] != null && payload['explorerUrl']!.isNotEmpty)
            'explorerUrl': payload['explorerUrl'],
          if (payload['senderAddress'] != null && payload['senderAddress']!.isNotEmpty)
            'senderAddress': payload['senderAddress'],
          if (payload['isZeko'] == 'true')
            'isZeko': true,
        },
      ).then((_) {
        _navigatingResetTimer?.cancel();
        _isNavigatingToTxDetail = false;
      }).catchError((_) {
        _navigatingResetTimer?.cancel();
        _isNavigatingToTxDetail = false;
      });
    } catch (_) {
      _navigatingResetTimer?.cancel();
      _isNavigatingToTxDetail = false;
    }
  }

  void _replayDeferredPayload(Map<String, String> payload, [int attempt = 0]) {
    const maxAttempts = 10;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (initLockCheck()) {
        _deferredLockedPayload = payload;
        return;
      }
      final homeCtx = _homePageContext;
      if (homeCtx != null && homeCtx.mounted) {
        _navigateToTxDetail(homeCtx, payload);
      } else if (attempt < maxAttempts) {
        _replayDeferredPayload(payload, attempt + 1);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _walletEmptyReaction?.call();
    _navigatingResetTimer?.cancel();
    NotificationService().onNotificationTap = null;
    webApi.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _doAutoRouting(BuildContext context, bool isFromLockPage) async {
    final bool hadAppLink = appLinkRouteParams != null;
    if (appLinkRouteParams != null) {
      if (!_storeReady || _appStore == null) {
        return;
      }
      final homeCtx = _homePageContext;
      if (homeCtx == null) {
        return;
      }
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
      AppLocalizations dic = AppLocalizations.of(homeCtx)!;
      bool? rejected = await UI.showConfirmDialog(
          context: homeCtx,
          title: dic.zkAppTipTitle,
          contents: [appLinkRouteParams!['url'] + '\n', dic.zkAppTipContent],
          okText: dic.isee,
          cancelText: dic.cancel);
      if (rejected != true) {
        return;
      }
      bool isBrowserWrapperPageOpened = false;
      Navigator.of(homeCtx).popUntil((route) {
        if (route.settings.name == BrowserWrapperPage.route) {
          isBrowserWrapperPageOpened = true;
        }
        return true;
      });
      if (isBrowserWrapperPageOpened) {
        Navigator.of(homeCtx).pushReplacementNamed(
          BrowserWrapperPage.route,
          arguments: {"url": appLinkRouteParams!['url']},
        );
      } else {
        Navigator.of(homeCtx).pushNamed(
          BrowserWrapperPage.route,
          arguments: {"url": appLinkRouteParams!['url']},
        );
      }
      String? currentNetworkID = _appStore!.settings!.currentNode?.networkID;
      if (appLinkRouteParams!['networkId'] != null &&
          currentNetworkID != appLinkRouteParams!['networkId']) {
        await UI.showSwitchChainAction(
            context: homeCtx,
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

    if (_deferredLockedPayload != null && isFromLockPage && !hadAppLink) {
      final payload = _deferredLockedPayload!;
      _deferredLockedPayload = null;
      _replayDeferredPayload(payload);
    }
  }

  bool initLockCheck() {
    if (_appStore?.settings == null) return false;
    final isAppAccessOpen = webApi.account.getAppAccessEnabled();
    return isAppAccessOpen && _appStore!.settings!.lockWalletStatus;
  }

  @override
  Widget build(BuildContext context) {
    if (appLinkRouteParams != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _doAutoRouting(context, false));
    }
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
        final mainContent = GestureDetector(
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
        return mainContent;
      }),
      routes: {
        HomePage.route: (context) => WillPopScopWrapper(
              child: FutureBuilder<int>(
                future: _initFuture ??= _initStore(context),
                builder: (_, AsyncSnapshot<int> snapshot) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _homePageContext = context;
                  });
                  if (snapshot.hasData) {
                    if (!_pendingNotificationConsumed) {
                      _pendingNotificationConsumed = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        NotificationService().consumePendingNotification();
                      });
                    }
                    FlutterNativeSplash.remove();
                    final walletCount = _appStore!.wallet!.walletListAll.length;
                    if (walletCount > 0) {
                      bool isOpen = initLockCheck() && !_lockPagePushed;
                      if (isOpen) {
                        _inlineLockShowing = true;
                        return LockWalletPage(_appStore!,
                            unLockCallBack: _doAutoRouting);
                      } else {
                        _inlineLockShowing = false;
                        return HomePage(_appStore!);
                      }
                    } else {
                      return CreateAccountEntryPage(
                          _appStore!.settings!, _changeLang);
                    }
                  } else {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF594AF1),
                        ),
                      ),
                    );
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
        WalletDetailsPage.route: (_) => WalletDetailsPage(_appStore!),
        AddWalletPage.route: (_) => AddWalletPage(_appStore!),
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
        ConnectHardwareWalletIntroPage.route: (_) => ConnectHardwareWalletIntroPage(_appStore!),
        SelectHDPathPage.route: (_) => SelectHDPathPage(_appStore!),
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
        PreferencesPage.route: (_) => PreferencesPage(_appStore!),
        // for dev
        DevPage.route: (_) => DevPage(_appStore!),
        TransactionPage.route: (_) => TransactionPage(_appStore!),
      },
    );
  }
}
