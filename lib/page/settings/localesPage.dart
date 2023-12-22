import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class LocalesPage extends StatefulWidget {
  LocalesPage(this.store, this.changeLang);
  static final String route = '/profile/locales';
  final SettingsStore store;
  final Function changeLang;
  @override
  _Settings createState() => _Settings(store, changeLang);
}

class _Settings extends State<LocalesPage> {
  _Settings(this.store, this.changeLang);

  final SettingsStore store;
  final Function changeLang;

  void _onChangeLocale(bool isChecked, String code) {
    if (isChecked && code != store.localeCode) {
      store.setLocalCode(code);
      changeLang(context, code);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.language),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          var languageCode = store.localeCode.isNotEmpty ? store.localeCode : dic.localeName.toLowerCase();
          return SafeArea(
            maintainBottomViewPadding: true,
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              children: <Widget>[
                LocaleItem(text: languageConfig['en'].toString(), localeKey: 'en', checked: languageCode == 'en', onChecked: _onChangeLocale,),
                LocaleItem(text: languageConfig['zh'].toString(), localeKey: 'zh', checked: languageCode == 'zh', onChecked: _onChangeLocale,),
              ],
            ),
          );
        },
      ),
    );
  }
}
class LocaleItem extends StatelessWidget {
  LocaleItem(
      {
        this.checked = false,
        required this.text,
        required this.localeKey,
        required this.onChecked,
      });
  final bool checked;
  final String text;
  final String localeKey;
  final void Function(bool, String) onChecked;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      child: ListTile(
        leading: null,
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        selectedColor: Colors.red,
        focusColor: Colors.amber,
        title: Text(text, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: checked ? RoundCheckBox(
          size: 18,
          borderColor: Colors.transparent,
          isChecked: checked,
          uncheckedColor: Colors.white,
          checkedColor: Theme.of(context).primaryColor,
          checkedWidget: Icon(Icons.check, color: Colors.white, size: 12,),
          // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
          onTap: (bool? checkedFlag) {
            onChecked(checkedFlag!, localeKey);
          },
        ) : null,
        onTap: () => onChecked(!checked, localeKey),
      )
    );
  }
}