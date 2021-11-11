import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/loadingPanel.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeListTip extends StatelessWidget {
  HomeListTip({required this.isEmpty,required this.isLoading, required this.isSupportedNode});
  final bool isLoading;
  final bool isEmpty;
  final bool isSupportedNode;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    if (!isSupportedNode) {
      return FormPanel(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
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
                    i18n['homeNoTx']!,
                  style: theme.headline5!.copyWith(
                      color: ColorsUtil.hexColor(0x666666)
                  ),
                )
            ),)
          ],
        ),
      );
    }
    if (isLoading && isEmpty) {
      return LoadingPanel(
        padding: EdgeInsets.only(top: 20),
      );
    }
    if (isEmpty) {
      return FormPanel(
        margin: EdgeInsets.only(top: 20),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                      CupertinoIcons.exclamationmark_circle_fill,
                      size: 20,
                      color: ColorsUtil.hexColor(0xFFC633)
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 4 ,left: 5),
                      child: Text(
                        i18n['prompt']!,
                        style: theme.headline4
                      )
                  ),
                ]
            ),
            Padding(
                padding: EdgeInsets.only(top: 15, bottom: 20),
                child: Text(
                  i18n['walletHomeTip']!,
                  style: theme.headline5!.copyWith(
                      color: ColorsUtil.hexColor(0x666666)
                  ),
                )
            )
          ],
        ),
      );
    }
    return Container();
  }
}
