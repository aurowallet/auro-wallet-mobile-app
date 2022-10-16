import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/page/account/accountNamePage.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/settings/security/changePasswordPage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_switch/flutter_switch.dart';


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
  bool _isBiometricAuthorized = false;
  bool _supportBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();

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
    WalletData? wallet = store.wallet!.walletList.firstWhereOrNull((wallet) => wallet.walletType == WalletStore.seedTypeMnemonic);
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

  Future<void> _checkBiometricAuth() async {
    final response = await BiometricStorage().canAuthenticate();
    final supportBiometric = response == CanAuthenticateResponse.success;
    if (!supportBiometric) {
      return;
    }
    setState(() {
      _supportBiometric = supportBiometric;
    });
    final isBiometricAuthorized = webApi.account.getBiometricEnabled();
    setState(() {
      _isBiometricAuthorized = isBiometricAuthorized;
    });
  }

  Future<void> _authBiometric() async {
    String? password = await UI.showPasswordDialog(context: context, wallet: store.wallet!.currentWallet, validate: true);

    try {
      if (password != null) {
        webApi.account.saveBiometricPass(context, password);
        webApi.account.setBiometricEnabled();
        setState(() {
          _isBiometricAuthorized = true;
        });
      }
    } catch (err) {
      // ignore
    }
  }

  void _onChangePassword() {
    Navigator.pushReplacementNamed(context, ChangePasswordPage.route);
  }

  void _onToggleBiometric(bool isOn) {
    if (isOn) {
      _authBiometric();
    } else {
      webApi.account.setBiometricDisabled();
      this.setState(() {
        this._isBiometricAuthorized = false;
      });
    }
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
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              children: <Widget>[
                ImportItem(text: dic['restoreSeed']!, onClick: _onBackup,),
                ImportItem(text: dic['changePassword']!, onClick: _onChangePassword,),
                _supportBiometric ?
                SwitchItem(text: dic['unlock.bio.enable']!, onClick: _onToggleBiometric, isOn: this._isBiometricAuthorized,)
                    : Container()
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
        behavior: HitTestBehavior.opaque,
        child: Container(
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600)),
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

class SwitchItem extends StatelessWidget {
  SwitchItem({
    required this.text,
    required this.isOn,
    required this.onClick
  });

  final String text;
  final bool isOn;
  final void Function(bool) onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600)),
            FlutterSwitch(
              value: isOn,
              width: 54,
              height: 30,
              onToggle: (value) {
                onClick(value);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        )
    );
  }
}