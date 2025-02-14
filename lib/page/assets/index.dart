import 'dart:async';

import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/token/component/TokenListView.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

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

  @override
  void ledgerSetup() async {
    final options = LedgerOptions(
      maxScanDuration: const Duration(milliseconds: 5000),
    );

    final ledger = Ledger(
      options: options,
      // onPermissionRequest: (status) async {
      //   // Location was granted, now request BLE
      //   Map<Permission, PermissionStatus> statuses = await [
      //     Permission.bluetoothScan,
      //     Permission.bluetoothConnect,
      //     Permission.bluetoothAdvertise,
      //   ].request();
      //
      //   if (status != BleStatus.ready) {
      //     return false;
      //   }
      //
      //   return statuses.values.where((status) => status.isDenied).isEmpty;
      // },
    );
    await ledger.close(ConnectionType.ble);
    await ledger.dispose();
    final subscription = ledger.scan().listen((device) async {
      print('found device');
      print(device.name);
      ledger.stopScanning();
      print('start connect');
      await ledger.disconnect(device);
      await ledger.connect(device);
      print('connected');
      try {
        final minaApp = MinaLedgerApp(ledger);
        print(minaApp);
        // final ledgerApp = await minaApp.getAppName(device);
        // print(ledgerApp.name);
        // print(ledgerApp.version);
        final version = await minaApp.getVersion(device);
        print(version.versionName);
        // final version = await minaApp.getAccounts(device);
        // print(version);
      } on LedgerException catch (e) {
        print('出错了');
        print(e.message);
        await ledger.disconnect(device);
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool showIndicator = store.assets!.tokenList.length == 0;
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
              // await store.wallet!.deleteWatchModeWallets();
              // _onRefresh(showIndicator: true);
              this._onConfirmDeleteWatchWallet();
            });
      });
    }
  }

  void _showNetworkDialog() {
    UI.showNetworkSelectDialog(context: context);
  }

  Widget _buildNetworkEntry(BuildContext context) {
    String networkName = widget.store.settings!.currentNode!.name;
    return InkWell(
        onTap: _showNetworkDialog,
        child: Container(
          height: 30,
          padding: const EdgeInsets.only(left: 14, right: 8),
          decoration: BoxDecoration(
            border: new Border.all(color: Color(0x1A000000), width: 1),
            borderRadius: BorderRadius.circular((15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Fmt.stringSlice(networkName, 12, withEllipsis: true),
                style: TextStyle(
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              SizedBox(
                width: 4,
              ),
              Icon(
                Icons.expand_more,
                size: 20,
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Container(
            //   width: 10,
            // ),
            Text(
              dic.myWallet,
              style: theme.displayLarge!.copyWith(
                color: ColorsUtil.hexColor(0x020028),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Flexible(child: Container(),),
                  Container(child: _buildNetworkEntry(context)),
                  Container(
                    width: 12,
                  ),
                  IconButton(
                      iconSize: 30,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: SvgPicture.asset(
                          'assets/images/assets/wallet_manage.svg',
                          width: 30,
                          height: 30),
                      onPressed: () {
                        Navigator.of(context).pushNamed(WalletManagePage.route);
                      }
                      // ,
                      ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _viewAccountDetail() {
    Navigator.pushNamed(context, AccountManagePage.route, arguments: {
      "account": store.wallet!.currentWallet.currentAccount,
      "wallet": store.wallet!.currentWallet
    });
  }

  Widget _buildTopCard(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    WalletData acc = store.wallet!.currentWallet;
    var currency = currencyConfig
        .firstWhere((element) => element.key == store.settings!.currencyCode);
    var currencySymbol = currency.symbol;
    Color amountColor =
        (store.assets!.isAssetsLoading) ? Color(0xFFDDDDDD) : Color(0xFFFFFFFF);
    bool isZekoNet = store.settings!.isZekoNet;
    String nextNetIcon = isZekoNet
        ? "assets/images/assets/icon_zeko.svg"
        : "assets/images/assets/icon_mina.svg";

    int chainColor = store.settings!.isMainnet ? 0xFF594AF1 : 0x4C000000;

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
                        color: Colors.white,
                        text: dic.send,
                        textStyle: buttonTextStyle,
                        onPressed: _onTransfer,
                        icon: SvgPicture.asset(
                          'assets/images/assets/send.svg',
                          width: 10,
                          colorFilter: ColorFilter.mode(Color(chainColor), BlendMode.srcIn)
                        ),
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
                                colorFilter: ColorFilter.mode(Color(chainColor), BlendMode.srcIn)
                              ),
                              padding: EdgeInsets.zero,
                              radius: 24,
                            ))),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Color(0x1A000000),
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                    iconSize: 28,
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minHeight: 0, minWidth: 0),
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _viewAccountDetail),
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
          key: globalBalanceRefreshKey,
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
