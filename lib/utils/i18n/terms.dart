import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class Terms extends StatelessWidget {
  Terms({required this.termsUrl, required this.privacyUrl});
  final String termsUrl;
  final String privacyUrl;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var normalStyle =
        theme.headlineMedium!.copyWith(color: ColorsUtil.hexColor(0x666666));
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Text(
              dic.termsAndPrivacy_line1,
              style: normalStyle,
            )),
        new StyledText(
            text: dic.termsAndPrivacy_line2,
            style: normalStyle,
            tags: {
              "conditions": StyledTextActionTag(
                (String? text, Map<String?, String?> attrs) {
                  final String? link = attrs['href'];
                  final String? route = attrs['route'];
                  launch(termsUrl);
                  print('The "$link" link is tapped.');
                },
                style: theme.headlineMedium!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              "policy": StyledTextActionTag(
                  (String? text, Map<String?, String?> attrs) {
                final String? link = attrs['href'];
                final String? route = attrs['route'];
                launch(privacyUrl);
                print('The "$link" link is tapped.');
              },
                  style: theme.headlineMedium!
                      .copyWith(color: Theme.of(context).primaryColor)),
            })
      ],
    );
  }
}
