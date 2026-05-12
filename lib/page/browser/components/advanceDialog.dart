import 'package:auro_wallet/common/components/feeButtonGroup.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/consts/enums.dart';
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
    required this.nonce,
    required this.fee,
    required this.feePlaceHolder,
    required this.feeType,
    this.showFeeButtons = true,
  });

  final Function(double? fee, int nonce) onConfirm;
  final int nonce;
  final double fee;
  final double feePlaceHolder;
  final ZkAppValueEnum feeType;
  final bool showFeeButtons;

  @override
  _AdvanceDialogState createState() => _AdvanceDialogState();
}

class _AdvanceDialogState extends State<AdvanceDialog> {
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _nonceCtrl = TextEditingController();
  final store = globalAppStore;

  @override
  void initState() {
    super.initState();
    _feeCtrl.text = widget.feeType == ZkAppValueEnum.recommed_custom
        ? widget.fee.toString()
        : "";
    _feeCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void onConfirm() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String inputFee = _feeCtrl.text.trim();
    String inputNonce = _nonceCtrl.text.trim();
    int inferredNonce = widget.nonce;

    if (inputFee.isNotEmpty) {
      final parsedFee = double.tryParse(inputFee);
      if (parsedFee == null || parsedFee <= 0) {
        UI.toast(dic.inputFeeError);
        return;
      }
    }
    if (inputNonce.isNotEmpty) {
      final parsedNonce = int.tryParse(inputNonce);
      if (parsedNonce == null || parsedNonce < 0) {
        UI.toast(dic.inputNonceError);
        return;
      }
    }

    double? fee;
    int nonce = 0;
    try {
      if (inputFee.isNotEmpty) {
        fee = double.parse(inputFee);
      }
    } catch (e) {
      fee = null;
    }
    try {
      nonce = inputNonce.isNotEmpty ? int.parse(inputNonce) : inferredNonce;
    } catch (e) {
      nonce = widget.nonce;
    }

    Navigator.of(context).pop();
    widget.onConfirm(fee, nonce);
  }

  void _onClickFeeButton(double fee) {
    _feeCtrl.text = fee.toString();
  }

  bool _validateFee(String fee) {
    return !store.assets!.transferFees.isFeeExceedsCap(fee);
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _nonceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrowserDialogTitleRow(title: dic.advanceMode, showCloseIcon: true),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: InputItem(
                label: dic.networkFee,
                maxLength: 16,
                placeholder: widget.feeType != ZkAppValueEnum.recommed_custom
                    ? widget.feePlaceHolder.toString()
                    : "",
                padding: EdgeInsets.only(top: 20),
                controller: _feeCtrl,
                inputFormatters: [UI.decimalInputFormatter(COIN.decimals)],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
                suffixIcon: widget.showFeeButtons
                    ? Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: FeeButtonGroup(
                          fees: store.assets!.transferFees,
                          currentFeeText: _feeCtrl.text,
                          fallbackFee: widget.feePlaceHolder,
                          onSelectFee: _onClickFeeButton,
                        ),
                      )
                    : null,
                suffixIconConstraints: BoxConstraints(minHeight: 0, minWidth: 0),
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
                placeholder: widget.nonce.toString(),
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
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: ZkAppBottomButton(
                onConfirm: onConfirm,
                hideCancel: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
