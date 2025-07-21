import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomConfirmDialog extends StatefulWidget {
  CustomConfirmDialog(
      {required this.title,
      required this.contents,
      this.okColor,
      this.onOk,
      this.onCancel,
      this.cancelText,
      this.okText,
      this.icon});

  final String title;
  final String? okText;
  final String? cancelText;
  final List<String> contents;
  final Function? onOk;
  final Color? okColor;
  final Function? onCancel;
  final Widget? icon;

  @override
  _CustomConfirmDialogDialogState createState() =>
      _CustomConfirmDialogDialogState();
}

class _CustomConfirmDialogDialogState extends State<CustomConfirmDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    return Dialog(
      clipBehavior: Clip.hardEdge,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20).copyWith(bottom: 0),
          child: Column(
            children: [
              widget.icon != null
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [widget.icon!],
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(widget.title,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              widget.contents.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.contents
                            .map((content) => Text(
                                  content,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xCC000000),
                                      fontWeight: FontWeight.w400),
                                ))
                            .toList(),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          height: 1,
          color: Colors.black.withValues(alpha: 0.05),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: SizedBox(
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                  textStyle: TextStyle(color: Colors.black),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  )),
              child: Text(widget.cancelText ?? dic.cancel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            color: Colors.black.withValues(alpha: 0.1),
          ),
          Expanded(
              child: SizedBox(
            height: 48,
            child: TextButton(
              style: TextButton.styleFrom(
                  foregroundColor:
                      widget.okColor ?? Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  )),
              child: Text(widget.okText ?? dic.confirm,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () {
                if (widget.onOk != null) {
                  widget.onOk!();
                }
                Navigator.of(context).pop(true);
              },
            ),
          )),
        ]),
      ]),
    );
  }
}
