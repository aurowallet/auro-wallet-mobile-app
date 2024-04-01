import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/outlinedButtonSmall.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:flutter/services.dart';
class AdvancedTransferOptions extends StatefulWidget {
  AdvancedTransferOptions({required this.nonceCtrl,required this.feeCtrl, this.noncePlaceHolder, required this.cap});
  final TextEditingController nonceCtrl;
  final TextEditingController feeCtrl;
  final int? noncePlaceHolder;
  final double cap;

  @override
  _AdvancedTransferOptionsState createState() => _AdvancedTransferOptionsState();
}

class _AdvancedTransferOptionsState extends State<AdvancedTransferOptions> {

  bool visibility = false;
  void onToggle() {
    setState(() {
      visibility = !visibility;
      // widget.nonceCtrl.clear();
      // widget.feeCtrl.clear();
    });
  }
  bool _validateFee(String fee) {
    bool res = true;
    if (fee.isNotEmpty && double.parse(fee)  >= widget.cap) {
      res =  false;
    } else {
      res = true;
    }
    return res;
  }
  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.only(
                    right: 20,
                    top: 10,
                    bottom: 10
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: Stack(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 20), child: Text(dic.advanceMode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),),),
                    Positioned(
                      right: 0,
                      top: -1,
                      child: Icon(!visibility ? Icons.arrow_drop_down : Icons.arrow_drop_up, size: 20,))
                  ],
                )
            ),
            visibility ? Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                  children: [
                    InputItem(
                      label: dic.fee,
                      padding: EdgeInsets.zero,
                      controller: widget.feeCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        UI.decimalInputFormatter(COIN.decimals)
                      ],
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 8),
                      ctrl: widget.feeCtrl,
                      message: dic.feeTooLarge,
                      keepShow: false,
                      validate: _validateFee,
                      tipType: TipType.warn,
                      hideIcon: true,
                    ),
                    InputItem(
                      label: 'Nonce',
                      placeholder: (widget.noncePlaceHolder ?? '').toString(),
                      keyboardType: TextInputType.number,
                      controller: widget.nonceCtrl,
                      inputFormatters:  <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                    )
                  ]
              ),
            ): Container()
          ]
      )
    );
  }
}
