import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
class CopyContainer extends StatelessWidget {
  CopyContainer({this.text, required this.child});
  final String? text;
  final Widget child;

  void _copyAddress(BuildContext context) {
    UI.copyAndNotify(context, text!);
  }
  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return child;
    }
    return  GestureDetector(
        child: child,
        onTap: () {
          _copyAddress(context);
        }
    );
  }
}