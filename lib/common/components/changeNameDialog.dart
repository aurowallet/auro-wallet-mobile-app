import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class ChangeNameDialog extends StatefulWidget {
  ChangeNameDialog({this.onOk, this.onCancel});

  final Function? onOk;
  final Function? onCancel;

  @override
  _ChangeNameDialogDialogState createState() => _ChangeNameDialogDialogState();
}

class _ChangeNameDialogDialogState extends State<ChangeNameDialog> {

  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> mainI18n = I18n.of(context).main;
    final Map<String, String> dic = I18n.of(context).home;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                      dic['renameAccountName']!,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: InputItem(
                    maxLength: 16,
                    initialValue: '',
                    placeholder: dic['accountNameLimit']!,
                    padding: EdgeInsets.only(top: 20),
                    controller: _nameCtrl,
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
                          child: Text(mainI18n['cancel']!, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: () {
                            if (widget.onCancel != null) {
                              widget.onCancel!();
                            }
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
                              Text(mainI18n['confirm']!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          ),
                          onPressed: () {
                            if (widget.onOk != null) {
                              widget.onOk!();
                            }
                            Navigator.of(context).pop(_nameCtrl.text.trim());
                          },
                        ),

                      ),)
                    ]
                ),
              ],
            ),
          )
        ]
      ),
    );
  }
}
