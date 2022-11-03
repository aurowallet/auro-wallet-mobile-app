import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CopyContainer extends StatelessWidget {
  CopyContainer({this.text, required this.child, this.showIcon = false, this.iconColor});
  final String? text;
  final Widget child;
  final bool showIcon;
  final Color? iconColor;

  void _copyAddress(BuildContext context) {
    UI.copyAndNotify(context, text!);
  }
  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return child;
    }
    return  GestureDetector(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:  MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              flex: 1,
              child:  Padding(
                padding: !showIcon ? EdgeInsets.zero :  EdgeInsets.only(right: 4),
                child: child,
              ),),
            showIcon ? SvgPicture.asset('assets/images/public/icon_copy.svg', width: 17, height: 17, color: iconColor ?? Theme.of(context).primaryColor,) : Container()
          ],
        ) ,
        onTap: () {
          _copyAddress(context);
        }
    );
  }
}