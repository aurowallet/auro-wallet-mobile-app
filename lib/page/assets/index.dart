import 'dart:async';
import 'dart:ui' as ui;

import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/nodeSelectionDropdown.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/components/roundedCard.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/page/assets/transactionDetail/transactionDetailPage.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/homeListTip.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/page/account/accountManagePage.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Assets extends StatefulWidget {
  Assets(this.store);

  final AppStore store;

  @override
  _AssetsState createState() => _AssetsState(store);
}

class _AssetsState extends State<Assets> with WidgetsBindingObserver {
  _AssetsState(this.store);

  final AppStore store;

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
      _fetchTransactions();
      _checkWatchMode();
      WidgetsBinding.instance.addObserver(this);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    var isInForeground = state == AppLifecycleState.resumed;
    if (isInForeground) {
      this._onRefresh(showIndicator: true);
    }
  }

  Future<void> _onRefresh({showIndicator = false}) async {
    await Future.wait([
      _fetchTransactions(),
      webApi.assets.fetchAccountInfo(showIndicator: showIndicator)
    ]);
  }

  Future<void> _fetchTransactions() async {
    print('start fetch tx list');
    if (!store.settings!.isSupportedNode) {
      return;
    }
    store.assets!.setTxsLoading(true);
    await Future.wait([
      webApi.assets.fetchPendingTransactions(store.wallet!.currentAddress),
      webApi.assets.fetchTransactions(store.wallet!.currentAddress),
    ]);
    store.assets!.setTxsLoading(false);
    print('finish fetch tx list');
  }

  void _onReceive() {
    Navigator.pushNamed(context, ReceivePage.route);
  }

  void _onTransfer() {
    // ledgerSetup();
    // return;
    Navigator.pushNamed(
      context,
      TransferPage.route,
    );
  }

  void _onConfirmDeleteWatchWallet() async {
    await Navigator.of(context).pushNamed(WalletManagePage.route);
    this._checkWatchMode();
  }

  void _checkWatchMode() {
    if (store.wallet!.hasWatchModeWallet()) {
      Future.delayed(Duration(milliseconds: 600), () async {
        var i18n = I18n.of(context).main;
        await UI.showAlertDialog(
            context: context,
            barrierDismissible: false,
            disableBack: true,
            contents: [
              i18n['watchModeWarn2']!,
            ],
            confirm: i18n['deleteWatch']!,
            onConfirm: () {
              // await store.wallet!.deleteWatchModeWallets();
              // _onRefresh(showIndicator: true);
              this._onConfirmDeleteWatchWallet();
            });
      });
    }
  }

  Widget _buildTopBar(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var i18nHome = I18n.of(context).home;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   width: 10,
          // ),
          Text(
            i18nHome['myWallet']!,
            style: theme.headline1!.copyWith(
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
                Container(
                  child: NodeSelectionDropdown(store: store),
                ),
                Container(
                  width: 15,
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
    );
  }

  void _viewAccountDetail() {
    Navigator.pushNamed(context, AccountManagePage.route, arguments: {
      "account": store.wallet!.currentWallet.currentAccount,
      "wallet": store.wallet!.currentWallet
    });
  }

  Widget _buildTopCard(BuildContext context) {
    var i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    WalletData acc = store.wallet!.currentWallet;
    AccountInfo? balancesInfo = store.assets!.accountsInfo[acc.pubKey];
    BigInt total = balancesInfo != null ? balancesInfo.total : BigInt.from(0);
    bool isDelegated = balancesInfo != null ? balancesInfo.isDelegated : false;
    String? coinPrice;
    var symbol = COIN.coinSymbol.toLowerCase();
    if (store.assets!.marketPrices[symbol] != null && balancesInfo != null) {
      coinPrice = Fmt.priceCeil(store.assets!.marketPrices[symbol]! *
          Fmt.bigIntToDouble(balancesInfo.total, COIN.decimals));
    }
    var currencySymbol = Currency(code: store.settings!.currencyCode).symbol;
    final amountColor = (store.assets!.isBalanceLoading) ? 0xDDDDDD : 0xFFFFFF;
    final priceColor = (store.assets!.isBalanceLoading)
        ? Color(0xFFDDDDDD)
        : Color(0x99FFFFFF);
    final currencyStyle = TextStyle(
        fontSize: 16,
        color: priceColor,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600);
    final buttonTextStyle = TextStyle(
        fontSize: 16,
        color: Color(0xFF594AF1),
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3);
    return Container(
      margin: EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            0.1,
            0.46,
            1.0,
          ],
          colors: [
            Color(0xFFCA5C89),
            Color(0xFF4F55EC),
            Color(0xFF3531FF),
          ],
        ),
      ),
      child: Stack(children: [
        Positioned.fill(
            child: FittedBox(
          fit: BoxFit.fill,
          child: Image.asset('assets/images/assets/card_mask.png'),
        )),
        Positioned(
          right: 20,
          top: 60,
          child: Image.asset(
            'assets/images/assets/card_logo.png',
            width: 99,
            height: 90,
          ),
        ),
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
                    Container(
                        alignment: Alignment.center,
                        child: Center(
                          child: Text(
                            isDelegated
                                ? i18n['stakingStatus_1']!
                                : i18n['stakingStatus_2']!,
                            strutStyle: StrutStyle(
                              fontSize: 12,
                              leading: 0,
                              height: 1.1,
                              forceStrutHeight: true,
                            ),
                            style: TextStyle(
                                color: Colors.white,
                                backgroundColor: Colors.transparent,
                                height: 1.1,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        margin: EdgeInsets.only(left: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDelegated
                              ? Color(0x33FFFFFF)
                              : Color(0x33FFFFFF),
                          borderRadius: BorderRadius.circular(29),
                        ))
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: CopyContainer(
                          showIcon: true,
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
                  padding: EdgeInsets.only(
                    top: 27,
                  ),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        Fmt.balance(total.toString(), COIN.decimals),
                        style: TextStyle(
                            fontSize: 32,
                            color: ColorsUtil.hexColor(amountColor),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700),
                      ),
                      Container(width: 4),
                      Text(
                        COIN.coinSymbol.toUpperCase(),
                        style: TextStyle(
                            fontSize: 15,
                            color: ColorsUtil.hexColor(amountColor),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                store.settings!.isMainnet
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: 24,
                        ),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              currencySymbol,
                              style: currencyStyle,
                            ),
                            Text(
                              coinPrice ?? '0',
                              style: currencyStyle,
                            )
                          ],
                        ),
                      )
                    : Container(
                        height: 23,
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
                      text: i18n['send']!,
                      textStyle: buttonTextStyle,
                      onPressed: _onTransfer,
                      icon: SvgPicture.asset('assets/images/assets/send.svg',
                          width: 10),
                      padding: EdgeInsets.zero,
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
                            text: i18n['receive']!,
                            textStyle: buttonTextStyle,
                            onPressed: _onReceive,
                            icon: SvgPicture.asset(
                              'assets/images/assets/receive.svg',
                              width: 10,
                            ),
                            padding: EdgeInsets.zero,
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
    );
  }

  List<Widget> _buildTxList() {
    var i18n = I18n.of(context).main;
    List<Widget> res = [];
    bool isTxsLoading = store.assets!.isTxsLoading;
    List<TransferData> txs = [
      ...store.assets!.pendingTxs,
      ...store.assets!.totalTxs
    ];
    if (store.settings!.isSupportedNode) {
      res.addAll(txs.map((i) {
        return TransferListItem(
          data: i,
          isOut: i.sender == store.wallet!.currentAddress,
        );
      }));
      if (store.assets!.txs.length >= 20) {
        res.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: BrowserLink(
                  '${!store.settings!.isMainnet ? TESTNET_TRANSACTIONS_EXPLORER_URL : MAINNET_TRANSACTIONS_EXPLORER_URL}/wallet/${store.wallet!.currentAddress}/transactions',
                  text: i18n['goToExplorer']!,
                ))
          ],
        ));
      }
    }
    res.add(HomeListTip(
        isLoading: isTxsLoading && txs.length == 0,
        isSupportedNode: store.settings!.isSupportedNode));
    return res;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Observer(
      builder: (_) {
        bool isTxsLoading = store.assets!.isTxsLoading;
        bool isEmpty = store.assets!.txs.length == 0 &&
            store.assets!.pendingTxs.length == 0;
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _onRefresh,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Column(
              children: <Widget>[
                _buildTopBar(context),
                _buildTopCard(context),
                !isEmpty || isTxsLoading
                    ? Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                margin: EdgeInsets.only(top: 30),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                        bottom: BorderSide(
                                      color: Colors.black.withOpacity(0.1),
                                      width: 0.5,
                                    ))),
                                child: Text(
                                  I18n.of(context).main['history']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: -0.3,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ))
                        ],
                      )
                    : Container(),
                Expanded(
                  child: isEmpty && !isTxsLoading
                      ? Wrap(
                          children: [EmptyTxListTip()],
                        )
                      : Ink(
                          color: Color(0xFFFFFFFF),
                          child: isEmpty && isTxsLoading
                              ? Container(
                                  child: Center(
                                    child: LoadingCircle(),
                                  ),
                                )
                              : ListView(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  children: _buildTxList(),
                                ),
                        ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class TransferListItem extends StatelessWidget {
  TransferListItem({
    required this.data,
    required this.isOut,
  });

  final TransferData data;
  final bool isOut;
  BuildContext? _ctx;

  void _viewRecordDetail() {
    Navigator.pushNamed(_ctx!, TransactionDetailPage.route, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    String? address = isOut ? data.receiver : data.sender;
    String title = '';
    if (address == null) {
      title = data.type.toUpperCase();
    } else {
      title = Fmt.address(address, pad: 8);
    }
    var theme = Theme.of(context).textTheme;
    final Map i18n = I18n.of(context).main;
    String icon = '';
    Color statusColor;
    switch (data.type) {
      case 'delegation':
        {
          icon = 'tx_stake';
        }
        break;
      default:
        {
          icon = isOut ? 'tx_out' : 'tx_in';
        }
        break;
    }
    String statusText;
    switch (data.status) {
      case 'applied':
      case 'failed':
      case 'pending':
        statusText = i18n[data.status.toUpperCase()];
        break;
      default:
        statusText = data.status.toUpperCase();
        break;
    }
    switch (data.status) {
      case 'applied':
        statusColor = ColorsUtil.hexColor(0x00C89C);
        break;
      case 'failed':
        statusColor = ColorsUtil.hexColor(0xE84335);
        break;
      default:
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
    }
    Color bgColor =
        data.status != 'pending' ? Colors.transparent : Color(0xFFF9FAFC);
    return new Material(
      color: bgColor,
      child: InkWell(
          onTap: _viewRecordDetail,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                  width: 0.5,
                ))),
                child: Row(
                  children: [
                    Container(
                        width: 28,
                        margin: EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          'assets/images/assets/$icon.svg',
                          width: 28,
                        )),
                    Expanded(
                      flex: 1,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '$title',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                  ),
                                  data.isFromAddressScam == true ?ScamTag():Container(),
                                ]),
                            Text(
                              '${isOut ? '-' : '+'}${Fmt.balance(data.amount, COIN.decimals)}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 4)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data.isPending
                                    ? 'Nonce ' + data.nonce.toString()
                                    : Fmt.dateTimeFromUTC(data.time),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: ColorsUtil.hexColor(0x96969A)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4)),
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                child: Center(
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: statusColor),
                                  ),
                                ),
                              ),
                            ])
                      ]),
                    )
                  ],
                )),
          )),
    );
  }
}
