import 'package:auro_wallet/common/components/customStyledText.dart';
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
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text(widget.title, style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: widget.crossAxisAlignment,
                  children: widget.contents
                      .map((content) => CustomStyledText(
                            text: content,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2
                            ),
                          ))
                      .toList(),
                ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    height: 0.5,
                    margin: EdgeInsets.only(top: 30),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.confirm ?? dic['confirm']!)
                      ],
                    ),
                    onPressed: widget.onOk,
                  ),
                ],
              ),
            )
          ]
      ),
    );
  }
}
