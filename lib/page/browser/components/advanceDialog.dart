import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvanceDialog extends StatefulWidget {
  AdvanceDialog({
    required this.onConfirm,
    this.nextStateFee,
  });

  final Function(double fee, int nonce) onConfirm;
  final double? nextStateFee;

  @override
  _AdvanceDialogState createState() => new _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final TextEditingController _feeCtrl = new TextEditingController();
  final TextEditingController _nonceCtrl = new TextEditingController();

  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
  }

  void onConfirm() {
    String inputFee = _feeCtrl.text.trim();
    String inputNonce = _nonceCtrl.text.trim();
    int inferredNonce = store.assets!.accountsInfo[store.wallet!.currentAddress]
        ?.inferredNonce as int;

    double fee = 0.0101;
    if (inputFee.isNotEmpty) {
      fee = double.parse(inputFee);
    } else if (widget.nextStateFee is double) {
      fee = widget.nextStateFee as double;
    }
    int nonce = inputNonce.isNotEmpty ? int.parse(inputNonce) : inferredNonce;
    widget.onConfirm!(fee, nonce);
    Navigator.of(context).pop();
  }

  bool _validateFee(String fee) {
    bool res = true;
    if (fee.isNotEmpty && double.parse(fee) >= store.assets!.transferFees.cap) {
      res = false;
    } else {
      res = true;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 16),
        child: SafeArea(
          child: Stack(
            children: [
              Wrap(
                children: [
                  BrowserDialogTitleRow(
                      title: dic.advanceMode, showCloseIcon: true),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: InputItem(
                      label: dic.feePlaceHolder,
                      maxLength: 16,
                      initialValue: '',
                      placeholder: widget.nextStateFee is double
                          ? widget.nextStateFee.toString()
                          : "",
                      padding: EdgeInsets.only(top: 20),
                      controller: _feeCtrl,
                      inputFormatters: [
                        UI.decimalInputFormatter(COIN.decimals)
                      ],
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: InputItem(
                      label: "Nonce",
                      initialValue: '',
                      placeholder: store
                          .assets!
                          .accountsInfo[store.wallet!.currentAddress]
                          ?.inferredNonce
                          .toString(),
                      padding: EdgeInsets.only(top: 20),
                      controller: _nonceCtrl,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ZkAppBottomButton(
                    onConfirm: onConfirm,
                    hideCancel: true,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
