import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:auro_wallet/common/components/loadingPanel.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeListTip extends StatelessWidget {
  HomeListTip({required this.isLoading, required this.isSupportedNode});
  final bool isLoading;
  final bool isSupportedNode;
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    if (!isSupportedNode) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
                'assets/images/public/no.svg',
                width: 14,
                height: 14
            ),
            Expanded(child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                    dic.homeNoTx,
                  style: theme.headline5!.copyWith(
                      color: ColorsUtil.hexColor(0x666666)
                  ),
                )
            ),)
          ],
        ),
      );
    }
    if (isLoading) {
      return Center(
        child: LoadingCircle(),
      );
    }
    return Container();
  }
}

class EmptyTxListTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(top: 20, right: 20, left: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Colors.white
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                    Icons.error_outline_outlined,
                    size: 20,
                    color: Colors.black
                ),
                Padding(
                    padding: EdgeInsets.only(top: 0 ,left: 5),
                    child: Text(
                        dic.prompt,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        )
                    )
                ),
              ]
          ),
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 0),
              child: Text(
                dic.walletHomeTip,
                style: theme.headline5!.copyWith(
                    fontSize: 12,
                    color: ColorsUtil.hexColor(0x666666)
                ),
              )
          )
        ],
      ),
    );
  }
}