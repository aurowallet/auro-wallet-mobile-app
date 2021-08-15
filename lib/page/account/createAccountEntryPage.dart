import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:auro_wallet/common/components/customDropdownButton.dart';
import 'package:auro_wallet/common/components/termsDialog.dart';
import 'package:auro_wallet/page/account/termPage.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as sp;
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/page/account/setNewWalletPasswordPage.dart';

class CreateAccountEntryPage extends StatelessWidget {
  CreateAccountEntryPage(this.store, this.changeLang);

  static final String route = '/account/entry';
  final SettingsStore store;
  final Function changeLang;
  BuildContext? _ctx;
  void _onClick(String type) async {
    bool? agree = await showDialog<bool?>(
      context: _ctx!,
      builder: (_) {
        return TermsDialog(store: store,);
      },
    );
    if (agree == true) {
      Navigator.pushNamed(_ctx!, SetNewWalletPasswordPage.route, arguments:{"type": type});
    }
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context);
    var languageCode = store.localeCode.isNotEmpty ? store.localeCode : i18n.locale.languageCode.toLowerCase();
    _ctx = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: BackgroundContainer(
        sp.Svg(
          'assets/images/public/top_cornor.svg',
        ),
        SafeArea(
          child:  Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset("assets/images/public/2x/m_logo@2x.png", width: 121, height: 30,) ,
                      ),
                      CustomDropdownButton(
                        items: [
                          DropdownItem(text: '中文', key: 'zh'),
                          DropdownItem(text: 'English', key: 'en'),
                        ],
                        value: languageCode,
                        onChoose: (String? value) {
                          if (value != null) {
                            changeLang(context, value);
                          }
                        },
                        placeholder: '',
                      )
                    ],
                  )
                ],
              ),
                ),
          ),
              Padding(
                padding: EdgeInsets.all(16),
                child: EntryButton(text: I18n.of(context).main['createAccount']!, onPressed: () {
                  _onClick('create');
                  // Navigator.pushNamed(context, TermPage.route, arguments: TermParams(arguments: {"type": "create"}));
                },),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: EntryButton(
                  text: I18n.of(context).main['importAccount']!,
                  isOutlined: true,
                  onPressed: () {
                    _onClick('import');
                    // Navigator.pushNamed(context, TermPage.route, arguments: TermParams(arguments: {"type": "import"}));
                },),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 100, 16, 30),
                child: Text('Powered by Bit Cat', style: TextStyle(fontSize: 14, color: ColorsUtil.hexColor(0xB9B9B9))),
              ),
            ],
          ),
        )
      )
    );
  }
}

class EntryButton extends StatelessWidget {
  EntryButton({required this.text, this.onPressed, this.isOutlined = false});

  final String text;
  final bool isOutlined;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    Color color = isOutlined ? Theme.of(context).primaryColor : Colors.white;
    return GestureDetector(
        child: Container(
            width: 315,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              image: isOutlined ? null : DecorationImage(
                  image: AssetImage("assets/images/public/2x/create_btn_bg@2x.png"),
                  fit: BoxFit.cover
              ),
              border: isOutlined ? Border.all(
                  color: color,
                  width: 1
              ): null,
              borderRadius: BorderRadius.circular(55),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(text, style: TextStyle(color: color, fontSize: 20)),
                  SvgPicture.asset(
                    'assets/images/public/button_arrow.svg',
                    width: 18,
                    height: 12,
                    color: color,
                  ),
                ],
              )
            ) // button text
        ),
        onTap: onPressed
    );
  }
}