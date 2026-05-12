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

class _PasswordVerificationState extends State<PasswordVerificationPage>
    with SingleTickerProviderStateMixin {
  _PasswordVerificationState(this.store);

  final AppStore store;
  bool _isAppAccessEnable = false;
  bool _isTransactionPwdEnable = true;
  bool _isWarning = false;
  AnimationController? _shakeController;
  Animation<double> _shakeAnimation = const AlwaysStoppedAnimation(0.0);
  Timer? _warningResetTimer;

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeController = controller;
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _warningResetTimer?.cancel();
        _warningResetTimer = Timer(Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isWarning = false);
        });
      }
    });
    _checkPwdAuth();
  }

  @override
  void dispose() {
    _warningResetTimer?.cancel();
    _shakeController?.dispose();
    super.dispose();
  }

  void _triggerWarning() {
    _warningResetTimer?.cancel();
    setState(() => _isWarning = true);
    _shakeController?.forward(from: 0);
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
        _triggerWarning();
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
        _triggerWarning();
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
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dic.pwdVerificationTip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isWarning
                              ? Color(0xFFD65A5A)
                              : Color(0xFF808080),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
