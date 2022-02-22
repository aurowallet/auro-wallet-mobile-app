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
      tags: {
        'red': StyledTextTag(style: st.copyWith(color: Colors.red)),
        'theme': StyledTextTag(style: st.copyWith(color: primaryColor)),
        'link': StyledTextActionTag(
              (String? text, Map<String?, String?> attrs)  {
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
          },
            style: TextStyle(decoration: TextDecoration.underline, color: primaryColor),
        ),
      },
    );
  }
}

/*
if (attrs != null) {
    if (link == 'aurowallet://back') {
    if (route != null) {
    Navigator.popUntil(context, ModalRoute.withName(route));
    } else {
    Navigator.of(context).pop();
    }
    }
    print('The "$link" link is tapped.');
    }
* */
