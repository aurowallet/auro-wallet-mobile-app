import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ZkAppBottomButton extends StatelessWidget {
  ZkAppBottomButton({
    required this.onConfirm,
    this.onCancel,
    this.hideCancel,
    this.submitting,
    this.disabled = false,
    this.confirmBtnText,
  });

  final Function()? onCancel;
  final Function() onConfirm;
  final bool? hideCancel;
  final bool? submitting;
  final bool disabled;
  final String? confirmBtnText;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    List<Widget> leftWidget = [];
    if (!(hideCancel == true)) {
      leftWidget.add(Expanded(
          child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.10),
          ),
        ),
        onPressed: () {
          if (onCancel != null) {
            onCancel!();
          }
          Navigator.of(context).pop();
        },
        child: Text(dic.cancel,
            style: TextStyle(
                color: Color(0xFF594AF1),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      )));
      leftWidget.add(SizedBox(width: 15));
    }
    return Container(
      margin: EdgeInsets.only(
        top: 20,
      ),
      padding: EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...leftWidget,
          Expanded(
            child: NormalButton(
                submitting: submitting == true,
                disabled: disabled,
                text: confirmBtnText ?? dic.confirm,
                onPressed: () {
                  onConfirm();
                },
                textStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
