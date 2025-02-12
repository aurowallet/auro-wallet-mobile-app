import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/inputItem.dart';

class TxAdvanceDialog extends StatefulWidget {
  TxAdvanceDialog(
      {this.onOk,
      this.onCancel,
      required this.currentNonce,
      required this.nextStateFee});

  final Function? onOk;
  final Function? onCancel;
  final int currentNonce;
  final double nextStateFee;
  final store = globalAppStore;

  @override
  _TxAdvanceDialogDialogState createState() => _TxAdvanceDialogDialogState();
}

class _TxAdvanceDialogDialogState extends State<TxAdvanceDialog> {
  final TextEditingController _feeCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _validateFee(String fee) {
    bool res = true;
    if (fee.isNotEmpty &&
        double.parse(fee) >= widget.store.assets!.transferFees.cap) {
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(dic.advanceMode,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: InputItem(
            label: dic.transactionFee,
            maxLength: 16,
            initialValue: '',
            placeholder: widget.nextStateFee.toString(),
            padding: EdgeInsets.only(top: 20),
            controller: _feeCtrl,
            inputFormatters: [UI.decimalInputFormatter(COIN.decimals)],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InputErrorTip(
          padding: EdgeInsets.only(top: 8, left: 20, right: 20),
          ctrl: _feeCtrl,
          message: dic.feeTooLarge,
          keepShow: false,
          validate: _validateFee,
          tipType: TipType.warn,
          hideIcon: true,
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: CustomStyledText(
            text: "Nonce",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xD9000000),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 44,
          margin: EdgeInsets.only(top: 6, left: 20, right: 20),
          padding: EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
              color: Colors.black.withValues(alpha: 0.05)),
          child: Text(widget.currentNonce.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
              )),
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
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textStyle: TextStyle(color: Colors.black)),
              child: Text(dic.cancel,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
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
            color: Colors.black.withValues(alpha: 0.1),
          ),
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dic.confirm,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600))
                  ],
                ),
                onPressed: () {
                  if (widget.onOk != null) {
                    widget.onOk!();
                  }
                  Navigator.of(context).pop(_feeCtrl.text.trim());
                },
              ),
            ),
          )
        ]),
      ]),
    );
  }
}
