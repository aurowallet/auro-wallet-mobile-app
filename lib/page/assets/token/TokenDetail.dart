import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/receive/receivePage.dart';
import 'package:auro_wallet/page/assets/token/component/TokenIcon.dart';
import 'package:auro_wallet/page/assets/token/component/TxListView.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/staking/index.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenAssetInfo.dart';
import 'package:auro_wallet/store/assets/types/tokenBaseInfo.dart';
import 'package:auro_wallet/store/assets/types/tokenNetInfo.dart';
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

class _TokenDetail extends State<TokenDetailPage> {
  late Token token;
  String tokenSymbol = "";
  String? tokenId;
  String tokenName = "";
  String displayBalance = "";
  String? displayAmount;
  String tokenIconUrl = "";
  bool showStakingEntry = false;
  bool isMainToken = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic> params =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    token = params['token'] as Token;
    TokenAssetInfo? tokenAssestInfo = token.tokenAssestInfo;
    TokenNetInfo? tokenNetInfo = token.tokenNetInfo;
    TokenBaseInfo? tokenBaseInfo = token.tokenBaseInfo;
    isMainToken = tokenBaseInfo?.isMainToken ?? false;
    if (isMainToken) {
      tokenIconUrl = "assets/images/stake/icon_mina_color.svg";
      tokenSymbol = COIN.coinSymbol;
      tokenName = COIN.name;
    } else {
      tokenSymbol = tokenNetInfo?.tokenSymbol ?? "UNKNOWN";
      tokenName = Fmt.address(tokenAssestInfo?.tokenId, pad: 6);
    }

    displayBalance = Fmt.balance(tokenBaseInfo?.showBalance.toString(), 0) +
        " " +
        tokenSymbol;

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
    tokenId = tokenAssestInfo?.tokenId ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
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
                            width: 12, color: Colors.black)
                      ],
                    ),
                  ),
          ],
        ),
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(
          builder: (_) {
            return Container(
              width: MediaQuery.of(context).size.width,
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
                              color: Color(0xFF000000).withOpacity(0.5),
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
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          TokenActionItem(
                            type: TokenActionType.receive,
                          ),
                          SizedBox(
                            width: showStakingEntry ? 20 : 0,
                          ),
                          showStakingEntry
                              ? TokenActionItem(
                                  type: TokenActionType.delegation,
                                )
                              : Container()
                        ],
                      ),
                    ],
                  ),
                  TxListView(widget.store)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum TokenActionType { send, receive, delegation }

class TokenActionItem extends StatelessWidget {
  TokenActionItem({required this.type, this.token});

  final TokenActionType type;
  final Token? token;

  void onClickItem(
      BuildContext context, TokenActionType type, String nextRouter) {
    Map nextArguments = {};
    if (type == TokenActionType.send) {
      nextArguments = {"token": token};
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
        actionIconUrl = "assets/images/assets/tx_stake.svg";
        break;
      default:
    }

    return InkWell(
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
                color: Color.fromRGBO(89, 74, 241, 0.1),
                borderRadius: BorderRadius.circular(48),
              ),
              child: SvgPicture.asset(
                actionIconUrl!,
                width: 28,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title!,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(128, 128, 128, 1),
                  height: 1.4),
            )
          ],
        ));
  }
}
