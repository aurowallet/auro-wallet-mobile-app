import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:auro_wallet/store/assets/types/fees.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
class FeeSelector extends StatefulWidget {
  FeeSelector({
    required this.fees,
    required this.onChoose,
    required this.value,
  });

  final Fees fees;
  final double? value;
  final Function onChoose;

  @override
  _FeeSelectorState createState() => _FeeSelectorState();
}

class _FeeSelectorState extends State<FeeSelector> {
  // late double value;
  @override
  void initState() {
    super.initState();
    // value = widget.fees.medium;
  }


  void _onClick (checkedValue) {
    // setState(() {
    //   value = checkedValue;
    // });
    widget.onChoose(checkedValue);
  }
  @override
  Widget build(BuildContext context) {
    final fees = widget.fees;
    final Map<String, String> i18n = I18n.of(context).main;
    double? value = widget.value;
    return FormPanel(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i18n['fee']!),
              value == null ? Text('') :Text(value.toString())
            ]
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FeeItem(
                text: i18n['fee_slow']!,
                value: fees.slow,
                isActive: fees.slow == value,
                onClick: _onClick,
              ),
              FeeItem(
                text: i18n['fee_default']!,
                value: fees.medium,
                isActive: fees.medium == value,
                onClick: _onClick,
              ),
              FeeItem(
                text: i18n['fee_fast']!,
                value: fees.fast,
                isActive: fees.fast == value,
                onClick: _onClick,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class FeeItem extends StatelessWidget {
  FeeItem({
    required this.value,
    required this.text,
    required this.onClick,
    required this.isActive
  });

  final String text;
  final double value;
  final bool isActive;
  final Function onClick;

  void _onClick  () {
    this.onClick(this.value);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onClick,
      child:  Stack(
        overflow:Overflow.visible,
        children: [
          Container(
            width: 86,
            height: 44,
            decoration: BoxDecoration(
                color: ColorsUtil.hexColor(0xF6F6F6),
                borderRadius: BorderRadius.all(Radius.circular(6)),
                border: Border.all(
                    color: isActive ? ColorsUtil.hexColor(0x00C89C) : Colors.transparent
                )
            ),
            child:  Center(
              child: Text(this.text, style: TextStyle(fontSize: 16, color: ColorsUtil.hexColor(0x666666))),
            ),
          ),
          isActive ? Positioned(
              right: -5,
              top: -5,
              child: Image.asset('assets/images/assets/2x/round_checked@2x.png', width: 15, height: 15,)
          ): Container()
        ],
      ),
    );
  }
}