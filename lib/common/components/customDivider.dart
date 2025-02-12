import 'package:flutter/material.dart';

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
      color: Color(0x1A000000),
    );
  }
}