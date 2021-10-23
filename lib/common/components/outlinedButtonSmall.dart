import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class OutlinedButtonSmall extends StatelessWidget {
  OutlinedButtonSmall({
    required this.content,
    this.active = false,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.margin,
    this.padding,
    this.onPressed,
    this.suffixIcon,
    this.radius = 15
  });
  final String content;
  final bool active;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final void Function()? onPressed;
  final Widget? suffixIcon;
  final double radius;
  @override
  Widget build(BuildContext context) {
    Color primary = color ?? Theme.of(context).primaryColor;
    Color grey = ColorsUtil.hexColor(0xeeeeee);
    Color textGrey = ColorsUtil.hexColor(0x666666);
    Color white = Theme.of(context).cardColor;
    return GestureDetector(
      child: Container(
        margin: margin ?? EdgeInsets.only(right: 8),
        padding: padding ?? EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: active ? primary : white,
          border: Border.all(color: active ? (borderColor ?? primary) : grey),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? ColorsUtil.hexColor(0x0078FF, alpha: 0.08),
              blurRadius: 15.0, // has the effect of softening the shadow
              spreadRadius: 1, // has the effect of extending the shadow
              offset: Offset(
                0, // horizontal,
                9.0, // vertical,
              ),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content, style: TextStyle(color: active ? white : textGrey, fontSize: 14)),
            suffixIcon ?? Container()
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}
