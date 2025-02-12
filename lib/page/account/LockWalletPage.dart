import 'package:auro_wallet/common/components/customPromptDialog.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';

class LockWalletPage extends StatefulWidget {
  const LockWalletPage(this.store, {this.unLockCallBack});

  final Function? unLockCallBack;
  static final String route = '/account/lockpage';
  final AppStore store;

  @override
  _LockWalletPageState createState() => _LockWalletPageState();
}

class _LockWalletPageState extends State<LockWalletPage> {
  final TextEditingController _passCtrl = new TextEditingController();
  FocusNode _pass2Focus = new FocusNode();
  bool isUseBiometric = false;
  bool canUseBiometric = false;

  @override
  void initState() {
    super.initState();
    final isBiometricAuthorized = webApi.account.getBiometricEnabled();
    setState(() {
      isUseBiometric = isBiometricAuthorized;
      canUseBiometric = isBiometricAuthorized;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isBiometricAuthorized) {
        _checkBiometricAuthenticate();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _passCtrl.dispose();
    _pass2Focus.dispose();
  }

  Future<void> _onSubmit() async {
    _unFocus();
    String passStr = _passCtrl.text.trim();
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (_passCtrl.text.trim().isEmpty) {
      UI.toast(dic.inputPassword);
      return;
    }
    bool isCorrect = await webApi.account
        .checkAccountPassword(widget.store.wallet!.currentWallet, passStr);
    if (!isCorrect) {
      UI.toast(dic.passwordError);
      return;
    }
    final isTransactionEnable = webApi.account.getTransactionPwdEnabled();
    if (!isTransactionEnable) {
      widget.store.wallet!.setRuntimePwd(passStr);
    }

    onCheckSuccess();
  }

  void _unFocus() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void onChangeVerifyMethod() {
    setState(() {
      isUseBiometric = !isUseBiometric;
    });
  }

  void onCheckSuccess() {
    widget.store.settings!.setLockWalletStatus(false);

    Navigator.of(context).pushReplacementNamed('/');
    if (widget.unLockCallBack != null) {
      widget.unLockCallBack!(context, true);
    }
  }

  Future<void> _onOk(String password) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (password.isEmpty) {
      UI.toast(dic.inputPassword);
      return;
    }

    bool isCorrect = await webApi.account
        .checkAccountPassword(widget.store.wallet!.currentWallet, password);
    if (!isCorrect) {
      UI.toast(dic.passwordError);
      return;
    }
    final isTransactionEnable = webApi.account.getTransactionPwdEnabled();
    if (!isTransactionEnable) {
      widget.store.wallet!.setRuntimePwd(password);
    }
    onCheckSuccess();
  }

  Future<void> _checkBiometricAuthenticate() async {
    final result =
        await webApi.account.getBiometricPassStoreFile(context);
    if (result != null) {
      await _onOk(result);
    } else {
      print('biometric read null');
    }
  }

  void _onResetApp() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool? confirmed = await UI.showConfirmDialog(
        context: context,
        icon: SvgPicture.asset(
          'assets/images/public/error.svg',
          width: 58,
          height: 58,
        ),
        title: dic.resetWarnContentTitle,
        contents: [dic.resetWarnContent],
        okColor: Color(0xFFD65A5A),
        okText: dic.confirmReset,
        cancelText: dic.cancelReset);
    if (confirmed != true) {
      return;
    }
    String deleteTag = dic.delete.toLowerCase();
    String? confirmInput = await showDialog<String>(
      context: context,
      builder: (_) {
        return CustomPromptDialog(
          title: dic.deleteConfirm(deleteTag),
          placeholder: deleteTag,
          onOk: (String? text) {
            if (text == null || text.isEmpty) {
              return false;
            }
            return true;
          },
          validate: (text) {
            return text.toLowerCase() == deleteTag;
          },
        );
      },
    );
    if (confirmInput != null &&
        confirmInput.toLowerCase() == dic.delete.toLowerCase()) {
      widget.store.wallet!.clearWallets();
      widget.store.assets!.clearAccountCache();
      webApi.account.setBiometricDisabled();

      // reset pwd verification
      webApi.account.setAppAccessDisabled();
      webApi.account.setTransactionPwdEnabled();
      widget.store.wallet!.clearRuntimePwd();

      Phoenix.rebirth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
            onTap: _unFocus,
            child: SafeArea(
                maintainBottomViewPadding: true,
                child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Column(children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: _onResetApp,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.black.withValues(alpha: 0.1)),
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: Text(
                                        dic.resetWallet,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Padding(
                                      padding: EdgeInsets.only(bottom: 60),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.asset(
                                          "assets/images/public/app.png",
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                            isUseBiometric
                                ? InkWell(
                                    onTap: _checkBiometricAuthenticate,
                                    child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            child: SvgPicture.asset(
                                              "assets/images/public/icon_biometric.svg",
                                              fit: BoxFit.contain,
                                            )),
                                        Text(dic.clickToVerification,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF808080)))
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      InputItem(
                                        label: dic.password,
                                        initialValue: '',
                                        controller: _passCtrl,
                                        isPassword: true,
                                        placeholder: '',
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                        child: NormalButton(
                                          text: dic.unlock,
                                          onPressed: _onSubmit,
                                        ),
                                      ),
                                    ],
                                  ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                      canUseBiometric
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 38, vertical: 30),
                              child: InkWell(
                                onTap: onChangeVerifyMethod,
                                child: Text(
                                  isUseBiometric
                                      ? dic.loginWithPassword
                                      : dic.useBiometricAuthentication,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ))
                          : Container(),
                    ])))));
  }
}
