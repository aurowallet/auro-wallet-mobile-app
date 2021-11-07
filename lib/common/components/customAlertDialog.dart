import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';

class CustomAlertDialog extends StatefulWidget {
  CustomAlertDialog({
    required this.title,
    required this.contents,
    this.onOk,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.confirm
  });

  final String title;
  final String? confirm;
  final List<String> contents;
  final void Function()? onOk;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  _CustomAlertDialogDialogState createState() => _CustomAlertDialogDialogState();
}

class _CustomAlertDialogDialogState extends State<CustomAlertDialog> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;

    var theme = Theme.of(context).textTheme;
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
                  child: Text(widget.title, style: theme.headline3),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: widget.crossAxisAlignment,
                    children: widget.contents.map((content) => Text(content, style: theme.headline5,)).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 27),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 40,
                        child: FlatButton(
                          color: Theme.of(context).primaryColor,
                          shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.confirm ?? dic['confirm']!, style: TextStyle(color: Colors.white))
                            ],
                          ),
                          onPressed: widget.onOk,
                        ),

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
