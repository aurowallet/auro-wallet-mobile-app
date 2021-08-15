import 'package:auro_wallet/utils/i18n/terms.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
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
            padding: EdgeInsets.all(20),
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
                Padding(
                  padding: EdgeInsets.only(top: 27),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 130,
                            minHeight: 40
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          highlightedBorderColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Text(dic['refuse']!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                      FlatButton(
                        height: 40,
                        minWidth: 130,
                        color: Theme.of(context).primaryColor,
                        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dic['agree']!, style: TextStyle(color: Colors.white, fontSize: 16))
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
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
