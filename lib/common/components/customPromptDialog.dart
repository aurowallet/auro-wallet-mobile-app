import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class CustomPromptDialog extends StatefulWidget {
  CustomPromptDialog({this.onOk, this.onCancel, this.placeholder, required this.title, this.validate});

  final bool Function(String text)? onOk;
  final Function? onCancel;
  final String? placeholder;
  final String title;
  final bool Function (String text)? validate;

  @override
  _CustomPromptDialogState createState() => _CustomPromptDialogState();
}

class _CustomPromptDialogState extends State<CustomPromptDialog> {

  final TextEditingController _textCtrl = new TextEditingController();
  bool _isCorrect = true;

  @override
  void initState() {
    super.initState();
    if (widget.validate != null) {
      _textCtrl.addListener(_doValidate);
    }
    _doValidate();
  }

  @override
  void dispose() {
    super.dispose();
    _textCtrl.dispose();
  }

  void _doValidate() {
    if (widget.validate != null) {
      var isCor = widget.validate!(_textCtrl.text);
      setState(() {
        _isCorrect = isCor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20).copyWith(bottom: 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(widget.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                ),
                InputItem(
                  initialValue: '',
                  placeholder: widget.placeholder,
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  controller: _textCtrl,
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
                              Text(dic['confirm']!, style: TextStyle(color: _isCorrect ? Theme.of(context).primaryColor: Colors.black.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          ),
                          onPressed: _isCorrect ? () {
                            if (widget.onOk != null) {
                              bool close = widget.onOk!(_textCtrl.text);
                              if (!close) {
                                return;
                              }
                            }
                            Navigator.of(context).pop(_textCtrl.text.trim());
                          } : null,
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
