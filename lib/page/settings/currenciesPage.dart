import 'package:auro_wallet/common/consts/Currency.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
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
      webApi.assets.fetchAllTokenAssets();
      Navigator.of(context).pop();
    }
  }

  Widget _renderCurrencyList(BuildContext context) {
    return ListView.builder(
        itemCount: currencyConfig.length,
        itemBuilder: (context, index) {
          Currency item = currencyConfig[index];
          return CurrencyItem(
            text: item.value,
            localeKey: item.key,
            checked: store.currencyCode == item.key,
            onChecked: onChange,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.currency),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Container(
                padding: EdgeInsets.only(top: 20),
                child: _renderCurrencyList(context)),
          );
        },
      ),
    );
  }
}
class CurrencyItem extends StatelessWidget {
  CurrencyItem({
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
          title: Text(text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          trailing: checked
              ? RoundCheckBox(
                  size: 18,
                  borderColor: Colors.transparent,
                  isChecked: checked,
                  uncheckedColor: Colors.white,
                  checkedColor: Theme.of(context).primaryColor,
                  checkedWidget: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                  onTap: (bool? checkedFlag) {
                    onChecked(checkedFlag ?? false, localeKey);
                  },
                )
              : null,
          onTap: () => onChecked(!checked, localeKey),
        ));
  }
}