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

class _PasswordVerificationState extends State<PasswordVerificationPage>
    with SingleTickerProviderStateMixin {
  _PasswordVerificationState(this.store);

  final AppStore store;
  bool _isAppAccessEnable = false;
  bool _isTransactionEnable = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _checkPwdAuth();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
        }
      });

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);

    _colorAnimation = ColorTween(
      begin: Color(0xFF808080),
      end: Color(0xFFD65A5A),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPwdAuth() async {
    final isAppAccessEnable = webApi.account.getAppAccessEnabled();
    final isTransactionEnable = webApi.account.getTransactionPwdEnabled();

    setState(() {
      _isAppAccessEnable = isAppAccessEnable;
      _isTransactionEnable = isTransactionEnable;
    });
  }

  void _onToggleAppAccess(bool isOn) async {
    if (!isOn && !_isTransactionEnable) {
      if (!_controller.isAnimating) {
        _controller.forward();
      }
    } else {
      if (isOn) {
        webApi.account.setAppAccessEnabled();
      } else {
        webApi.account.setAppAccessDisabled();
      }
      setState(() {
        _isAppAccessEnable = isOn;
      });
    }
  }

  void _onToggleTransaction(bool isOn) async {
    if (!isOn && !_isAppAccessEnable) {
      if (!_controller.isAnimating) {
        _controller.forward();
      }
    } else {
      if (!isOn) {
        String? password = await UI.showPasswordDialog(
            context: context,
            wallet: store.wallet!.currentWallet,
            inputPasswordRequired: true);
        if (password != null) {
          store.wallet!.setRuntimePwd(password);
          setState(() {
            _isTransactionEnable = isOn;
          });
          webApi.account.setTransactionPwdDisabled();
        }
      } else {
        store.wallet!.clearRuntimePwd();
        webApi.account.setTransactionPwdEnabled();
        setState(() {
          _isTransactionEnable = isOn;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
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
                  onClick: _onToggleTransaction,
                  isOn: this._isTransactionEnable,
                ),
                Container(
                    height: 54,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _offsetAnimation,
                              child: Text(
                                dic.pwdVerificationTip,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _colorAnimation.value,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ))
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
