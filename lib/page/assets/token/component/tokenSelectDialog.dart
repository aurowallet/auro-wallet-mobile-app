import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/TokenListView.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';

class TokenSelectionDialog extends StatefulWidget {
  TokenSelectionDialog({
    required this.tokenSelected,
  });

  final Function() tokenSelected;
  @override
  _TokenSelectDialogState createState() => new _TokenSelectDialogState();
}

class _TokenSelectDialogState extends State<TokenSelectionDialog> {
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
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
                  child: TokenListView(
                    store,
                    isInModal: true,
                    onClickItem: widget.tokenSelected,
                  )),
            ],
          ),
        ));
  }
}
