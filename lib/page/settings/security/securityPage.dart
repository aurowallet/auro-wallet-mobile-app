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
import 'package:auro_wallet/page/account/accountNamePage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/settings/security/changePasswordPage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage(this.store);

  static final String route = '/setting/security';
  final AppStore store;

  @override
  _SecurityPageState createState() => _SecurityPageState(store);
}

class _SecurityPageState extends State<SecurityPage> {
  _SecurityPageState(this.store);

  final AppStore store;


  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
  }

  void _onBackup() async {
    print('pri');
    final Map<String, String> dic = I18n.of(context).main;
    await UI.showAlertDialog(
      context: context,
      crossAxisAlignment: CrossAxisAlignment.start,
      contents:[
        dic['backTips_1']!,
        '',
        dic['backTips_2']!,
        '',
        dic['backTips_3']!,
      ],
    );
    WalletData? wallet = (store.wallet!.walletList as List<WalletData?>).firstWhere((wallet) => wallet!.walletType == WalletStore.seedTypeMnemonic, orElse: ()=> null);
    if (wallet == null) {
      return;
    }
    String? password = await UI.showPasswordDialog(context: context, wallet: store.wallet!.currentWallet);
    if (password == null) {
      return;
    }
    EasyLoading.show();
    String? mnemonic = await store.wallet!.getMnemonic(wallet, password);
    EasyLoading.dismiss();
    if (mnemonic == null) {
      UI.toast(dic['passwordError']!);
      return;
    }
    await Navigator.pushNamed(context, ExportMnemonicResultPage.route, arguments: {
      "key": mnemonic
    });
    // Navigator.pushReplacementNamed(context, AccountNamePage.route, arguments: AccountNameParams(
    //   redirect: ImportPrivateKeyPage.route
    // ));
  }

  void _onChangePassword() {
    print('changepassword');
    Navigator.pushReplacementNamed(context, ChangePasswordPage.route);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['security']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              ImportItem(text: dic['restoreSeed']!, onClick: _onBackup,),
              ImportItem(text: dic['changePassword']!, onClick: _onChangePassword,),
            ],
          )
        ),
      ),
    );
  }
}

class ImportItem extends StatelessWidget {
  ImportItem({
    required this.text,
    required this.onClick
  });

  final String text;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: ColorsUtil.hexColor(0xeeeeee))),
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: ColorsUtil.hexColor(0x010000)),),
            Container(
                width: 6,
                margin: EdgeInsets.only(left: 14,),
                child: SvgPicture.asset(
                    'assets/images/assets/right_arrow.svg',
                    width: 6,
                    height: 12
                )
            ),
          ],
        )
      )
    );
  }
}
