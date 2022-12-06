import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/InputErrorTip.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/UI.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage(this.store);

  static final String route = '/profile/password';
  final WalletStore store;

  @override
  _ChangePassword createState() => _ChangePassword(store);
}

class _ChangePassword extends State<ChangePasswordPage> {
  _ChangePassword(this.store);

  final Api api = webApi;
  final WalletStore store;

  final TextEditingController _oldPassCtrl = new TextEditingController();
  final TextEditingController _newPassCtrl = new TextEditingController();
  final TextEditingController _newPass2Ctrl = new TextEditingController();
  bool _submitting = false;
  bool _submitDisabled = false;
  bool lengthError = false;
  bool upCaseError = false;
  bool lowerCaseError = false;
  bool numberError = false;
  bool unRepeatError = false;


  Future<void> _doChangePass() async {
    var dic = I18n.of(context).main;
    setState(() {
      _submitting = true;
    });
    _unFocus();
    String passOld =  _oldPassCtrl.text.trim();
    if (passOld.isEmpty) {
      UI.toast(dic['inputOldPwd']!);
      setState(() {
        _submitting = false;
      });
      return;
    }
    bool isPasswordCorrect = await webApi.account.checkAccountPassword(store.currentWallet, passOld);
    if (!isPasswordCorrect) {
      UI.toast(dic['passwordError']!);
      setState(() {
        _submitting = false;
      });
      return;
    }
    final String passNew = _newPassCtrl.text.trim();
    final String pass2New = _newPass2Ctrl.text.trim();
    if (!_validateLength(passNew)
        || !_validateUpCase(passNew)
        || !_validateLowerCase(passNew)
        || !_validateNumber(passNew)
        || !_validateSame(pass2New)
    ) {
      setState(() {
        _submitting = false;
      });
      return;
    }
    final response = await BiometricStorage().canAuthenticate();
    bool biometricFail = false;
    final supportBiometric = response == CanAuthenticateResponse.success;
    if (supportBiometric) {
      final isBiometricAuthorized = webApi.account.getBiometricEnabled();
      if (isBiometricAuthorized) {
        try {
          await webApi.account.saveBiometricPass(context, passNew);
        } catch(e) {
          biometricFail = true;
          print('biometric fail');
        }
      }
    }
    if (!biometricFail) {
      await store.updateAllWalletSeed(passOld, passNew);
      UI.toast(dic['pwdChangeSuccess']!);
      Navigator.of(context).pop();
    }
    setState(() {
      _submitting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newPassCtrl.addListener(_monitorSummitStatus);
      _newPass2Ctrl.addListener(_monitorSummitStatus);
      _oldPassCtrl.addListener(_monitorSummitStatus);
    });
  }
  bool _validateLength(String text) {
    bool res = true;
    if (text.length  < 8) {
      res =  false;
    } else {
      res = true;
    }
    setState(() {
      lengthError = !res;
    });
    return res;
  }

  bool _validateUpCase(String text) {
    RegExp up = new RegExp(r"[A-Z]");
    bool res = up.hasMatch(text);
    setState(() {
      upCaseError = !res;
    });
    return res;
  }

  bool _validateLowerCase(String text) {
    RegExp lower = new RegExp(r"[a-z]");
    bool res = lower.hasMatch(text);
    setState(() {
      lowerCaseError = !res;
    });
    return res;
  }

  bool _validateNumber(String text) {
    RegExp num = new RegExp(r"\d");
    bool res = num.hasMatch(text);
    setState(() {
      numberError = !res;
    });
    return res;
  }

  bool _validateSame(String text) {
    bool res = _newPassCtrl.text.trim() == text.trim();
    setState(() {
      unRepeatError = !res;
    });
    return res;
  }

  bool _isFormError() {
    return lengthError || upCaseError || lowerCaseError || numberError || unRepeatError;
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _monitorSummitStatus() {
    if (_newPassCtrl.text.isEmpty || _newPass2Ctrl.text.isEmpty || _oldPassCtrl.text.isEmpty) {
      if (!_submitDisabled) {
        setState((){
          _submitDisabled = true;
        });
      }
    } else if(_submitDisabled) {
      setState((){
        _submitDisabled = false;
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    _newPassCtrl.dispose();
    _newPass2Ctrl.dispose();
    _oldPassCtrl.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).main;
    final List<String> errors = [];
    if (lengthError) {
      errors.add(dic['passwordRequires']!);
    }
    if (upCaseError) {
      errors.add(dic['atLeastOneUppercaseLetter']!);
    }
    if (lowerCaseError) {
      errors.add(dic['atLeastOneLowercaseLetter']!);
    }
    if (numberError) {
      errors.add(dic['atLeastOneNumber']!);
    }
    return GestureDetector(
      onTap: _unFocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text(dic['changeSecPassword']!),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  children: <Widget>[
                    InputItem(
                      padding: EdgeInsets.zero,
                      label: dic['inputOldPwd']!,
                      controller: _oldPassCtrl,
                      isPassword: true,
                    ),
                    InputItem(
                      label: dic['inputNewPwd']!,
                      controller: _newPassCtrl,
                      isPassword: true,
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        errors.join("/"),
                        style: TextStyle(
                            color: Color(0xFFD65A5A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 8),
                      ctrl: _newPassCtrl,
                      showMessage: false,
                      message: dic['passwordRequires']!,
                      validate: _validateLength,
                    ),
                    InputErrorTip(
                      ctrl: _newPassCtrl,
                      showMessage: false,
                      message: dic['atLeastOneUppercaseLetter']!,
                      validate: _validateUpCase,
                    ),
                    InputErrorTip(
                      ctrl: _newPassCtrl,
                      showMessage: false,
                      message: dic['atLeastOneLowercaseLetter']!,
                      validate: _validateLowerCase,
                    ),
                    InputErrorTip(
                      ctrl: _newPassCtrl,
                      showMessage: false,
                      message: dic['atLeastOneNumber']!,
                      validate: _validateNumber,
                    ),
                    InputItem(
                      label: dic['inputNewPwdRepeat']!,
                      controller: _newPass2Ctrl,
                      isPassword: true,
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 4),
                      ctrl: _newPass2Ctrl,
                      message: dic['passwordDifferent']!,
                      hideIcon: true,
                      validate: _validateSame,
                      keepShow: false,
                      // focusNode: _pass2Focus,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                child: NormalButton(
                  text: dic['confirm']!,
                  disabled: _submitDisabled || _isFormError(),
                  submitting: _submitting,
                  onPressed: _submitting ? null : _doChangePass,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
