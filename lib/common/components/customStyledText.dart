import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class CustomStyledText extends StatelessWidget {
  CustomStyledText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final st = style ?? TextStyle();
    final primaryColor = Theme.of(context).primaryColor;
    return StyledText(
      text: text,
      style: st,
      styles: {
        'red': st.copyWith(color: Colors.red),
        'theme': st.copyWith(color: primaryColor),
        'link': ActionTextStyle(
          color: primaryColor,
          decoration: TextDecoration.underline,
          onTap: (TextSpan? text, Map<String?, String?>? attrs) {
            if (attrs != null) {
              final String? link = attrs['href'];
              print('The "$link" link is tapped.');
            }
          },
        ),
      },
    );
  }
}
