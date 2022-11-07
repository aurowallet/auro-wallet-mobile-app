import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';


class RootAlertPage extends StatefulWidget {
  const RootAlertPage();


  @override
  _RootAlertPageState createState() => _RootAlertPageState();
}

class _RootAlertPageState extends State<RootAlertPage> {
  _RootAlertPageState();

  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }
  @override
  void dispose() {
    super.dispose();
    _nameCtrl.dispose();
  }

  void _handleConfirm() async {
    Future.delayed(const Duration(milliseconds: 500), () {
      exit(0);
    });
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 100

                      ),
                    ),
                    SvgPicture.asset(
                        'assets/images/public/red_alert.svg',
                        width: 110,
                        height: 97
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 47),
                      child: Text(
                        dic['rootTip']!,
                        textAlign: TextAlign.center,
                        style: theme.headline4
                      ),
                    )
                  ]
                )
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child:
                  NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['confirm']!,
                    onPressed: _handleConfirm,
                  )

              )
            ],
          ),
        )
      ),
    );
  }
}
