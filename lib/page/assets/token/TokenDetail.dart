import 'dart:async';
import 'dart:convert';

import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/page/assets/token/component/MinaExchangePicker.dart';
import 'package:auro_wallet/service/minaExchanges.dart';
import 'package:auro_wallet/service/tx_status_monitor.dart';
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
import 'package:auro_wallet/utils/index.dart';
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
  String tokenIconUrl = "";
  bool isMainToken = false;
  bool isLoading = false;
  int tokenDecimal = COIN.decimals;
  String? tokenPublicKey;
  Timer? _refreshTimer;
  final GlobalKey<RefreshIndicatorState> _tokenRefreshKey =
      GlobalKey<RefreshIndicatorState>();

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
    } else {
      tokenSymbol = getTokenSymbol(tokenNetInfo);
      tokenDecimal = int.parse(tokenBaseInfo?.decimals ?? "0");
      tokenPublicKey = tokenNetInfo?.publicKey;
    }

    tokenIconUrl = tokenBaseInfo?.iconUrl ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.store.setTokenRefreshKey(_tokenRefreshKey);
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

    // Register callback for transaction confirmation refresh
    TxStatusMonitor().addOnTxConfirmedListener(_onTxConfirmedRefresh);

    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.store.setTokenRefreshKey(null);
    TxStatusMonitor().removeOnTxConfirmedListener(_onTxConfirmedRefresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTxConfirmedRefresh(String gqlUrl) {
    if (mounted) {
      _onRefresh();
    }
  }

  Future<void> _onRefresh({showIndicator = false}) async {
    if (showIndicator && mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await Future.wait([
      webApi.assets.fetchAllTokenAssets(showIndicator: showIndicator),
      _fetchTransactions(showIndicator),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTransactions(showIndicator) async {
    if (isMainToken) {
      await Future.wait([
        webApi.assets
            .fetchPendingTransactions(widget.store.wallet!.currentAddress),
        webApi.assets
            .fetchPendingZkTransactions(widget.store.wallet!.currentAddress),
        webApi.assets.fetchFullTransactions(widget.store.wallet!.currentAddress)
      ]);
    } else {
      await Future.wait([
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
                ? Text(COIN.name,
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
                        Text(Fmt.address(tokenId, pad: 6),
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
          key: _tokenRefreshKey,
          onRefresh: _onRefresh,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Observer(
              builder: (_) {
                final currentToken =
                    widget.store.assets!.getCurrentToken(tokenId!);
                final baseInfo = currentToken?.tokenBaseInfo;
                final balance = baseInfo?.showBalance;
                final balanceText = balance == null
                    ? '--'
                    : Fmt.parseShowBalance(balance, showLength: tokenDecimal);
                final displayBalance = '$balanceText $tokenSymbol';
                final amount = baseInfo?.showAmount;
                final currency = currencyConfig.firstWhere(
                    (item) => item.key == widget.store.settings!.currencyCode);
                final displayAmount =
                    amount == null ? null : '≈ ${currency.symbol} $amount';
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
                                    displayAmount,
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
                          TokenDetailActions(
                            store: widget.store,
                            token: currentToken ?? token,
                            tokenSymbol: tokenSymbol,
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

class TokenDetailActions extends StatelessWidget {
  const TokenDetailActions({
    super.key,
    required this.store,
    required this.token,
    required this.tokenSymbol,
  });

  final AppStore store;
  final Token token;
  final String tokenSymbol;

  @override
  Widget build(BuildContext context) => Observer(
    builder: (_) {
      final mainToken = token.tokenBaseInfo?.isMainToken == true;
      final node = store.settings!.currentNode;
      final address = store.wallet!.currentAddress;
      final showBuy = mainToken && store.settings!.isMainnet;
      final showEarn = mainToken && store.settings!.isMinaNet;
      return ValueListenableBuilder<MinaExchangesConfig?>(
        valueListenable: store.minaExchanges,
        builder: (_, config, __) {
          final exchanges = config?.available ?? const <MinaExchange>[];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBuy && exchanges.isNotEmpty)
                  Flexible(
                    child: MinaExchangePicker(
                      key: ValueKey(
                        jsonEncode([address, node?.networkID, node?.url]),
                      ),
                      exchanges: exchanges,
                      builder: (context, open) => TokenActionItem(
                        type: TokenActionType.buy,
                        store: store,
                        onTap: open,
                      ),
                    ),
                  ),
                Flexible(
                  child: TokenActionItem(
                    type: TokenActionType.send,
                    token: token,
                    store: store,
                  ),
                ),
                Flexible(
                  child: TokenActionItem(
                    type: TokenActionType.receive,
                    store: store,
                    tokenSymbol: tokenSymbol,
                  ),
                ),
                if (showEarn)
                  Flexible(
                    child: TokenActionItem(
                      type: TokenActionType.delegation,
                      store: store,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

enum TokenActionType { buy, send, receive, delegation }

class TokenActionItem extends StatelessWidget {
  TokenActionItem({
    required this.type,
    this.token,
    required this.store,
    this.tokenSymbol,
    this.onTap,
  });

  final VoidCallback? onTap;
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
      case TokenActionType.buy:
        title = dic.buy;
        break;
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
        title = dic.earn;
        nextRouter = Staking.route;
        actionIconUrl = "assets/images/assets/delegation.svg";
        break;
    }

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            onTap ??
            () {
              onClickItem(context, type, nextRouter!);
            },
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: type == TokenActionType.buy
                    ? const Icon(Icons.add, color: Colors.white, size: 28)
                    : SvgPicture.asset(
                        actionIconUrl!,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
