import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class HomeListTip extends StatelessWidget {
  HomeListTip();
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
                child: Text(
              dic.txHistoryTip,
              style: theme.headlineMedium!
                  .copyWith(color: ColorsUtil.hexColor(0x666666)),
            )),
          )
        ],
      ),
    );
  }
}

class EmptyTxListTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(Icons.error_outline_outlined, size: 20, color: Colors.black),
            Padding(
                padding: EdgeInsets.only(top: 0, left: 5),
                child: Text(dic.prompt,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          ]),
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 0),
              child: Text(
                dic.walletHomeTip,
                style: theme.headlineMedium!.copyWith(
                    fontSize: 12, color: ColorsUtil.hexColor(0x666666)),
              ))
        ],
      ),
    );
  }
}
