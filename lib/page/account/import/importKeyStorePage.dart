import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/consts/enums.dart';

class ImportKeyStorePage extends StatefulWidget {
  const ImportKeyStorePage(this.store);

  static final String route = '/wallet/importkeystore';
  final AppStore store;

  @override
  _ImportKeyStorePageState createState() => _ImportKeyStorePageState(store);
}

class _ImportKeyStorePageState extends State<ImportKeyStorePage> {
  _ImportKeyStorePageState(this.store);

  final AppStore store;
  final TextEditingController _keyStoreCtrl = new TextEditingController();
  final TextEditingController _keyStorePasswordCtrl = new TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
    _keyStoreCtrl.dispose();
    _keyStorePasswordCtrl.dispose();
  }

  void _handleSubmit() async {
    final Map<String, String> dic = I18n.of(context).main;
    String keyStore = _keyStoreCtrl.text.trim();
    String keyStorePassword = _keyStorePasswordCtrl.text.trim();
    String? privateKey = await webApi.account.getPrivateKeyFromKeyStore(keyStore, keyStorePassword, context: context);
    if (privateKey != null) {
      Map<String,dynamic> params = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
      String accountName = params["accountName"];
      String? password = await UI.showPasswordDialog(context: context, wallet: store.wallet!.currentWallet, validate: true);
      if (password == null) {
        return;
      }
      setState(() {
        submitting = true;
      });
      var isSuccess = await webApi.account.createWalletByPrivateKey(accountName, privateKey, password, context: context, source: WalletSource.outside);
      setState(() {
        submitting = false;
      });
      if(isSuccess) {
        UI.toast(dic['backup_success_restore']!);
        Navigator.of(context).pop();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['accountImport']!),
        centerTitle: true,
      ),
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
                    InputItem(
                      label: dic['pleaseInputKeyPair']!,
                      controller: _keyStoreCtrl,
                      maxLines: 8,
                    ),
                    InputItem(
                      label: dic['pleaseInputKeyPairPwd']!,
                      controller: _keyStorePasswordCtrl,
                      isPassword: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    Flexible(
                      child: Text(dic['importAccount_2']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x4D000000), height: 1.2),)
                    ),
                    Flexible(
                        child: Text(dic['importAccount_3']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x4D000000), height: 1.2),)
                    ),
                  ]
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: NormalButton(
                    submitting: submitting,
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['confirm']!,
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