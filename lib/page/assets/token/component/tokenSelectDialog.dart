import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenItem.dart';
import 'package:auro_wallet/page/assets/transfer/transferPage.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TokenSelectionDialog extends StatefulWidget {
  TokenSelectionDialog();

  @override
  _TokenSelectDialogState createState() => new _TokenSelectDialogState();
}

class _TokenSelectDialogState extends State<TokenSelectionDialog> {
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onClickTokenItem(Token tokenItem) async {
    await store.assets!.setNextToken(tokenItem);
    Navigator.of(context).pop();
    Navigator.of(context)
        .pushNamed(TransferPage.route, arguments: {"isFromModal": true});
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double height = MediaQuery.of(context).size.height;

    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(top: 2, bottom: 16),
        child: SafeArea(
          child: Wrap(
            children: [
              BrowserDialogTitleRow(
                title: dic.tokens,
                showCloseIcon: true,
              ),
              Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  constraints: BoxConstraints(
                    maxHeight: height * 0.6,
                  ),
                  child: Observer(builder: (BuildContext context) {
                    return ListView.builder(
                        itemCount: store.assets!.getTokenShowList().length,
                        itemBuilder: (context, index) {
                          return Container(
                              child: TokenItemView(
                                  tokenItem: store.assets!.getTokenShowList()[index],
                                  store: store,
                                  onClickTokenItem: onClickTokenItem,
                                  isInModal: true));
                        });
                  })),
            ],
          ),
        ));
  }
}
