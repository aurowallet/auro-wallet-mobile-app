import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/page/account/create/backupMnemonicTipsPage.dart';
import 'package:auro_wallet/page/account/import/importMnemonicPage.dart';

class SetNewWalletPasswordPage extends StatefulWidget {
  const SetNewWalletPasswordPage(this.store);

  static final String route = '/account/create';
  final AppStore store;

  @override
  _SetNewWalletPasswordPageState createState() => _SetNewWalletPasswordPageState();
}

class _SetNewWalletPasswordPageState extends State<SetNewWalletPasswordPage> {

  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();
  FocusNode _pass2Focus = new FocusNode();
  bool _supportBiometric = false;
  bool _enableBiometric = true; // if the biometric usage checkbox checked
  bool lengthError = false;
  bool upCaseError = false;
  bool lowerCaseError = false;
  bool numberError = false;
  bool unRepeatError = false;
  bool _submitDisabled = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passCtrl.addListener(_monitorSummitStatus);
      _pass2Ctrl.addListener(_monitorSummitStatus);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pass2Ctrl.dispose();
    _passCtrl.dispose();
    _pass2Focus.dispose();
  }





  void _monitorSummitStatus() {
    if (_passCtrl.text.isEmpty || _pass2Ctrl.text.isEmpty) {
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

  Future<void> _onSubmit() async {
    _unFocus();
    String passStr = _passCtrl.text.trim();
    String pass2Str = _pass2Ctrl.text.trim();
    final Map<String, String> dic = I18n.of(context).main;
    if(_passCtrl.text.trim().isEmpty || _pass2Ctrl.text.trim().isEmpty) {
      UI.toast(dic['inputPassword']!);
      return;
    }
    if (!_validateLength(passStr)
        || !_validateUpCase(passStr)
        || !_validateLowerCase(passStr)
        || !_validateNumber(passStr)
        || !_validateSame(pass2Str)
    ) {
      return;
    }
    widget.store.wallet!.setNewAccount(_passCtrl.text);
    Map params = ModalRoute.of(context)!.settings.arguments as Map;
    if (params['type'] == 'create') {
      Navigator.pushNamed(context, BackupMnemonicTipsPage.route);
    } else {
      Navigator.pushNamed(context, ImportMnemonicPage.route);
    }
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
    bool res = _passCtrl.text.trim() == text.trim();
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

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['createPassword']!),
        // backgroundColor: Colors.transparent,
        // iconTheme: IconThemeData(
        //   color: Colors.white, //change your color here
        // ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: GestureDetector(
          onTap: _unFocus,
          child: SafeArea(
            maintainBottomViewPadding: true,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 22),
                    child:  Text(dic['createPasswordTip']!, style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),),
                    decoration: BoxDecoration(
                      color: Color(0x1A594AF1),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                        InputItem(
                          label: dic['password']!,
                          initialValue: '',
                          controller: _passCtrl,
                          isPassword: true,
                          placeholder: '',
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
                          ctrl: _passCtrl,
                          keepShow: false,
                          showSuccess: false,
                          hideIcon: true,
                          showMessage: false,
                          message: dic['passwordRequires']!,
                          validate: _validateLength,
                        ),
                        InputErrorTip(
                          ctrl: _passCtrl,
                          keepShow: false,
                          showSuccess: false,
                          showMessage: false,
                          hideIcon: true,
                          message: dic['atLeastOneUppercaseLetter']!,
                          validate: _validateUpCase,
                        ),
                        InputErrorTip(
                          ctrl: _passCtrl,
                          keepShow: false,
                          showSuccess: false,
                          showMessage: false,
                          hideIcon: true,
                          message: dic['atLeastOneLowercaseLetter']!,
                          validate: _validateLowerCase,
                        ),
                        InputErrorTip(
                          ctrl: _passCtrl,
                          keepShow: false,
                          showSuccess: false,
                          showMessage: false,
                          hideIcon: true,
                          message: dic['atLeastOneNumber']!,
                          validate: _validateNumber,
                        ),
                        InputItem(
                          label: dic['confirmPasswordShort']!,
                          initialValue: '',
                          controller: _pass2Ctrl,
                          isPassword: true,
                          focusNode: _pass2Focus,
                          placeholder: '',
                        ),
                        InputErrorTip(
                          padding: EdgeInsets.only(top: 4),
                          ctrl: _pass2Ctrl,
                          message: dic['passwordDifferent']!,
                          validate: _validateSame,
                          keepShow: false,
                          hideIcon: true,
                          focusNode: _pass2Focus,
                        ),
                        _supportBiometric
                            ? Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _enableBiometric,
                                  onChanged: (v) {
                                    setState(() {
                                      _enableBiometric = v != null && v == true;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                    I18n.of(context).main['unlock.bio.enable']!),
                              )
                            ],
                          ),
                        )
                            : Container(),
                      ]
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 38, vertical: 30),
                  child: NormalButton(
                    disabled: _isFormError() || _submitDisabled,
                    text: I18n.of(context).main['next']!,
                    onPressed: _onSubmit,
                  ),
                ),
              ],
            ),
          )
      )
    );
  }
}
