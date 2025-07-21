import 'dart:async';

import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/token/component/TokenIcon.dart';
import 'package:auro_wallet/page/assets/token/component/TxListView.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TokenDetailPage extends StatefulWidget {
  TokenDetailPage(this.store);

  final AppStore store;

  static final String route = '/assets/tokendetail';

  @override
  _TokenDetail createState() => _TokenDetail();
}

class _TokenDetail extends State<TokenDetailPage> with WidgetsBindingObserver {
  late Token token;
  String tokenSymbol = "";
  String? tokenId;
  String tokenName = "";
  String displayBalance = "";
  String? displayAmount;
  String tokenIconUrl = "";
  bool showStakingEntry = false;
  bool isMainToken = false;
  bool isLoading = false;
  int tokenDecimal = COIN.decimals;
  String? tokenPublicKey;
  Timer? _refreshTimer;

  @override
  void initState() {
    token = widget.store.assets!.nextToken;
    TokenAssetInfo? tokenAssestInfo = token.tokenAssestInfo;
    TokenNetInfo? tokenNetInfo = token.tokenNetInfo;
    TokenBaseInfo? tokenBaseInfo = token.tokenBaseInfo;
    isMainToken = tokenBaseInfo?.isMainToken ?? false;

    tokenId = tokenAssestInfo?.tokenId ?? "";
    if (isMainToken) {
      tokenSymbol = COIN.coinSymbol;
      tokenName = COIN.name;
    } else {
      tokenSymbol = tokenNetInfo?.tokenSymbol ?? "UNKNOWN";
      tokenName = Fmt.address(tokenId, pad: 6);
      tokenDecimal = int.parse(tokenBaseInfo?.decimals ?? "0");
      tokenPublicKey = tokenNetInfo?.publicKey;
    }

    tokenIconUrl = tokenBaseInfo?.iconUrl ?? "";
    displayBalance = tokenBaseInfo?.showBalance != null
        ? Fmt.parseShowBalance(tokenBaseInfo!.showBalance!,
            showLength: tokenDecimal)
        : "0.0";
    displayBalance = displayBalance + " " + tokenSymbol;

    double? tokenAmount = tokenBaseInfo?.showAmount;

    if (tokenAmount != null) {
      var currency = currencyConfig.firstWhere(
          (element) => element.key == widget.store.settings!.currencyCode);
      var currencySymbol = currency.symbol;
      String showAmount = currencySymbol + " " + tokenAmount.toString();
      displayAmount = "≈ " + showAmount;
    }

    bool isMinaNet = widget.store.settings!.isMinaNet;
    if (isMinaNet && isMainToken) {
      showStakingEntry = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<TransferData> txs = [
        ...widget.store.assets!.getTotalPendingTxs(tokenId!),
        ...widget.store.assets!.getTotalTxs(tokenId!)
      ];

      bool showIndicator = txs.length == 0;
      _onRefresh(showIndicator: showIndicator);
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

  Future<void> _onRefresh({showIndicator = false}) async {
    if (showIndicator) {
      setState(() {
        isLoading = true;
      });
    }
    await Future.wait([
      webApi.assets.fetchAllTokenAssets(showIndicator: showIndicator),
      _fetchTransactions(showIndicator),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchTransactions(showIndicator) async {
    if (isMainToken) {
      await Future.wait([
        webApi.assets.fetchAllTokenAssets(showIndicator: showIndicator),
        webApi.assets
            .fetchPendingTransactions(widget.store.wallet!.currentAddress),
        webApi.assets
            .fetchPendingZkTransactions(widget.store.wallet!.currentAddress),
        webApi.assets.fetchFullTransactions(widget.store.wallet!.currentAddress)
      ]);
    } else {
      await Future.wait([
        webApi.assets.fetchAllTokenAssets(showIndicator: showIndicator),
        webApi.assets
            .fetchPendingZkTransactions(widget.store.wallet!.currentAddress),
        webApi.assets.fetchFullTransactions(widget.store.wallet!.currentAddress,
            tokenId: tokenId),
        webApi.assets.fetchTokenTransactions(
            widget.store.wallet!.currentAddress, tokenPublicKey)
      ]);
    }
    print('finish fetch tx list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              tokenSymbol,
            ),
            isMainToken
                ? Text(tokenName,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400))
                : InkWell(
                    onTap: () {
                      UI.copyAndNotify(context, tokenId);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tokenName,
                            style: TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w400)),
                        SizedBox(
                          width: 2,
                        ),
                        SvgPicture.asset('assets/images/webview/icon_copy.svg',
                            width: 12,
                            colorFilter:
                                ColorFilter.mode(Colors.black, BlendMode.srcIn))
                      ],
                    ),
                  ),
          ],
        ),
      ),
      body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Theme.of(context).primaryColor,
          key: globalTokenRefreshKey,
          onRefresh: _onRefresh,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Observer(
              builder: (_) {
                List<TransferData> pendingTx =
                    widget.store.assets!.getTotalPendingTxs(tokenId!);
                List<TransferData> tx =
                    widget.store.assets!.getTotalTxs(tokenId!);
                List<TransferData> pendingBuildTx = [];
                if (tokenPublicKey != null) {
                  pendingBuildTx =
                      widget.store.assets!.tokenBuildTxList[tokenPublicKey] ??
                          [];
                }
                List<TransferData> txs = [
                  ...pendingBuildTx,
                  ...pendingTx,
                  ...tx
                ];
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xFFF9FAFC),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          TokenIcon(
                            iconUrl: tokenIconUrl,
                            tokenSymbol: tokenSymbol,
                            size: 60,
                            isMainToken: isMainToken,
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                displayBalance,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              )),
                          displayAmount != null
                              ? Container(
                                  child: Text(
                                    displayAmount!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000)
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: [
                                  TokenActionItem(
                                    type: TokenActionType.send,
                                    token: token,
                                    store: widget.store,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  TokenActionItem(
                                      type: TokenActionType.receive,
                                      store: widget.store,
                                      tokenSymbol: tokenSymbol),
                                  SizedBox(
                                    width: showStakingEntry ? 20 : 0,
                                  ),
                                  showStakingEntry
                                      ? TokenActionItem(
                                          type: TokenActionType.delegation,
                                          store: widget.store,
                                        )
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                    TxListView(widget.store,
                        txList: txs,
                        isLoading: isLoading,
                        tokenId: tokenId!,
                        tokenDecimal: tokenDecimal,
                        tokenSymbol: tokenSymbol)
                  ],
                );
              },
            ),
          )),
    );
  }
}

enum TokenActionType { send, receive, delegation }

class TokenActionItem extends StatelessWidget {
  TokenActionItem(
      {required this.type, this.token, required this.store, this.tokenSymbol});

  final TokenActionType type;
  final Token? token;
  final String? tokenSymbol;
  final AppStore store;

  Future<void> onClickItem(
      BuildContext context, TokenActionType type, String nextRouter) async {
    Map nextArguments = {};
    if (type == TokenActionType.send) {
      await store.assets!.setNextToken(token!);
    } else if (type == TokenActionType.delegation) {
      nextArguments = {"isFromRoute": true};
    } else if (type == TokenActionType.receive) {
      nextArguments = {"isFromRoute": true, "tokenSymbol": tokenSymbol};
    }
    Navigator.of(context).pushNamed(nextRouter, arguments: nextArguments);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String? title;
    String? nextRouter;
    String? actionIconUrl;
    switch (type) {
      case TokenActionType.send:
        title = dic.send;
        nextRouter = TransferPage.route;
        actionIconUrl = "assets/images/assets/send.svg";
        break;
      case TokenActionType.receive:
        title = dic.receive;
        nextRouter = ReceivePage.route;
        actionIconUrl = "assets/images/assets/receive.svg";
        break;
      case TokenActionType.delegation:
        title = dic.staking;
        nextRouter = Staking.route;
        actionIconUrl = "assets/images/assets/delegation.svg";
        break;
      default:
    }

    return GestureDetector(
        onTap: () {
          onClickItem(context, type, nextRouter!);
        },
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(48),
              ),
              child: SvgPicture.asset(actionIconUrl!,
                  width: 14,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ),
            SizedBox(height: 4),
            Text(
              title!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ));
  }
}
