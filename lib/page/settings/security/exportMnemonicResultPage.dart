import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ExportMnemonicResultPage extends StatelessWidget {
  static final String route = '/setting/export_mnemonic_result';

  Widget buildWords(context) {
    List<Widget> cells = <Widget>[];
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final words = args['key']!.split(' ');
    final borderRadius =
        20 * ((MediaQuery.of(context).size.width - 20 * 2 - 12 * 2) / 3 / 104);
    for (var index = 0; index < words.length; index++) {
      String word = words[index];
      cells.add(Container(
          padding: EdgeInsets.only(left: 0, right: 0),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: new RichText(
              textScaler: MediaQuery.textScalerOf(context),
              text: TextSpan(children: [
                TextSpan(
                  text: '${index + 1}. ',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: '$word',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ]),
            ),
          )));
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 20,
      childAspectRatio: 3.4666,
      children: cells,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.restoreSeed),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                children: <Widget>[
                  Text(dic.show_seed_content,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
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
