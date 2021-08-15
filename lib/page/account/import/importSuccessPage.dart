import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
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
    final Map<String, String> dic = I18n.of(context).main;
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    String type = args['type'];
    bool isRestore = type == 'restore';

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['backup_success_title']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8),child:  Image.asset('assets/images/public/wallet_success.png', width: 110, height: 110),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(dic['backupSuccess']!, style: TextStyle(color: ColorsUtil.hexColor(0x38D79F), fontWeight: FontWeight.w600))
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 21, right: 0, left: 0),
                        child: Text(isRestore ? dic['backup_success_restore']! : dic['backup_success']!, style: TextStyle(color: ColorsUtil.hexColor(0x666666), fontWeight: FontWeight.w600))
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['startHome']!,
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