import 'package:auro_wallet/page/account/walletManagePage.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class CustomStyledText extends StatelessWidget {
  CustomStyledText(
      {required this.text, this.style, this.textAlign = TextAlign.left, this.onLinkTap});

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final st = style ?? TextStyle();
    final primaryColor = Theme.of(context).primaryColor;
    return StyledText(
      text: text,
      style: st,
      textAlign: textAlign,
      newLineAsBreaks: true,
      textScaler: MediaQuery.of(context).textScaler,
      tags: {
        'bold': StyledTextTag(style: TextStyle(fontWeight: FontWeight.w900)),
        'semiBold': StyledTextTag(style: TextStyle(fontWeight: FontWeight.w700)),
        'red': StyledTextTag(
            style: st.copyWith(color: Color(0xFFD65A5A), fontWeight: FontWeight.w900)),
        'lightred' :StyledTextTag(
            style: st.copyWith(color: Color(0xFFD65A5A), fontWeight: FontWeight.w400)),
        'theme': StyledTextTag(style: st.copyWith(color: primaryColor)),
        'link': StyledTextActionTag(
          (String? text, Map<String?, String?> attrs) {
            if (onLinkTap != null) {
              onLinkTap!();
              return;
            }
            final String? link = attrs['href'];
            final String? route = attrs['route'];
            if (link == 'aurowallet://back') {
              if (route != null) {
                Navigator.popUntil(context, ModalRoute.withName(route));
              } else {
                Navigator.of(context).pop();
              }
            } else if (link != null && link.startsWith('http')) {
              UI.launchURL(link);
            }
          },
          style: TextStyle(
              decoration: TextDecoration.none,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500),
        ),
        'acmanage': StyledTextActionTag(
          (String? text, Map<String?, String?> attrs) {
              Navigator.popUntil(context, ModalRoute.withName(WalletManagePage.route));
          },
          style: TextStyle(
              decoration: TextDecoration.none, color: primaryColor),
        ),
        'yellowBold': StyledTextTag(
            style: st.copyWith(color: Color(0xFFE4B200), fontWeight: FontWeight.w700)),
        'yellow': StyledTextTag(
            style: st.copyWith(color: Color(0xFFE4B200), fontWeight: FontWeight.w700)),
        'strongBlack':StyledTextTag(style: TextStyle(color: Color(0xCC000000))),
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
