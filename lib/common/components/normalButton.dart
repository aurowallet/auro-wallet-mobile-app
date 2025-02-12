import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  NormalButton(
      {required this.text,
      this.textStyle,
      this.onPressed,
      this.icon,
      this.color,
      this.submitting = false,
      this.disabled = false,
      this.radius = 12,
      this.height = 48,
      this.shrink = false,
      this.padding = EdgeInsets.zero});

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
      row.add(RotatingCircle(
        color: Colors.white,
        size: 24,
      ));
    } else {
      if (icon != null) {
        row.add(Padding(
          padding: EdgeInsets.only(right: 10),
          child: icon,
        ));
      }
      row.add(Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.merge(textStyle),
      ));
    }
    Color normalColor = color ?? Theme.of(context).primaryColor;
    return ElevatedButton(
      // highlightColor: ColorsUtil.darken(normalColor, 0.05),

      style: ElevatedButton.styleFrom(
        padding: padding,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor:
            submitting ? normalColor.withValues(alpha: 0.8) : normalColor,
        minimumSize: Size(!shrink ? double.infinity : 0, height),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: row,
      ),
      onPressed: disabled
          ? null
          : submitting
              ? () {}
              : onPressed,
    );
  }
}
