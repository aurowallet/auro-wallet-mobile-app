import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:auro_wallet/utils/colorsUtil.dart';

class NormalButton extends StatelessWidget {
  NormalButton({
    required this.text,
    this.textStyle,
    this.onPressed,
    this.icon,
    this.color,
    this.submitting = false,
    this.disabled = false,
    this.radius = 12,
    this.height = 48,
    this.shrink = false,
    this.padding = const EdgeInsets.only(top: 12, bottom: 12)
  }) : assert(text != null);

  final String text;
  final Function()? onPressed;
  final Widget? icon;
  final Color? color;
  final bool submitting;
  final bool disabled;
  final double radius;
  final bool shrink;
  final double height;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    if (submitting) {
      row.add(CupertinoActivityIndicator());
    }
    if (icon != null) {
      row.add(Padding(
        padding: EdgeInsets.only(right: 10),
        child: icon,
      ));
    }
    row.add(Text(
      text,
      style: textStyle ?? Theme.of(context).textTheme.button,
    ));
    Color normalColor = color ?? Theme.of(context).primaryColor;
    return ElevatedButton(
      // padding: padding,
      // highlightColor: ColorsUtil.darken(normalColor, 0.05),
      style: ElevatedButton.styleFrom(
          backgroundColor: normalColor,
          // onSurface: normalColor.withOpacity(0.5),
          minimumSize: Size(!shrink ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius))
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row,
      ),
      onPressed: submitting || disabled ? null : onPressed,
    );
  }
}
