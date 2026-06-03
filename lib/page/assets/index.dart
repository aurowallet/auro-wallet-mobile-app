import 'dart:async';

import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/account/scanPage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/token/component/TokenListView.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/testKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Assets extends StatefulWidget {
  Assets(this.store);

  final AppStore store;

  @override
  _AssetsState createState() => _AssetsState(store);
}

class _AssetsState extends State<Assets> with WidgetsBindingObserver {
  _AssetsState(this.store);

  final AppStore store;
  Timer? _refreshTimer;
  bool _isNetworkDialogOpen = false;
  final GlobalKey<RefreshIndicatorState> _balanceRefreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool showIndicator = store.assets!.tokenList.length == 0;
      store.setBalanceRefreshKey(_balanceRefreshKey);
      this._onRefresh(showIndicator: showIndicator);
      _checkWatchMode();
      WidgetsBinding.instance.addObserver(this);
    });
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _onRefresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    store.setBalanceRefreshKey(null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    var isInForeground = state == AppLifecycleState.resumed;
    if (isInForeground) {
      bool showIndicator = store.assets!.tokenList.length == 0;
      this._onRefresh(showIndicator: showIndicator);
    }
  }

  Future<void> _onRefresh({showIndicator = false}) async {
    if (showIndicator || store.assets!.tokenList.isEmpty) {
      store.assets!.setAssetsLoading(true);
    }
    await Future.wait([
      webApi.assets.fetchAllTokenAssets(showIndicator: showIndicator),
    ]);
    store.assets!.setAssetsLoading(false);
  }

  void _onReceive() {
    Navigator.pushNamed(context, ReceivePage.route);
  }

  void _onTransfer() {
    UI.showTokenSelectDialog(context: context);
  }

  void _onConfirmDeleteWatchWallet() async {
    await Navigator.of(context).pushNamed(WalletManagePage.route);
    this._checkWatchMode();
  }

  void _checkWatchMode() {
    if (store.wallet!.hasWatchModeWallet()) {
      Future.delayed(Duration(milliseconds: 600), () async {
        AppLocalizations dic = AppLocalizations.of(context)!;
        await UI.showAlertDialog(
            context: context,
            barrierDismissible: false,
            disableBack: true,
            contents: [
              dic.watchModeWarn2,
            ],
            confirm: dic.deleteWatch,
            onConfirm: () {
              this._onConfirmDeleteWatchWallet();
            });
      });
    }
  }

  Future<void> _showNetworkDialog() async {
    if (_isNetworkDialogOpen) {
      return;
    }
    setState(() {
      _isNetworkDialogOpen = true;
    });
    await UI.showNetworkSelectDialog(context: context);
    if (!mounted) {
      return;
    }
    setState(() {
      _isNetworkDialogOpen = false;
    });
  }

  Widget _buildNetworkEntry(BuildContext context) {
    String networkName = widget.store.settings!.currentNode!.name;
    return InkWell(
        onTap: _showNetworkDialog,
        child: Container(
          padding: const EdgeInsets.only(left: 14, top: 6, right: 8, bottom: 6),
          decoration: BoxDecoration(
            border: new Border.all(color: Color(0x1A000000), width: 1),
            borderRadius: BorderRadius.circular(45),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Fmt.stringSlice(networkName, 12, withEllipsis: true),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000)),
              ),
              SizedBox(
                width: 8,
              ),
              SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: AnimatedRotation(
                    turns: _isNetworkDialogOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: SvgPicture.asset(
                      'assets/images/assets/icon_arrow_unfold.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildTopBar(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      color: Color(0xFFEDEFF2),
      child: Padding(
        padding: EdgeInsets.only(left: 20, top: 12, right: 15, bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dic.myWallet,
              style: theme.displayLarge!.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(child: _buildNetworkEntry(context)),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    key: TestKeys.walletManageIcon,
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).pushNamed(WalletManagePage.route);
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/assets/wallet_manage.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onScan() async {
    var params = {"isScanWc": true};
    var result = await Navigator.of(context).pushNamed(
      ScanPage.route,
      arguments: params,
    );
    if (result == null) return;
    String address = (result as QRCodeAddressResult).address;
    if (!store.walletConnectService!.isInitialized) {
      await store.walletConnectService!.init();
    }
    await store.walletConnectService!.pair(Uri.parse(address));
  }

  Widget _buildTopCard(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    WalletData acc = store.wallet!.currentWallet;
    var currency = currencyConfig
        .firstWhere((element) => element.key == store.settings!.currencyCode);
    var currencySymbol = currency.symbol;
    Color amountColor =
        (store.assets!.isAssetsLoading) ? Color(0xFFDDDDDD) : Color(0xFFFFFFFF);
    String networkID = store.settings!.currentNode?.networkID ?? "";
    bool isZekoNet = store.settings!.isZekoNet;
    String nextNetIcon = isZekoNet
        ? "assets/images/assets/icon_zeko_mainnet.svg"
        : "assets/images/assets/icon_mina.svg";

    int chainColor = 0x4C000000;
    if (networkID == networkIDMap.mainnet) {
      chainColor = 0xFF594AF1;
    } else if (networkID == networkIDMap.zeko) {
      chainColor = 0xFFE7B13F;
      nextNetIcon = "assets/images/assets/icon_zeko_mainnet.svg";
    }

    final buttonTextStyle = TextStyle(
        fontSize: 16,
        color: Color(chainColor),
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3);
    String totalAmount = store.assets!.getTokenTotalAmount();
    String showAmount = currencySymbol + " " + totalAmount;
    return Container(
      color: Color(0xFFEDEFF2),
      padding: EdgeInsets.only(bottom: 30, right: 20),
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 4, 0, 0),
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Color(chainColor)),
        child: Stack(children: [
          Positioned(
              right: 20,
              top: 50,
              child: SvgPicture.asset(
                nextNetIcon,
                width: 99,
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 15, right: 20, left: 20),
                child: Column(children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: new Text(
                          Fmt.accountName(acc.currentAccount),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: CopyContainer(
                            iconColor: const Color(0x80FFFFFF),
                            child: Container(
                              child: Text(
                                Fmt.address(store.wallet!.currentAddress,
                                    pad: 10),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: const Color(0x80FFFFFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            text: store.wallet!.currentAddress),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          showAmount,
                          key: TestKeys.balanceDisplay,
                          style: TextStyle(
                              fontSize: 32,
                              color: amountColor,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Container(
                      height: 40.0,
                      // constraints: BoxConstraints(maxWidth: 140),
                      child: NormalButton(
                        key: TestKeys.sendButton,
                        color: Colors.white,
                        text: dic.send,
                        textStyle: buttonTextStyle,
                        onPressed: _onTransfer,
                        icon: SvgPicture.asset('assets/images/assets/send.svg',
                            width: 10,
                            colorFilter: ColorFilter.mode(
                                Color(chainColor), BlendMode.srcIn)),
                        padding: EdgeInsets.zero,
                        radius: 24,
                      ),
                    )),
                    SizedBox(
                      width: 15,
                    ),
                    Flexible(
                        child: Container(
                            height: 40,
                            // constraints: BoxConstraints(maxWidth: 140),
                            child: NormalButton(
                              color: Colors.white,
                              text: dic.receive,
                              textStyle: buttonTextStyle,
                              onPressed: _onReceive,
                              icon: SvgPicture.asset(
                                  'assets/images/assets/receive.svg',
                                  width: 10,
                                  colorFilter: ColorFilter.mode(
                                      Color(chainColor), BlendMode.srcIn)),
                              padding: EdgeInsets.zero,
                              radius: 24,
                            ))),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                icon: SvgPicture.asset('assets/images/assets/scanner.svg',
                    width: 20,
                    height: 20,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                onPressed: _onScan,
              )),
        ]),
      ),
    );
  }

  Widget _buildTokenListView() {
    return TokenListView(store);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return RefreshIndicator(
          backgroundColor: Colors.white,
          color: Theme.of(context).primaryColor,
          key: _balanceRefreshKey,
          onRefresh: _onRefresh,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    _buildTopBar(context),
                    _buildTopCard(context),
                    _buildTokenListView(),
                  ],
                )),
          ),
        );
      },
    );
  }
}
