import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/currenciesPage.dart';
import 'package:auro_wallet/page/settings/localesPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this.store);

  static final String route = '/setting/preferences';
  final AppStore store;

  @override
  _PreferencesPageState createState() => _PreferencesPageState(store);
}

class _PreferencesPageState extends State<PreferencesPage> {
  _PreferencesPageState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.perferences),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          var languageCode = store.settings!.localeCode.isNotEmpty
              ? store.settings!.localeCode
              : dic.localeName.toLowerCase();
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    MenuItem(
                      text: dic.language,
                      value: languageConfig[languageCode],
                      onClick: () =>
                          Navigator.of(context).pushNamed(LocalesPage.route),
                    ),
                    MenuItem(
                      text: dic.currency,
                      value: store.settings?.currencyCode.toUpperCase(),
                      onClick: () =>
                          Navigator.of(context).pushNamed(CurrenciesPage.route),
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  MenuItem({required this.text, required this.onClick, this.value});

  final String text;
  final void Function() onClick;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: Container(
            height: 54,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    value != null
                        ? Text(
                            value!,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0x4D000000)),
                          )
                        : Container(),
                    Container(
                        width: 6,
                        margin: EdgeInsets.only(
                          left: 14,
                        ),
                        child: SvgPicture.asset(
                            'assets/images/assets/right_arrow.svg',
                            width: 6,
                            height: 12,
                            colorFilter: ColorFilter.mode(
                                Color(0x4D000000), BlendMode.srcIn)))
                  ],
                )
              ],
            )));
  }
}
