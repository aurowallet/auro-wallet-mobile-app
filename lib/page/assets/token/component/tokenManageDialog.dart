import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenManagaItem.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TokenManageDialog extends StatefulWidget {
  TokenManageDialog();

  @override
  _TokenManageDialogState createState() => new _TokenManageDialogState();
}

class _TokenManageDialogState extends State<TokenManageDialog> {
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onClickIgnore() async {
    await store.assets!.updateNewTokenConfig(store.wallet!.currentAddress);
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
                title: dic.assetManagement,
                showCloseIcon: true,
              ),
              Observer(builder: (_) {
                if (store.assets!.newTokenCount <= 0) {
                  return Container();
                }
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.black.withOpacity(0.1), width: 0.5),
                      ),
                      color: Color(0xFFF9FAFC),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dic.newTokenFound(
                              store.assets!.newTokenCount.toString()),
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClickIgnore,
                          child: Text(
                            dic.ignore,
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ));
              }),
              Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  constraints: BoxConstraints(
                    maxHeight: height * 0.6,
                  ),
                  child: Observer(builder: (BuildContext context) {
                    // todo when init,  add loading
                    List<Token> manageList = store.assets!.tokenList
                        .where(
                          (tokenItem) =>
                              !(tokenItem.tokenBaseInfo?.isMainToken ?? false),
                        )
                        .toList();

                    return ListView.builder(
                        itemCount: manageList.length,
                        itemBuilder: (context, index) {
                          return Container(
                              child: TokenManagaItem(
                            tokenItem: manageList[index],
                            store: store,
                          ));
                        });
                  })),
            ],
          ),
        ));
  }
}
