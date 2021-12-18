import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class CustomStyledText extends StatelessWidget {
  CustomStyledText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final st = style ?? TextStyle();
    return StyledText(
      text: text,
      style: st,
      styles: {
        'red': st.copyWith(color: Colors.red),
      },
    );
  }
}
