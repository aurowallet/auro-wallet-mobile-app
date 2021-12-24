import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
class LoadingPanel extends StatelessWidget {
  LoadingPanel({
    this.padding = const EdgeInsets.only(top: 20, right: 30, left: 30)
  });

  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: FormPanel(
        child: LoadingBox(),
      )
    );
  }
}

class LoadingBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 150
      ),
      child: Center(
        child: Image.asset('assets/images/public/loading.gif', width: 58, height: 58,),
      ),
    );
  }
}