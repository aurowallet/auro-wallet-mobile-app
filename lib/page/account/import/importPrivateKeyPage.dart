import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/common/consts/enums.dart';


class ImportPrivateKeyPage extends StatefulWidget {
  const ImportPrivateKeyPage(this.store);

  static final String route = '/wallet/importprivate';
  final AppStore store;

  @override
  _ImportPrivateKeyPageState createState() => _ImportPrivateKeyPageState(store);
}

class _ImportPrivateKeyPageState extends State<ImportPrivateKeyPage> {
  _ImportPrivateKeyPageState(this.store);

  final AppStore store;
  final TextEditingController _privateKeyCtrl = new TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
    _privateKeyCtrl.dispose();
  }

  void _handleSubmit() async {
    UI.unfocus(context);
    final Map<String, String> dic = I18n.of(context).main;
    String privateKey = _privateKeyCtrl.text.trim();
    bool isPrivateKeyValid = await webApi.account.isPrivateKeyValid(privateKey);
    if (!isPrivateKeyValid) {
      UI.toast(dic['privateError']!);
      return;
    }
    Map params = ModalRoute.of(context)!.settings.arguments as Map;
    String accountName = params["accountName"];
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        validate: true,
        inputPasswordRequired: true
    );
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
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    InputItem(
                      padding: EdgeInsets.zero,
                      inputPadding: EdgeInsets.only(top: 20),
                      label: dic['pleaseInputPriKey']!,
                      controller: _privateKeyCtrl,
                      maxLines: 3,
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
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
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