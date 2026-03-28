import 'dart:async';

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
        store.wallet?.clearRuntimePwd();
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
      store.wallet?.clearRuntimePwd();
      setState(() {
        _isTransactionPwdEnable = true;
      });
    } else {
      // Only allow disabling when App Access is ON
      if (!_isAppAccessEnable) {
        UI.toast(dic.pwdVerificationTip);
        return;
      }
      // Require password verification before disabling transaction password
      // (aligns with MetaMask/Coinbase/Trust Wallet security practices)
      String? password = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: true);
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
                SwitchItem(
                  text: dic.appAccess,
                  onClick: _onToggleAppAccess,
                  isOn: this._isAppAccessEnable,
                ),
                SwitchItem(
                  text: dic.transactions,
                  onClick: _onToggleTransactionPwd,
                  isOn: this._isTransactionPwdEnable,
                ),
              ],
            )),
      ),
    );
  }
}

class SwitchItem extends StatelessWidget {
  SwitchItem({required this.text, required this.isOn, required this.onClick});

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
            Text(text,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            Theme(
              data: ThemeData(
                useMaterial3: true,
              ).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(outline: Color(0xFFE9E9E9)),
              ),
              child: Switch(
                value: isOn,
                onChanged: onClick,
                activeThumbColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Color(0xFF594AF1),
                inactiveTrackColor: Color(0xFFE9E9E9),
              ),
            )
          ],
        ));
  }
}
