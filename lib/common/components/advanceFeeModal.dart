import 'package:auro_wallet/common/components/feeButtonGroup.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvanceFeeModal extends StatefulWidget {
  AdvanceFeeModal({
    required this.currentFee,
    required this.transferFees,
    required this.onConfirm,
    this.currentNonce,
    this.advanceFee,
    this.advanceNonce,
    this.showFeeButtons = true,
  });

  final double currentFee;
  final Fees transferFees;
  final Function(String fee, String nonce) onConfirm;
  final int? currentNonce;
  final String? advanceFee;
  final String? advanceNonce;
  final bool showFeeButtons;

  @override
  _AdvanceFeeModalState createState() => _AdvanceFeeModalState();
}

class _AdvanceFeeModalState extends State<AdvanceFeeModal> {
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _nonceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.advanceFee != null && widget.advanceFee!.isNotEmpty) {
      _feeCtrl.text = widget.advanceFee!;
    }
    if (widget.advanceNonce != null && widget.advanceNonce!.isNotEmpty) {
      _nonceCtrl.text = widget.advanceNonce!;
    }
    _feeCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _nonceCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    _nonceCtrl.dispose();
    super.dispose();
  }

  void _onClickFeeButton(double fee) {
    _feeCtrl.text = fee.toString();
  }

  bool _validateFee(String fee) {
    return !widget.transferFees.isFeeExceedsCap(fee);
  }

  bool _isValidNumber(String value) {
    if (value.isEmpty) return true;
    final parsed = double.tryParse(value);
    return parsed != null && parsed > 0;
  }

  bool _isValidNonce(String value) {
    if (value.isEmpty) return true;
    final parsed = int.tryParse(value);
    return parsed != null && parsed >= 0;
  }

  void _handleConfirm() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final inputFee = _feeCtrl.text.trim();
    final inputNonce = _nonceCtrl.text.trim();

    if (inputFee.isNotEmpty && !_isValidNumber(inputFee)) {
      UI.toast(dic.inputFeeError);
      return;
    }
    if (inputNonce.isNotEmpty && !_isValidNonce(inputNonce)) {
      UI.toast(dic.inputNonceError);
      return;
    }
    Navigator.of(context).pop();
    widget.onConfirm(inputFee, inputNonce);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dic.advanceMode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, size: 22, color: Color(0xFF222222)),
                    ),
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: Color(0xFFF2F2F2),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputItem(
                      label: dic.networkFee,
                      placeholder: widget.currentFee.toString(),
                      padding: EdgeInsets.zero,
                      controller: _feeCtrl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        UI.decimalInputFormatter(COIN.decimals)
                      ],
                      suffixIcon: widget.showFeeButtons
                          ? Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: FeeButtonGroup(
                                fees: widget.transferFees,
                                currentFeeText: _feeCtrl.text,
                                fallbackFee: widget.currentFee,
                                onSelectFee: _onClickFeeButton,
                              ),
                            )
                          : null,
                      suffixIconConstraints: BoxConstraints(minHeight: 0, minWidth: 0),
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 8),
                      ctrl: _feeCtrl,
                      message: dic.feeTooLarge,
                      keepShow: false,
                      validate: _validateFee,
                      tipType: TipType.warn,
                      hideIcon: true,
                    ),
                    InputItem(
                      label: 'Nonce',
                      placeholder:
                          widget.currentNonce?.toString() ?? '',
                      padding: EdgeInsets.only(top: 20),
                      controller: _nonceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    left: 38, right: 38, top: 30, bottom: 20),
                child: NormalButton(
                  text: dic.confirm,
                  onPressed: _handleConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAdvanceFeeModal({
  required BuildContext context,
  required double currentFee,
  required Fees transferFees,
  required Function(String fee, String nonce) onConfirm,
  int? currentNonce,
  String? advanceFee,
  String? advanceNonce,
  bool showFeeButtons = true,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AdvanceFeeModal(
          currentFee: currentFee,
          transferFees: transferFees,
          onConfirm: onConfirm,
          currentNonce: currentNonce,
          advanceFee: advanceFee,
          advanceNonce: advanceNonce,
          showFeeButtons: showFeeButtons,
        ),
      );
    },
  );
}
