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

class ImportWatchedAccountPage extends StatefulWidget {
  const ImportWatchedAccountPage(this.store);

  static final String route = '/wallet/watchmode';
  final AppStore store;

  @override
  _ImportWatchedAccountPageState createState() =>
      _ImportWatchedAccountPageState(store);
}

class _ImportWatchedAccountPageState extends State<ImportWatchedAccountPage> {
  _ImportWatchedAccountPageState(this.store);

  final AppStore store;
  final TextEditingController _watchedAccountCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _watchedAccountCtrl.dispose();
  }

  void _handleSubmit() async {
    final Map<String, String> dic = I18n.of(context).main;
    String watchedAccount = _watchedAccountCtrl.text.trim();
    bool isValid = await webApi.account.isAddressValid(watchedAccount);
    if (!isValid) {
      UI.toast(dic['sendAddressError']!);
      return;
    }
    Map params = ModalRoute.of(context)!.settings.arguments as Map;
    String accountName = params["accountName"];
    var isSuccess = await webApi.account.createExternalWallet(
        accountName, watchedAccount,
        context: context, source: WalletSource.outside);
    if (isSuccess) {
      UI.toast(dic['backup_success_restore']!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['watchAccount']!),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: InputItem(
                    label: dic['textWatchModeAddress']!,
                    controller: _watchedAccountCtrl,
                    maxLines: 3,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                    child: NormalButton(
                      color: ColorsUtil.hexColor(0x6D5FFE),
                      text: I18n.of(context).main['confirm']!,
                      onPressed: _handleSubmit,
                    )),
              ],
            )),
      ),
    );
  }
}
