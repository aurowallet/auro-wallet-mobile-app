import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator, CupertinoTheme;
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({
    required this.wallet,
    this.validate = false
  });

  final WalletData wallet;
  final bool validate;

  @override
  _PasswordInputDialog createState() => _PasswordInputDialog();
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();

  bool _submitting = false;

  bool _isBiometricAuthorized = false; // if user authorized biometric usage
  bool _isCheckingBiometric = true;

  Future<void> _onOk(String password) async {
    if (password.isEmpty) {
      final Map<String, String> dic = I18n.of(context).main;
      UI.toast(dic['inputPassword']!);
      return;
    }
    if (widget.validate) {
      setState(() {
        _submitting = true;
      });
      bool isCorrect = await webApi.account.checkAccountPassword(widget.wallet, password);
      setState(() {
        _submitting = false;
      });
      if (!isCorrect) {
          final Map<String, String> dic = I18n.of(context).main;
          UI.toast(dic['passwordError']!);
          return;
      }
    }
    // bool isCorrect = await webApi.account.checkAccountPassword(widget.wallet, password);
    // Tuple2 result = await widget.onOk(password);
    // if (mounted) {
    //   setState(() {
    //     _submitting = false;
    //   });
    // }
    // if (!result.item1) {
    //   final Map<String, String> dic = I18n.of(context).main;
    //   UI.toast(dic['passwordError']!);
    //   return;
    // } else {
    //   Navigator.of(context).pop(result);
    // }
    Navigator.of(context).pop(password);
  }

  Future<CanAuthenticateResponse> _checkBiometricAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();

    final supportBiometric = response == CanAuthenticateResponse.success;
    final isBiometricAuthorized = webApi.account.getBiometricEnabled();
    setState(() {
      _isBiometricAuthorized = isBiometricAuthorized;
      _isCheckingBiometric = false;
    });
    if (supportBiometric) {
      // we prompt biometric auth here if device supported
      // and user authorized to use biometric.
      if (isBiometricAuthorized) {
        try {
          final authStorage = await webApi.account.getBiometricPassStoreFile(context);
          final result = await authStorage.read();
          if (result != null) {
            await _onOk(result);
          }
        } catch (err) {
          print(err);
          // Navigator.of(context).pop();
        }
      }
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAuthenticate();
    });
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    if (_isBiometricAuthorized || _isCheckingBiometric) {
      return Container();
    }
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Text(dic['securityPassword']!, style: TextStyle(fontSize: 18)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 30, right: 30),
              child: InputItem(
                autoFocus: true,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                controller: _passCtrl,
                isPassword: true,
                // clearButtonMode: OverlayVisibilityMode.editing,
              ),
            ),
      Container(
        margin: EdgeInsets.only(top: 30),
        height: 1,
        color: Colors.black.withOpacity(0.05),
      ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          textStyle: TextStyle(
                              color: Colors.black
                          )
                      ),
                      child: Text(dic['cancel']!, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  Expanded(child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _submitting ? Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: CupertinoTheme( data: CupertinoTheme.of(context).copyWith(brightness: Brightness.dark), child: CupertinoActivityIndicator(),)
                          ): Container(),
                          Text(dic['confirm']!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      onPressed: _submitting ? (){} : () => _onOk(_passCtrl.text.trim()),
                    ),

                  ),)
                ]
            ),
          ],
        ),
      ),
    );
  }
}
