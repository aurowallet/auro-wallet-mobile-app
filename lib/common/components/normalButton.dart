import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class NormalButton extends StatelessWidget {
  NormalButton({
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.submitting = false,
    this.disabled = false,
    this.radius = 8,
    this.padding = const EdgeInsets.only(top: 12, bottom: 12)
  }) : assert(text != null);

  final String text;
  final Function()? onPressed;
  final Widget? icon;
  final Color? color;
  final bool submitting;
  final bool disabled;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    if (submitting) {
      row.add(CupertinoActivityIndicator());
    }
    if (icon != null) {
      row.add(Container(
        width: 32,
        child: icon,
      ));
    }
    row.add(Text(
      text,
      style: Theme.of(context).textTheme.button,
    ));
    Color normalColor = color ?? Theme.of(context).primaryColor;
    return RaisedButton(
      padding: padding,
      color: normalColor,
      disabledColor: normalColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      // highlightColor: ColorsUtil.darken(normalColor, 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row,
      ),
      onPressed: submitting || disabled ? null : onPressed,
    );
  }
}
