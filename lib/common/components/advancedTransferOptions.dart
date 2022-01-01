import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/outlinedButtonSmall.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
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
      widget.nonceCtrl.clear();
      widget.feeCtrl.clear();
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
    final Map<String, String> dic = I18n.of(context).main;


    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButtonSmall(
                onPressed: onToggle,
                radius: 30,
                content: dic['advanceMode']!,
                shadowColor: Colors.transparent,
                suffixIcon: Icon(!visibility ? Icons.keyboard_arrow_down_sharp : Icons.keyboard_arrow_up_sharp)
            ),
            visibility ? FormPanel(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                  children: [
                    InputItem(
                      padding: EdgeInsets.zero,
                      placeholder: dic['feePlaceHolder']!,
                      controller: widget.feeCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        UI.decimalInputFormatter(COIN.decimals)
                      ],
                    ),
                    InputErrorTip(
                      padding: EdgeInsets.only(top: 8),
                      ctrl: widget.feeCtrl,
                      message: dic['feeTooLarge']!,
                      keepShow: false,
                      validate: _validateFee,
                      tipType: TipType.warn,
                    ),
                    InputItem(
                      placeholder: 'Nonce ' +  (widget.noncePlaceHolder ?? '').toString(),
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
