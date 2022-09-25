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
              padding: EdgeInsets.only(top: 20),
              children: <Widget>[
                CurrencyItem(text: 'USD', localeKey: 'usd', checked: store.currencyCode == 'usd', onChecked: onChange,),
                CurrencyItem(text: 'CNY', localeKey: 'cny', checked: store.currencyCode == 'cny', onChecked: onChange,),
                CurrencyItem(text: 'RUB', localeKey: 'rub', checked: store.currencyCode == 'rub', onChecked: onChange,),
                CurrencyItem(text: 'EUR', localeKey: 'eur', checked: store.currencyCode == 'eur', onChecked: onChange,),
                CurrencyItem(text: 'GBP', localeKey: 'gbp', checked: store.currencyCode == 'gbp', onChecked: onChange,),
              ],
            ),
          );
        },
      ),
    );
  }
}
class CurrencyItem extends StatelessWidget {
  CurrencyItem(
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
          title: Text(text, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          trailing: RoundCheckBox(
            size: 18,
            borderColor: Colors.transparent,
            isChecked: checked,
            uncheckedColor: Colors.white,
            checkedColor: Theme.of(context).primaryColor,
            checkedWidget: Icon(Icons.check, color: Colors.white, size: 12,),
            onTap: (bool? checkedFlag) {
              onChecked(checkedFlag ?? false, localeKey);
            },
          ),
          onTap: () => onChecked(!checked, localeKey),
        )
    );
  }
}