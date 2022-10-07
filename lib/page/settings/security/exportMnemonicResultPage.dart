import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExportMnemonicResultPage extends StatelessWidget {
  static final String route = '/setting/export_mnemonic_result';

  Widget buildWords (context) {
    List<Widget> cells = <Widget>[];
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final words = args['key']!.split(' ');
    for (var index = 0; index < words.length; index++) {
      String word = words[index];
      cells.add(Container(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: Container(
            padding: EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: new RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${index + 1}. ',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      TextSpan(
                        text: '$word',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ])),

          )));
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4666,
      children: cells,
    );
  }
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                children: <Widget>[
                  Text(dic['show_seed_content']!, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.only(top: 20),
                    child: this.buildWords(context),
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
