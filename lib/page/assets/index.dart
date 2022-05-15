import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:auro_wallet/common/components/nodeSelectionDialog.dart';
import 'package:auro_wallet/common/components/nodeSelectionDropdown.dart';
import 'package:auro_wallet/common/components/outlinedButtonSmall.dart';
import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/service/notification.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/components/roundedCard.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
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
import 'package:auro_wallet/walletSdk/rustSDK.dart';

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
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchTransactions();
      _checkWatchMode();
      WidgetsBinding.instance?.addObserver(this);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
    if(!store.settings!.isSupportedNode) {
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
    var i18n = I18n.of(context).main;
    return Padding(
      padding: EdgeInsets.fromLTRB(13, ui.window.viewPadding.top > 0 ? 16 : 36, 15, 0),
      child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/public/2x/m_logo@2x.png', width: 121, height: 30,),
        Expanded(child:  Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
            ),
            Flexible(child: NodeSelectionDropdown(store: store.settings!),),
            Container(
              width: 10,
            ),
            IconButton(
                iconSize: 30,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Image.asset('assets/images/assets/2x/wallet_manage@2x.png', width: 30, height: 30,),
                onPressed: () {
                  Navigator.of(context).pushNamed(WalletManagePage.route);
                }
              // ,
            ),
          ],
        ),)
      ],
    ),);
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
    BigInt total = balancesInfo != null ? balancesInfo.total :  BigInt.from(0);
    bool isDelegated = balancesInfo != null ? balancesInfo.isDelegated : false;
    String? coinPrice;
    var symbol = COIN.coinSymbol.toLowerCase();
    if (store.assets!.marketPrices[symbol] != null && balancesInfo != null) {
      coinPrice = Fmt.priceCeil(store.assets!.marketPrices[symbol]! * Fmt.bigIntToDouble(balancesInfo.total, COIN.decimals));
    }
    var currencySymbol = Currency(code: store.settings!.currencyCode).symbol;
    final amountColor = store.assets!.isBalanceLoading ? 0xDDDDDD : 0x1E1F20;
    final priceColor = store.assets!.isBalanceLoading ? 0xDDDDDD : 0x666666;
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(15, 30, 15, 0),
      padding: EdgeInsets.all(0),
      child: Stack(
        children:[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: new Text(Fmt.accountName(acc.currentAccount), style: theme.headline5!.copyWith(height: 1),),
                        ),
                        Container(
                            child: Text(isDelegated ? i18n['stakingStatus_1']! : i18n['stakingStatus_2']!,
                              style: theme.headline6!.copyWith(color: Colors.white),),
                            margin: EdgeInsets.only(left: 5),
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexColor(isDelegated ? 0xFFC633: 0xB1B3BD),
                              borderRadius: BorderRadius.circular(10),
                            )
                        )
                      ],
                    ),
                    Row(
                      children: [
                        CopyContainer(
                            child: Container(
                              child: Text(
                                Fmt.address(store.wallet!.currentAddress),
                                textAlign: TextAlign.left,
                                style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0xB1B3BD)),
                              ),
                              margin: EdgeInsets.only(top:10),
                            ),
                            text: store.wallet!.currentAddress
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 18,),
                      child: Row(
                        textBaseline: TextBaseline.alphabetic,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: [
                          Text(
                            Fmt.balance(total.toString(), COIN.decimals),
                            style: TextStyle(fontSize: 30, color: ColorsUtil.hexColor(amountColor)),
                          ),
                          Container(width:8),
                          Text(COIN.coinSymbol.toUpperCase(), style: theme.headline3!.copyWith(color: ColorsUtil.hexColor(amountColor)),)
                        ],
                      ),
                    ),
                    store.settings!.isMainnet ?
                    Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 23,),
                      child: Row(
                        textBaseline: TextBaseline.alphabetic,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: [
                          Text(currencySymbol, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(priceColor)),),
                          Text(coinPrice ?? '0', style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(priceColor)),)
                        ],
                      ),
                    ) : Container(height: 23,),
                  ]
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150.0,
                    height: 40.0,
                    margin: EdgeInsets.only(left: 20, bottom: 20),
                    child: NormalButton(
                      color: ColorsUtil.hexColor(0x6B5DFB),
                      text: i18n['send']!,
                      onPressed: _onTransfer,
                      radius: 20,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Container(
                      width: 150,
                      height: 40,
                      margin: EdgeInsets.only(right: 20, bottom: 20),
                      child: NormalButton(
                        color: ColorsUtil.hexColor(0x00C89C),
                        text: i18n['receive']!,
                        onPressed: _onReceive,
                        radius: 20,
                        padding: EdgeInsets.zero,
                      )
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
                iconSize: 23,
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minHeight: 0, minWidth: 0),
                icon: SvgPicture.asset(
                    'assets/images/assets/more.svg',
                    width: 23,
                    height: 23
                ),
                onPressed: _viewAccountDetail
            )
          ),
        ]
      ),
    );
  }

  List<Widget> _buildTxList() {
    var i18n = I18n.of(context).main;
    List<Widget> res = [];
    List<TransferData> txs = [...store.assets!.pendingTxs, ...store.assets!.txs];
    if (store.settings!.isSupportedNode) {
      res.addAll(txs.map((i) {
        return TransferListItem(
          data: i,
          isOut: i.sender == store.wallet!.currentAddress,
          hasDetail: true,
        );
      }));
      if (store.assets!.txs.length >= 20) {
        res.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: BrowserLink(
                  '${!store.settings!.isMainnet ? TESTNET_TRANSACTIONS_EXPLORER_URL : MAINNET_TRANSACTIONS_EXPLORER_URL}/wallet/${store.wallet!.currentAddress}/transactions',
                  text: i18n['goToExplorer']!,
                ))
          ],
        ));
      }
    }
    res.add(HomeListTip(
        isEmpty: txs.length == 0,
        isLoading: store.assets!.isTxsLoading,
        isSupportedNode: store.settings!.isSupportedNode
    ));
    return res;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Observer(
      builder: (_) {
        return RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: _onRefresh,
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              _buildTopCard(context),
              store.assets!.txs.length !=0 || store.assets!.pendingTxs.length != 0 ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Padding(
                  padding: EdgeInsets.only(top: 30,left: 15, right: 15, bottom: 0),
                  child: Text(
                      I18n.of(context).main['history']!,
                      style: theme.headline4!.copyWith(
                          color: ColorsUtil.hexColor(0x020028),
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                      ),
                      textAlign:TextAlign.left,
                  ),
                ),
              ],): Container(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                  children: _buildTxList(),
                ),
              )
            ],
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
    required this.hasDetail,
  });

  final TransferData data;
  final bool isOut;
  final bool hasDetail;
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
      title = Fmt.address(address);
    }
    var theme = Theme.of(context).textTheme;
    final Map i18n = I18n.of(context).main;
    String icon = '';
    Color statusColor;
    switch(data.type) {
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
    switch(data.status) {
      case 'applied':
      case 'failed':
      case 'pending':
        statusText = i18n[data.status.toUpperCase()];
        break;
      default:
        statusText = data.status.toUpperCase();
        break;
    }
    switch(data.status) {
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
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: GestureDetector(
          onTap: hasDetail ? _viewRecordDetail : null,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                  width: 20,
                  margin: EdgeInsets.only(right: 11),
                  child: SvgPicture.asset(
                    'assets/images/assets/$icon.svg',
                    width: 20,
                  )
              ),
              Expanded(
                flex: 1,
                child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$title', style: theme.headline5!.copyWith(
                              color: Colors.black
                          ),),
                          Text(
                            '${isOut ? '-' : '+'}${Fmt.balance(data.amount, COIN.decimals)}',
                            style: theme.headline5!.copyWith(
                                color: Colors.black
                            ),
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top:7)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.isPending ? 'Nonce ' + data.nonce.toString() : Fmt.dateTimeFromUTC(data.time), style: theme.headline6!.copyWith(
                                color:  ColorsUtil.hexColor(0x96969A)
                            ),),
                            Text(statusText, style: theme.headline6!.copyWith(
                                color:  statusColor
                            ),),
                          ]
                      )
                    ]
                ),
              ),
              Container(
                  width: 6,
                  margin: EdgeInsets.only(left: 14,),
                  child: SvgPicture.asset(
                      'assets/images/assets/right_arrow.svg',
                      width: 6,
                      height: 12
                  )
              ),
            ],
          )
      )
    );
  }
}