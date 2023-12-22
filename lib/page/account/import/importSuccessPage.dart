import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';


class ImportSuccessPage extends StatefulWidget {
  const ImportSuccessPage(this.store);

  static final String route = '/wallet/import_success';
  final AppStore store;

  @override
  _ImportSuccessPageState createState() => _ImportSuccessPageState(store);
}

class _ImportSuccessPageState extends State<ImportSuccessPage> {
  _ImportSuccessPageState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
  }

  void _handleSubmit() async {
    Navigator.of(context).pushReplacementNamed('/');
  }
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    String type = args['type'];
    bool isRestore = type == 'restore';

    return Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 162),child:  Image.asset('assets/images/public/wallet_success.png', width: 213, height: 182),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Text(dic.backupSuccess, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 22))
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 18, right: 0, left: 0),
                        child: Text(isRestore ? dic.backup_success_restore : dic.backup_success, style: TextStyle(color: Color(0x80000000), fontWeight: FontWeight.w500, fontSize: 16), textAlign: TextAlign.center,)
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
                  child: NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: dic.startHome,
                    onPressed: _handleSubmit,
                  )
              ),
            ],
          )
        ),
      ),
    );
  }
}