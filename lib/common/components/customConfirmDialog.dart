import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';

class CustomConfirmDialog extends StatefulWidget {
  CustomConfirmDialog({required this.title,required this.contents, this.onOk, this.onCancel, this.cancelText, this.okText, this.icon});

  final String title;
  final String? okText;
  final String? cancelText;
  final List<String> contents;
  final Function? onOk;
  final Function? onCancel;
  final Widget? icon;

  @override
  _CustomConfirmDialogDialogState createState() => _CustomConfirmDialogDialogState();
}

class _CustomConfirmDialogDialogState extends State<CustomConfirmDialog> {

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
                widget.icon != null ? Padding(padding: EdgeInsets.only(bottom: 10),child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.icon!
                  ],
                ),): Container(),
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(widget.title, style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Column(
                    children: widget.contents.map((content) => Text(content)).toList(),
                  ),
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
                        child: OutlinedButton(
                          // borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          // highlightedBorderColor: Theme.of(context).primaryColor,
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Text(widget.cancelText ?? dic['cancel']!, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                          onPressed: () {
                            if (widget.onCancel != null) {
                              widget.onCancel!();
                            }
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                      TextButton(
                        // height: 40,
                        // minWidth: 130,
                        // color: Theme.of(context).primaryColor,
                        // shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.okText ?? dic['confirm']!, style: TextStyle(color: Colors.white, fontSize: 16))
                          ],
                        ),
                        onPressed: () {
                          if (widget.onOk != null) {
                            widget.onOk!();
                          }
                          Navigator.of(context).pop(true);
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
