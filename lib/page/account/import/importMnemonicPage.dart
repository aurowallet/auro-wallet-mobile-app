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
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/page/account/import/importSuccessPage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/common/consts/enums.dart';

class ImportMnemonicPage extends StatefulWidget {
  const ImportMnemonicPage(this.store);

  static final String route = '/wallet/import_mnemonic';
  final AppStore store;

  @override
  _ImportMnemonicPageState createState() => _ImportMnemonicPageState(store);
}

class _ImportMnemonicPageState extends State<ImportMnemonicPage> {
  _ImportMnemonicPageState(this.store);

  final AppStore store;
  final TextEditingController _mnemonicCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
    _mnemonicCtrl.dispose();
  }
  Future<bool> _checkAccountDuplicate(Map<String, dynamic> acc) async {
    final Map<String, String> dic = I18n.of(context).main;
    int index = store.wallet!.walletList.indexWhere((i) => i.id == acc['pubKey']);
    if (index > -1) {
      UI.toast(dic['improtRepeat']!);
      return true;
    }
    return false;
  }
  void _handleSubmit() async {
    final Map<String, String> dic = I18n.of(context).main;
    String mnemonic = _mnemonicCtrl.text.trim();
    bool isMnemonicValid = webApi.account.isMnemonicValid(mnemonic);
    if (!isMnemonicValid) {
      UI.toast(dic['seed_error']!);
      return;
    }
    EasyLoading.show(status: '');
    widget.store.wallet!.setNewWalletSeed(mnemonic, WalletStore.seedTypeMnemonic);
    var acc = await webApi.account.importWalletByWalletParams();
    final duplicated = await _checkAccountDuplicate(acc);
    if (duplicated) {
      return;
    }
    await webApi.account.saveWallet(
        acc,
        context: context,
        seedType: WalletStore.seedTypeMnemonic,
        walletSource:  WalletSource.outside
    );
    widget.store.wallet!.resetNewWallet();
    EasyLoading.dismiss();
    await Navigator.pushNamedAndRemoveUntil(context, ImportSuccessPage.route, (Route<dynamic> route) => false, arguments: {
      'type': 'restore'
    });
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['restoreWallet']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: <Widget>[
              Expanded(
                child: InputItem(
                  initialValue: '',
                  label: dic['inputSeed']!,
                  controller: _mnemonicCtrl,
                  backgroundColor: Colors.transparent,
                  borderColor: ColorsUtil.hexColor(0xE5E5E5),
                  focusColor: Theme.of(context).primaryColor,
                  inputPadding: EdgeInsets.only(top: 20),
                  maxLines: 6,
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: NormalButton(
                    color: ColorsUtil.hexColor(0x6D5FFE),
                    text: I18n.of(context).main['confirm']!,
                    onPressed: _handleSubmit,
                  )
              )

            ],
          )
        ),
      ),
    );
  }
}