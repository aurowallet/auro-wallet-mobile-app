import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/page/settings/remoteNodeListPage.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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

  final _langOptions = [null, 'en', 'zh'];

  int _selected = 0;

  void _onChangeLocale(bool isChecked, String code) {
    if (isChecked && code != store.localeCode) {
      EasyLoading.show(status: '');
      store.setLocalCode(code);
      changeLang(context, code);
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).main['setting']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          var languageCode = store.localeCode.isNotEmpty ? store.localeCode : i18n.locale.languageCode.toLowerCase();
          return SafeArea(
            child: ListView(
              padding: EdgeInsets.only(left: 30, right: 30),
              children: <Widget>[
                LocaleItem(text: 'English', localeKey: 'en', checked: languageCode == 'en', onChecked: _onChangeLocale,),
                LocaleItem(text: '中文（简体）', localeKey: 'zh', checked: languageCode == 'zh', onChecked: _onChangeLocale,),
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
    return FormPanel(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: null,
        title: Text(text, style: TextStyle(color: ColorsUtil.hexColor(0x01000D), fontWeight: FontWeight.w500)),
        trailing: RoundCheckBox(
          isChecked: checked,
          uncheckedColor: Colors.white,
          checkedColor: ColorsUtil.hexColor(0x59c49c),
          // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
          onTap: (bool? checkedFlag) {
            onChecked(checkedFlag!, localeKey);
          },
        ),
        onTap: () => onChecked(!checked, localeKey),
      )
    );
  }
}