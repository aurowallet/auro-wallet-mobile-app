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
      newLineAsBreaks: true,
      styles: {
        'red': st.copyWith(color: Colors.red),
        'theme': st.copyWith(color: primaryColor),
        'link': ActionTextStyle(
          color: primaryColor,
          decoration: TextDecoration.none,
          onTap: (TextSpan? text, Map<String?, String?>? attrs) {
            if (attrs != null) {
              final String? link = attrs['href'];
              final String? route = attrs['route'];
              if (link == 'aurowallet://back') {
                if (route != null) {
                  Navigator.popUntil(context, ModalRoute.withName(route));
                } else {
                  Navigator.of(context).pop();
                }
              }
              print('The "$link" link is tapped.');
            }
          },
        ),
      },
    );
  }
}
