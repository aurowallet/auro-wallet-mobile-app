import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
enum TxItemTypes {
  address,
  amount,
  text
}
class TxItem {
  TxItem({required this.label,required this.value, this.type});
  final String label;
  final String value;
  final TxItemTypes? type;
}
class TxConfirmDialog extends StatelessWidget {
  TxConfirmDialog({
    required this.items,
    required this.title,
    this.onConfirm,
    this.disabled = false,
    this.buttonText
  });
  final List<TxItem> items;
  final String title;
  final String? buttonText;
  final bool disabled;
  final Function()? onConfirm;
  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).main;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )
        ),
        padding: EdgeInsets.only(left:28, top: 22, right: 28, bottom: 16),
        child: SafeArea(
          child: Wrap(
            children: [
              Center(child: Text(title, style: TextStyle(
                color: ColorsUtil.hexColor(0x090909),
                fontSize: 20,
                fontFamily: "PingFangSC-Medium",
              )),),
              ...items.map((e) {
                return TxConfirmItem(data: e,);
              }).toList(),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child:
                NormalButton(
                  disabled: disabled,
                  text: buttonText ?? dic['confirm']!,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        )
    );
  }
}
class TxConfirmItem extends StatelessWidget {
  TxConfirmItem({required this.data});
  final TxItem data;
  @override
  Widget build(BuildContext context) {
    Color valueColor;
    String text;
    var theme = Theme.of(context).textTheme;
    switch(data.type) {
      case TxItemTypes.amount:
        text = data.value;
        valueColor = Theme.of(context).primaryColor;
        break;
      case TxItemTypes.address:
        text = data.value;
        valueColor = ColorsUtil.hexColor(0x333333);
        break;
      default:
        text = data.value;
        valueColor = ColorsUtil.hexColor(0x333333);
        break;
    }
    return Padding(
      padding: EdgeInsets.only(top: 28),
      child: Row(
          children: [
            Container(
              width: 85,
              child: Text(data.label, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x999999)),),
            ),
            Expanded(
              child: Text(text, style: theme.headline5!.copyWith(color: valueColor))
            ),
          ]
      )
    );
  }
}