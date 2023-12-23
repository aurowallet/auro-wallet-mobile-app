import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/utils/i18n/terms.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    var theme = Theme.of(context).textTheme;
    var languageCode = widget.store.localeCode.isNotEmpty
        ? widget.store.localeCode
        : dic.localeName;
    print('languageCode' + languageCode);
    var aboutUsData = widget.store.aboutus;
    var termsUrl = '';
    var privacyUrl = '';
    if (aboutUsData != null) {
      if(languageCode == 'zh'){
        termsUrl = aboutUsData.termsAndContionsZH;
        privacyUrl = aboutUsData.privacyPolicyZH;
      }else{
        termsUrl = aboutUsData.termsAndContionsEN;
        privacyUrl = aboutUsData.privacyPolicyEN;
      }
    }

    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(0).copyWith(bottom: 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(dic.termsDialogTitle,
                    style: theme.headline3!.copyWith(
                      color: ColorsUtil.hexColor(0x333333),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 19, right: 20, left: 20),
                child: Terms(termsUrl: termsUrl, privacyUrl: privacyUrl)
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                height: 1,
                color: Colors.black.withOpacity(0.05),
              ),
              Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              // side: BorderSide(color: Colors.red)
                            )),
                        child: Text(dic.refuse, style: theme.headline5!),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    )),
                    Container(
                      width: 0.5,
                      height: 48,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    Expanded(
                        child: SizedBox(
                            height: 48,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    // side: BorderSide(color: Colors.red)
                                  )),
                              child: Text(dic.agree,
                                  style: theme.headline5!.copyWith(
                                      color: Theme.of(context).primaryColor)),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ))),
                  ]),
            ],
          ),
        )
      ]),
    );
  }
}
