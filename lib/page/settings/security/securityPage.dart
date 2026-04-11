import 'dart:async';

import 'package:auro_wallet/common/components/menuItem.dart';
import 'package:auro_wallet/common/components/switchItem.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/security/PasswordVerificationPage.dart';
import 'package:auro_wallet/page/settings/security/changePasswordPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';

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


  Future<void> _checkBiometricAuth() async {
    final supportBiometric =
        await webApi.account.canAuthenticateWithBiometrics();
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
        inputPasswordRequired: true);
    bool status = false;
    try {
      if (password != null) {
        status = await webApi.account.saveBiometricPass(context, password);
      }
    } catch (err) {
    }
    if (status) {
      webApi.account.setBiometricEnabled();
      setState(() {
        _isBiometricAuthorized = true;
      });
    }
  }

  void _onChangePassword() {
    Navigator.pushNamed(context, ChangePasswordPage.route);
  }

  void _onSetPwdVerification() {
    Navigator.pushNamed(context, PasswordVerificationPage.route);
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
                MenuItem(
                  text: dic.changePassword,
                  onTap: _onChangePassword,
                ),
                MenuItem(
                  text: dic.passwordVerification,
                  onTap: _onSetPwdVerification,
                ),
                _supportBiometric
                    ? SwitchItem(
                        text: dic.unlockBioEnable,
                        onClick: _onToggleBiometric,
                        isOn: this._isBiometricAuthorized,
                      )
                    : Container(),
              ],
            )),
      ),
    );
  }
}
