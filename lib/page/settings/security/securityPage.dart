import 'dart:async';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auro_wallet/page/settings/security/exportMnemonicResultPage.dart';
import 'package:auro_wallet/page/settings/security/changePasswordPage.dart';
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    await UI.showAlertDialog(
      context: context,
      crossAxisAlignment: CrossAxisAlignment.start,
      contents:[
        dic.backTips_1,
        '',
        dic.backTips_2,
        '',
        dic.backTips_3,
      ],
    );
    WalletData? wallet = store.wallet!.walletList.firstWhereOrNull((wallet) => wallet.walletType == WalletStore.seedTypeMnemonic);
    if (wallet == null) {
      return;
    }
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        inputPasswordRequired: true
    );
    if (password == null) {
      return;
    }
    String? mnemonic = await store.wallet!.getMnemonic(wallet, password);
    if (mnemonic == null) {
      UI.toast(dic.passwordError);
      return;
    }
    if (mounted) {
      await Navigator.pushNamed(context, ExportMnemonicResultPage.route, arguments: {
        "key": mnemonic
      });
    }
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
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        validate: true,
        inputPasswordRequired: true
    );

    bool success = false;
    try {
      if (password != null) {
        await webApi.account.saveBiometricPass(context, password);
        success = true;
        print('save bio success');
      }
    } catch (err) {
      print('save bio failed');
      print(err);
      // ignore
    }
    if (success) {
      webApi.account.setBiometricEnabled();
      setState(() {
        _isBiometricAuthorized = true;
      });
    }
  }

  void _onChangePassword() {
    Navigator.pushNamed(context, ChangePasswordPage.route);
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
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.security),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: <Widget>[
                MenuItem(text: dic.restoreSeed, onClick: _onBackup,),
                MenuItem(text: dic.changePassword, onClick: _onChangePassword,),
                _supportBiometric ?
                SwitchItem(text: dic.unlockBioEnable, onClick: _onToggleBiometric, isOn: this._isBiometricAuthorized,)
                    : Container()
              ],
            )
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  MenuItem({
    required this.text,
    required this.onClick
  });

  final String text;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onClick,
        child: Container(
            height: 54,
            padding: EdgeInsets.symmetric(horizontal: 20),
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
        padding: EdgeInsets.symmetric(horizontal: 20),
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