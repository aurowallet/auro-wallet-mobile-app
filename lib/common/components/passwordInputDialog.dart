import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoTheme;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({
    required this.wallet,
    this.inputPasswordRequired = false,
  });

  final WalletData wallet;
  final bool inputPasswordRequired;

  @override
  _PasswordInputDialog createState() => _PasswordInputDialog();
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();

  bool _submitting = false;

  bool _isBiometricAuthorized = false; // if user authorized biometric usage
  bool _isCheckingBiometric = true;
  bool _isConfirmButtonEnabled = false;
  bool _supportBiometric = false;
  bool isUseBiometric = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.inputPasswordRequired) {
        _checkBiometricStatus();
      }
    });
  }

  Future<void> _onOk(String password) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    if (password.isEmpty) {
      UI.toast(dic.inputPassword);
      return;
    }
    setState(() {
      _submitting = true;
    });
    bool isCorrect =
        await webApi.account.checkAccountPassword(widget.wallet, password);
    setState(() {
      _submitting = false;
    });
    if (!isCorrect) {
      UI.toast(dic.passwordError);
      return;
    }
    // bool isCorrect = await webApi.account.checkAccountPassword(widget.wallet, password);
    // Tuple2 result = await widget.onOk(password);
    // if (mounted) {
    //   setState(() {
    //     _submitting = false;
    //   });
    // }
    // if (!result.item1) {
    //   UI.toast(dic['passwordError']!);
    //   return;
    // } else {
    //   Navigator.of(context).pop(result);
    // }
    Navigator.of(context).pop(password);
  }

  Future<void> _checkBiometricStatus() async {
    final supportBiometric =
        await webApi.account.canAuthenticateWithBiometrics();
    final isBiometricAuthorized = webApi.account.getBiometricEnabled();
    setState(() {
      _isBiometricAuthorized = isBiometricAuthorized;
      _isCheckingBiometric = false;
      _supportBiometric = supportBiometric;
    });
  }

  Future<void> _checkBiometricAuthenticate() async {
    if (_supportBiometric) {
      final result = await webApi.account.getBiometricPassStoreFile(context);
      if (result != null) {
        await _onOk(result);
      } else {
        print('biometric read null');
      }
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool showBioWidget = false;
    if ((_isBiometricAuthorized || _isCheckingBiometric) &&
        !widget.inputPasswordRequired) {
      showBioWidget = true;
    }
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text(
                        showBioWidget ? dic.biometricAuth : dic.password,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                  ),
                ),
                showBioWidget
                    ? Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                            child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isUseBiometric = !isUseBiometric;
                              });
                            },
                            child: isUseBiometric
                                ? Text(
                                    dic.password,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(2),
                                    child: SvgPicture.asset(
                                      "assets/images/public/icon_biometric.svg",
                                      fit: BoxFit.contain,
                                      width: 24,
                                    )),
                          ),
                        )))
                    : Container(),
              ],
            ),
            showBioWidget && isUseBiometric
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: InputItem(
                      autoFocus: true,
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      controller: _passCtrl,
                      isPassword: true,
                      onChanged: (value) {
                        setState(() {
                          _isConfirmButtonEnabled = value.isNotEmpty;
                        });
                      },
                      // clearButtonMode: OverlayVisibilityMode.editing,
                    ),
                  ),
            showBioWidget && isUseBiometric
                ? SizedBox(
                    height: 20,
                  )
                : Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 1,
                    color: Colors.black.withOpacity(0.05),
                  ),
            showBioWidget && isUseBiometric
                ? Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: _checkBiometricAuthenticate,
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: SvgPicture.asset(
                                    "assets/images/public/icon_biometric.svg",
                                    fit: BoxFit.contain,
                                    width: 58,
                                  )),
                              Text(dic.tapToVerify,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF808080)))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 1,
                        color: Colors.black.withOpacity(0.05),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            textStyle: TextStyle(color: Colors.black)),
                        child: Text(dic.cancel,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                            child: SizedBox(
                          height: 48,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                textStyle: TextStyle(color: Colors.black)),
                            child: Text(dic.cancel,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        )),
                        Container(
                          width: 0.5,
                          height: 48,
                          color: Colors.black.withOpacity(0.1),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _submitting
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: CupertinoTheme(
                                            data: CupertinoTheme.of(context)
                                                .copyWith(
                                                    brightness:
                                                        Brightness.dark),
                                            child: CupertinoActivityIndicator(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ))
                                      : Text(dic.confirm,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                ],
                              ),
                              onPressed: !_isConfirmButtonEnabled
                                  ? null
                                  : _submitting
                                      ? () {}
                                      : () => _onOk(_passCtrl.text.trim()),
                            ),
                          ),
                        )
                      ]),
          ],
        ),
      ),
    );
  }
}
