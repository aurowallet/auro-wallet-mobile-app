import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class LedgerWaitingContent extends StatelessWidget {
  const LedgerWaitingContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(top: 30),
          child: Center(
            child: RotatingCircle(
              size: 58,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Text(
            dic.waitingLedgerSign,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF808080),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 40,left: 30,right: 30),
          child: Center(
            child: StyledText(
                text: dic.ledgerAddressTip3,
                textAlign: TextAlign.center,
                newLineAsBreaks: true,
                style: TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500),
                tags: {
                  'yellowBold': StyledTextTag(
                      style: TextStyle(
                          color: Color(0xFFE4B200),
                          fontWeight: FontWeight.w700)),
                  'yellow': StyledTextTag(
                      style: TextStyle(
                          color: Color(0xFFE4B200),
                          fontWeight: FontWeight.w500)),
                }),
          ),
        ),
      ],
    );
  }
}
