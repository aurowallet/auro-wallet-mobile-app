import 'dart:async';

import 'package:auro_wallet/common/components/menuItem.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';

class PasswordVerificationPage extends StatefulWidget {
  const PasswordVerificationPage(this.store);

  static final String route = '/setting/passwordverification';
  final AppStore store;

  @override
  _PasswordVerificationState createState() => _PasswordVerificationState(store);
}

enum PwdSwitchType { transaction, appaccess }

class _PasswordVerificationState extends State<PasswordVerificationPage> {
  _PasswordVerificationState(this.store);

  final AppStore store;
  bool _isAppAccessEnable = false;
  bool _isTransactionPwdEnable = true;

  @override
  void initState() {
    super.initState();
    _checkPwdAuth();
  }

  Future<void> _checkPwdAuth() async {
    final isAppAccessEnable = webApi.account.getAppAccessEnabled();
    final isTransactionPwdEnable = webApi.account.getTransactionPwdEnabled();
    setState(() {
      _isAppAccessEnable = isAppAccessEnable;
      _isTransactionPwdEnable = isTransactionPwdEnable;
    });
  }

  void _onToggleAppAccess(bool isOn) async {
    if (!isOn) {
      if (!_isTransactionPwdEnable) {
        UI.toast(dic.pwdVerificationTip);
        return;
      }
      String? password = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: true);
      if (password != null) {
        if (!mounted) return;
        webApi.account.setAppAccessDisabled();
        setState(() {
          _isAppAccessEnable = false;
        });
      }
    } else {
      webApi.account.setAppAccessEnabled();
      setState(() {
        _isAppAccessEnable = true;
      });
    }
  }

  void _onToggleTransactionPwd(bool isOn) async {
    if (isOn) {
      webApi.account.setTransactionPwdEnabled();
      store.wallet!.clearRuntimePwd();
      setState(() {
        _isTransactionPwdEnable = true;
      });
    } else {
      if (!_isAppAccessEnable) {
        UI.toast(dic.pwdVerificationTip);
        return;
      }
      String? password = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: true,
          store: store);
      if (password != null) {
        if (!mounted) return;
        webApi.account.setTransactionPwdDisabled();
        store.wallet!.setRuntimePwd(password);
        setState(() {
          _isTransactionPwdEnable = false;
        });
      }
    }
  }

  late AppLocalizations dic;

  @override
  Widget build(BuildContext context) {
    dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.passwordVerification),
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
                  text: dic.appAccess,
                  switchValue: _isAppAccessEnable,
                  onSwitchChanged: _onToggleAppAccess,
                ),
                MenuItem(
                  text: dic.transactions,
                  switchValue: _isTransactionPwdEnable,
                  onSwitchChanged: _onToggleTransactionPwd,
                ),
              ],
            )),
      ),
    );
  }
}
