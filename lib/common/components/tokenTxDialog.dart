import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class TokenTxDialog extends StatefulWidget {
  TokenTxDialog({
    required this.txList,
    this.onOk,
    this.onCancel,
  });

  final List<TokenPendingTx> txList;
  final Function? onOk;
  final Function? onCancel;

  @override
  _TokenTxDialogDialogState createState() => _TokenTxDialogDialogState();
}

class _TokenTxDialogDialogState extends State<TokenTxDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerMaxHeight = screenHeight * 0.4;
    double minHeight = 200;
    if (containerMaxHeight <= minHeight) {
      containerMaxHeight = containerMaxHeight + 50;
    }
    return Dialog(
      clipBehavior: Clip.hardEdge,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20).copyWith(bottom: 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 6),
                child: Text(dic.pendingTx,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 6),
                child: new StyledText(
                    text: dic.tokenPendingTip(widget.txList.length),
                    style: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                    tags: {
                      'light': StyledTextTag(
                        style: TextStyle(
                            color: Color(0xFF000000).withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      )
                    }),
              ),
              widget.txList.length > 0
                  ? Container(
                      constraints: BoxConstraints(
                          minHeight: minHeight, maxHeight: containerMaxHeight),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.txList //
                              .map((txItem) => TokenTxItemView(
                                    txItem: txItem,
                                    store: globalAppStore,
                                  ))
                              .toList(),
                        ),
                      ))
                  : Container(),
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.black.withValues(alpha: 0.05),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: SizedBox(
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                  textStyle: TextStyle(color: Colors.black),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  )),
              child: Text(dic.cancel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () {
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
                Navigator.of(context).pop(false);
              },
            ),
          )),
          Container(
            width: 0.5,
            height: 48,
            color: Colors.black.withValues(alpha: 0.1),
          ),
          Expanded(
              child: SizedBox(
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              )),
              child: Text(dic.confirm,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor)),
              onPressed: () {
                if (widget.onOk != null) {
                  widget.onOk!();
                }
                Navigator.of(context).pop(true);
              },
            ),
          )),
        ]),
      ]),
    );
  }
}

class TokenTxItemView extends StatelessWidget {
  TokenTxItemView({
    required this.txItem,
    required this.store,
  });
  final TokenPendingTx txItem;
  final AppStore store;

  Token findTokenByAddress(String address, List<Token> tokens) {
    return tokens.firstWhere(
      (token) => token.tokenNetInfo?.publicKey == address,
      orElse: () {
        return Token(
          tokenAssestInfo: null,
          tokenNetInfo: null,
          localConfig: null,
          tokenBaseInfo: null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Token currentTokenInfo =
        findTokenByAddress(txItem.tokenaddress, store.assets!.tokenList);
    int tokenDecimal = 0;
    if (currentTokenInfo.tokenBaseInfo != null) {
      tokenDecimal = int.parse(currentTokenInfo.tokenBaseInfo?.decimals ?? "0");
    }

    String showAmount = "";
    showAmount = Fmt.balance(txItem.amount, tokenDecimal);

    String tokenSymbol = "--";
    if (currentTokenInfo.tokenNetInfo != null) {
      tokenSymbol = currentTokenInfo.tokenNetInfo?.tokenSymbol ?? "--";
    }
    return new Material(
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.1),
                width: 0.5,
              ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 4,
                              child: Text(
                                Fmt.address(txItem.sender, pad: 6),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              flex: 2,
                              child: Text(
                                '$showAmount' + " " + tokenSymbol,
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              )),
                        ],
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    txItem.nonce.toString(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ],
              )),
        ));
  }
}
