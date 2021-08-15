import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class FormPanel extends StatelessWidget {
  FormPanel({
    this.border,
    this.margin,
    this.padding = const EdgeInsets.all(20),
    this.child
  });

  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: this.child,
      decoration: BoxDecoration(
        border: border,
        borderRadius: const BorderRadius.all(const Radius.circular(10)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: ColorsUtil.hexColor(0x252275, alpha: 0.08),
            blurRadius: 30.0, // has the effect of softening the shadow
            spreadRadius: 0, // has the effect of extending the shadow
            offset: Offset(
              0, // horizontal, move right 10
              12.0, // vertical, move down 10
            ),
          )
        ],
      ),
    );
  }
}
/*
*
* background: #FFFFFF;
box-shadow: 0 12px 30px 0 rgba(37,34,117,0.08);
border-radius: 10px;
* */