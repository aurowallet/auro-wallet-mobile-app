import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
enum TxItemTypes {
  address,
  amount,
  text,
  head
}
class TxItem {
  TxItem({required this.label,required this.value, this.type});
  final String label;
  final String value;
  final TxItemTypes? type;
}

class TxConfirmDialog extends StatefulWidget {
  TxConfirmDialog({
    required this.items,
    required this.title,
    this.onConfirm,
    this.disabled = false,
    this.buttonText,
    this.headerLabel,
    this.headerValue,
  });
  final List<TxItem> items;
  final String title;
  final String? headerLabel;
  final Widget? headerValue;
  final String? buttonText;
  final bool disabled;
  final Function()? onConfirm;
  @override
  _TxConfirmDialogState createState() => new _TxConfirmDialogState();
}
class _TxConfirmDialogState extends State<TxConfirmDialog> {

  bool submitting = false;
  Widget renderHead(String headerLabel, Widget headerValue) {
    return Padding(
      padding:const EdgeInsets.only(top: 40),
      child: Center(
        child:  Column(
          children: [
            Text(headerLabel, style: TextStyle(color:const Color(0x80000000), fontSize: 14, fontWeight: FontWeight.w500),),
            headerValue
          ],
        ),
      ),
    );
  }
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
        padding: EdgeInsets.only(left:0, top: 8, right: 0, bottom: 16),
        child: SafeArea(
          child: Stack(
            children: [
              Wrap(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      child: Text(widget.title, style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                      )),
                  ),
                  Container(
                    height: 0.5,
                    color: Color(0xFF000000).withOpacity(0.1),
                  ),
                  widget.headerLabel != null && widget.headerValue != null ? this.renderHead(widget.headerLabel!, widget.headerValue!) : Container(),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      children: [
                        ...widget.items.map((e) {
                          return TxConfirmItem(data: e,);
                        }).toList(),
                        Padding(
                          padding: EdgeInsets.only(top: 40, left: 18, right: 18),
                          child:
                          NormalButton(
                            disabled: widget.disabled,
                            submitting: submitting,
                            text: widget.buttonText ?? dic['confirm']!,
                            onPressed: () {
                              setState(() {
                                submitting = true;
                              });
                              if (widget.onConfirm != null) {
                                widget.onConfirm!();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/images/public/icon_nav_close.svg',
                    width: 24,
                    height: 24,
                    color: Colors.black,
                  ),
                  onTap: ()=> Navigator.pop(context),
                ),
                top: 8,
                right: 20,
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
        // valueColor = Theme.of(context).primaryColor;
        break;
      case TxItemTypes.address:
        text = data.value;
        // valueColor = ColorsUtil.hexColor(0x333333);
        break;
      default:
        text = data.value;
        // valueColor = ColorsUtil.hexColor(0x333333);
        break;
    }
    return Padding(
      padding: EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // width: 85,
              child: Text(data.label, style: TextStyle(fontSize: 14, color: Color(0x80000000), height: 1.33, fontWeight: FontWeight.w500),),
            ),
            Container(
              height: 4,
            ),
            Text(text, style: TextStyle(color: Colors.black, fontSize: 14, height: 1.33, fontWeight: FontWeight.w500)),
          ]
      )
    );
  }
}