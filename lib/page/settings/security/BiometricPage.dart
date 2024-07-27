import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';

class BiometricPage extends StatefulWidget {
  const BiometricPage(this.store);

  static final String route = '/setting/biometric';
  final AppStore store;

  @override
  _BiometricPageState createState() => _BiometricPageState(store);
}

enum BiometricSwitchType { transaction, appaccess }

class _BiometricPageState extends State<BiometricPage> {
  _BiometricPageState(this.store);

  final AppStore store;
  bool _isBiometricAuthorized = false;
  bool _isBiometricAppAccessOpen = false;

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
    final isBiometricAuthorized = webApi.account.getBiometricEnabled();
    final isBiometricAppAccessOpen =
        webApi.account.getBiometricAppAccessEnabled();

    setState(() {
      _isBiometricAuthorized = isBiometricAuthorized;
      _isBiometricAppAccessOpen = isBiometricAppAccessOpen;
    });
  }

  Future<void> _authBiometric(BiometricSwitchType type) async {
    String? password = await UI.showPasswordDialog(
        context: context,
        wallet: store.wallet!.currentWallet,
        inputPasswordRequired: true);

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
      if (err is AuthException) {
        UI.toast(err.message);
      } else {
        UI.toast('Unknown error: ${err.toString()}');
      }
    }
    if (success) {
      if (type == BiometricSwitchType.transaction) {
        webApi.account.setBiometricEnabled();
        setState(() {
          _isBiometricAuthorized = true;
        });
      } else {
        webApi.account.setBiometricAppAccessEnabled();
        setState(() {
          _isBiometricAppAccessOpen = true;
        });
      }
    }
  }

  void _onToggleBiometric(bool isOn) {
    if (isOn) {
      _authBiometric(BiometricSwitchType.transaction);
    } else {
      webApi.account.setBiometricDisabled();
      this.setState(() {
        this._isBiometricAuthorized = false;
      });
    }
  }

  void _onToggleAppAccessBiometric(bool isOn) {
    if (isOn) {
      _authBiometric(BiometricSwitchType.appaccess);
    } else {
      webApi.account.setBiometricAppAccessDisabled();
      this.setState(() {
        this._isBiometricAppAccessOpen = false;
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
                SwitchItem(
                  text: dic.appAccess,
                  onClick: _onToggleAppAccessBiometric,
                  isOn: this._isBiometricAppAccessOpen,
                ),
                SwitchItem(
                  text: dic.transactions,
                  onClick: _onToggleBiometric,
                  isOn: this._isBiometricAuthorized,
                )
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
            Switch(
              value: isOn,
              onChanged: onClick,
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white,
              activeTrackColor: Color(0xFF594AF1),
              inactiveTrackColor: Color(0xFFE9E9E9),
            ),
          ],
        ));
  }
}
