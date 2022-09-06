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
            padding: EdgeInsets.all(20).copyWith(bottom: 0),
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
                  child: Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: widget.contents.map((content) => Text(content, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400
                    ),)).toList(),
                  ),
                ),
              ],
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
                      child: Text(widget.cancelText ?? dic['cancel']!, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        if (widget.onCancel != null) {
                          widget.onCancel!();
                        }
                        Navigator.of(context).pop(false);
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
                          foregroundColor: Color(0xFFD65A5A)
                      ),
                      child: Text(widget.okText ?? dic['confirm']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        if (widget.onOk != null) {
                          widget.onOk!();
                        }
                        Navigator.of(context).pop(true);
                      },
                    ),
                  )),
                ]
            ),
        ]
      ),
    );
  }
}
