import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/backgroundContainer.dart';
import 'package:auro_wallet/common/components/customDropdownButton.dart';
import 'package:auro_wallet/common/components/termsDialog.dart';
import 'package:auro_wallet/page/account/termPage.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    var theme = Theme.of(context).textTheme;
    _ctx = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [
                                    0,
                                    1.0,
                                  ],
                                  colors: [
                                    Color(0xFF594AF1),
                                    Color(0xFFFF6B6B),
                                  ],
                                ),
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(bottom: 0, left: 20, right: 20),
                          child: SvgPicture.asset("assets/images/entry/desc.svg",),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 108),
                        child: Image.asset("assets/images/entry/auro_logo.png", width: 245, height: 221,),
                      ),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 38, right: 38),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    primary: ColorsUtil.hexColor(0x594AF1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _onClick('create');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset("assets/images/entry/icon_add.svg"),
                      SizedBox(width: 8,),
                      Text(I18n.of(context).main['createWallet']!, style: TextStyle(color: Colors.white, fontSize: 20))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 38, right: 38),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _onClick('import');
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/images/entry/icon_restore.svg"),
                      SizedBox(width: 8,),
                      Text(I18n.of(context).main['restoreWallet']!, style: TextStyle(color: ColorsUtil.hexColor(0x594AF1), fontSize: 20))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 31, 0, 0),
                child: Text(i18n.main['restoreTip']!, style: theme.bodySmall?.copyWith(color: ColorsUtil.hexColor(0xCCCCCC)), textAlign: TextAlign.center,),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 21),
                child: Text('aurowallet.com', style: theme.bodySmall?.copyWith(color: ColorsUtil.hexColor(0xB9B9B9))),
              ),
            ],
          )
      ),
    );
  }
}

