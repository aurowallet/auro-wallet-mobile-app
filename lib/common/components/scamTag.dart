import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';

class ScamTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFD65A5A),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(2)),
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      child: Text(
        // text:
        I18n.of(context).main['scam']!,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFD65A5A)),
      ),
    );
  }
}
