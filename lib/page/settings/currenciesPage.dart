import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/service/api/api.dart';

class CurrenciesPage extends StatefulWidget {
  CurrenciesPage(this.store);
  static final String route = '/profile/currencies';
  final SettingsStore store;
  @override
  _Currencies createState() => _Currencies(store);
}

class _Currencies extends State<CurrenciesPage> {
  _Currencies(this.store);

  final SettingsStore store;

  void onChange(bool isChecked, String code) async {
    if (isChecked && code != store.currencyCode) {
       await store.setCurrencyCode(code);
       print(store.currencyCode);
       await webApi.assets.fetchAccountInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).main['currency']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          return SafeArea(
            child: ListView(
              padding: EdgeInsets.only(left: 30, right: 30),
              children: <Widget>[
                LocaleItem(text: 'USD', localeKey: 'usd', checked: store.currencyCode == 'usd', onChecked: onChange,),
                LocaleItem(text: 'CNY', localeKey: 'cny', checked: store.currencyCode == 'cny', onChecked: onChange,),
                LocaleItem(text: 'RUB', localeKey: 'rub', checked: store.currencyCode == 'rub', onChecked: onChange,),
                LocaleItem(text: 'EUR', localeKey: 'eur', checked: store.currencyCode == 'eur', onChecked: onChange,),
                LocaleItem(text: 'GBP', localeKey: 'gbp', checked: store.currencyCode == 'gbp', onChecked: onChange,),
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
          onTap: (bool? checkedFlag) {
            onChecked(checkedFlag ?? false, localeKey);
          },
        ),
        onTap: () => onChecked(!checked, localeKey),
      )
    );
  }
}