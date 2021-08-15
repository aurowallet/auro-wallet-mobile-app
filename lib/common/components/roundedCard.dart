import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
enum RoundedCardType {
  normal,
  small
}
class RoundedCard extends StatelessWidget {
  RoundedCard({this.border, this.margin, this.padding, this.child, this.type = RoundedCardType.normal});

  final BoxBorder? border;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final RoundedCardType type;

  @override
  Widget build(BuildContext context) {
    double radius;
    switch(type) {
      case RoundedCardType.small:
        radius = 10;
        break;
      default:
        radius = 20;
        break;
    }
    return Container(
      margin: margin,
      padding: padding,
      child: child,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16.0, // has the effect of softening the shadow
            spreadRadius: 4.0, // has the effect of extending the shadow
            offset: Offset(
              2.0, // horizontal, move right 10
              2.0, // vertical, move down 10
            ),
          )
        ],
      ),
    );
  }
}
