import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class AddressBookDialog extends StatefulWidget {
  AddressBookDialog({this.onOk, this.onCancel});

  final bool Function(String name, String address)? onOk;
  final Function? onCancel;

  @override
  _AddressBookDialogState createState() => _AddressBookDialogState();
}

class _AddressBookDialogState extends State<AddressBookDialog> {

  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _addressCtrl = new TextEditingController();

  bool _submitDisabled = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_monitorSummitStatus);
    _addressCtrl.addListener(_monitorSummitStatus);
  }

  @override
  void dispose() {
    super.dispose();
  }
  void _monitorSummitStatus() {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
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
                  child: Text(dic['addaddress']!, style: TextStyle(fontSize: 20)),
                ),
                InputItem(
                  initialValue: '',
                  placeholder: dic['name'],
                  padding: EdgeInsets.only(top: 25),
                  controller: _nameCtrl,
                ),
                InputItem(
                  initialValue: '',
                  placeholder: dic['address'],
                  padding: EdgeInsets.only(top: 16),
                  controller: _addressCtrl,
                  maxLines: 2,
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
                        disabledColor: Colors.black12,
                        disabledTextColor: Colors.blueGrey,
                        onPressed: _submitDisabled ? null : () {
                          if (widget.onOk != null) {
                            bool close = widget.onOk!(_nameCtrl.text, _addressCtrl.text);
                            if (!close) {
                              return;
                            }
                          }
                          Navigator.of(context).pop([_nameCtrl.text, _addressCtrl.text]);
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
