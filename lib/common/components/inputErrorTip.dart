import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
enum TipType  {
  error,
  warn
}
class InputErrorTip extends StatefulWidget {
  InputErrorTip({
    required this.ctrl,
    required this.validate,
    required this.message,
    this.keepShow = true,
    this.showSuccess = false,
    this.focusNode,
    this.padding = const EdgeInsets.only(top: 5),
    this.tipType = TipType.error
  });

  final TextEditingController ctrl;
  final bool Function(String text) validate;
  final bool keepShow;
  final bool showSuccess;
  final String message;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final TipType tipType;
  @override
  _InputErrorTipState createState() => _InputErrorTipState();
}
class _InputErrorTipState extends State<InputErrorTip> {
  bool isCorrect = true;
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      widget.focusNode!.addListener((){
        if (!widget.focusNode!.hasFocus) {
          _onChange();
        }
      });
    } else {
      widget.ctrl.addListener(_onChange);
    }
  }
  void _onChange() {
    String text = widget.ctrl.text.trim();
    if(text.length > 0 && !isDirty) {
      isDirty = true;
    }
    if (isDirty) {
      bool success = widget.validate(text);
      setState(() {
        isCorrect = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.keepShow && (!isDirty && widget.showSuccess) || (isCorrect && !widget.showSuccess)) {
      return Container();
    }
    Color? textColor;
    if (widget.tipType == TipType.error) {
      textColor = isCorrect? ColorsUtil.hexColor(0xB9B9B9): ColorsUtil.hexColor(0xF95051);
    } else {
      textColor = ColorsUtil.hexColor(0xFFC633);
    }
    return Padding(
      padding: widget.padding,
      child: Row(
          children:[
            widget.tipType == TipType.error ? SvgPicture.asset(
                isCorrect ? 'assets/images/public/success_tip.svg' : 'assets/images/public/error_tip.svg',
                width: 15,
                height: 15
            ):   Icon(
        CupertinoIcons.exclamationmark_circle_fill,
        size: 20,
        color: ColorsUtil.hexColor(0xFFC633)
    ),
            Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(widget.message, style: TextStyle(color: textColor))
            )
          ]
      ),
    );
  }
}