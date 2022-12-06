import 'package:auro_wallet/utils/i18n/terms.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/store/settings/settings.dart';


class TermsDialog extends StatefulWidget {
  TermsDialog({required this.store});
  final SettingsStore store;

  @override
  _TermsDialogState createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    var i18n = I18n.of(context);
    var theme = Theme.of(context).textTheme;
    var languageCode = widget.store.localeCode.isNotEmpty ? widget.store.localeCode : i18n.locale.languageCode.toLowerCase();
    print('languageCode'+languageCode);
    var aboutUsData = widget.store.aboutus;
    var termsUrl = '';
    var privacyUrl = '';
    if (aboutUsData != null) {
      switch(languageCode) {
        case 'en':
          termsUrl = aboutUsData.termsAndContionsEN;
          privacyUrl = aboutUsData.privacyPolicyEN;
          break;
        case 'zh':
          termsUrl = aboutUsData.termsAndContionsZH;
          privacyUrl = aboutUsData.privacyPolicyZH;
          break;
      }
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20).copyWith(bottom: 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(dic['termsDialogTitle']!, style: theme.headline3!.copyWith(color: ColorsUtil.hexColor(0x333333),)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 19),
                  child: languageCode == 'en' ? TermsEN(
                      termsUrl: termsUrl,
                      privacyUrl: privacyUrl
                  ): TermsZH(
                      termsUrl: termsUrl,
                      privacyUrl: privacyUrl
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  height: 1,
                  color: Colors.black.withOpacity(0.05),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.black
                        ),
                        child: Text(dic['refuse']!, style: theme.headline5!),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),),
                      Container(
                        width: 0.5,
                        height: 48,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      Expanded(child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor
                        ),
                        child: Text(dic['agree']!, style: theme.headline5!.copyWith(color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )),
                    ]
                ),
              ],
            ),
          )
        ]
      ),
    );
  }
}
