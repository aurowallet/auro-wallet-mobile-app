import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExportMnemonicResultPage extends StatelessWidget {
  static final String route = '/setting/export_mnemonic_result';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['restoreSeed']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                children: <Widget>[
                  Text(dic['show_seed_content']!, style: textTheme.headline5!.copyWith(color: ColorsUtil.hexColor(0x333333))),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: ColorsUtil.hexColor(0xe5e5e5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.all(23),
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      args['key']!,
                      style: textTheme.headline5!.copyWith(color: ColorsUtil.hexColor(0x333333), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
