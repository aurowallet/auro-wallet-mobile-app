import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class CustomDivider extends StatelessWidget {
  CustomDivider({
    this.margin = const EdgeInsets.symmetric(vertical: 9, horizontal: 0)
  });
  final EdgeInsets margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: 1,
      color: ColorsUtil.hexColor(0xf5f5f5),
    );
  }
}