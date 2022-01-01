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
    final Map<String, String> dic = I18n.of(context).main;

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
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(dic['renameAccountName']!, style: TextStyle(fontSize: 20)),
                ),
                InputItem(
                  maxLength: 16,
                  initialValue: '',
                  padding: EdgeInsets.only(top: 33),
                  controller: _nameCtrl,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 27),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 130,
                            minHeight: 40
                        ),
                        child: OutlineButton(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          highlightedBorderColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Text(dic['cancel']!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                          onPressed: () {
                            if (widget.onCancel != null) {
                              widget.onCancel!();
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      FlatButton(
                        height: 40,
                        minWidth: 130,
                        color: Theme.of(context).primaryColor,
                        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dic['confirm']!, style: TextStyle(color: Colors.white, fontSize: 16))
                          ],
                        ),
                        onPressed: () {
                          if (widget.onOk != null) {
                            widget.onOk!();
                          }
                          Navigator.of(context).pop(_nameCtrl.text.trim());
                        },
                      ),
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
