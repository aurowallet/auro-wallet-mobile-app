import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
enum TipType  {
  error,
  warn,
}


class InputErrorTip extends StatefulWidget {
  InputErrorTip({
    required this.ctrl,
    // required this.validate,
    required this.message,
    this.keepShow = true,
    this.showSuccess = false,
    this.focusNode,
    this.hideIcon = false,
    this.padding = const EdgeInsets.only(top: 5),
    this.tipType = TipType.error,
    this.validate,
    this.asyncValidate,
    this.showMessage = true
  });

  final TextEditingController ctrl;
  final bool Function(String text)? validate;
  final Future<bool> Function(String text)? asyncValidate;
  final bool keepShow;
  final bool showMessage;
  final bool hideIcon;
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
      widget.focusNode?.addListener((){
        if (widget.focusNode != null && !widget.focusNode!.hasFocus) {
          _onChange();
        }
      });
    } else {
      widget.ctrl.addListener(_onChange);
    }
  }
  void _onChange() async {
    String text = widget.ctrl.text.trim();
    if(text.length > 0 && !isDirty) {
      isDirty = true;
    }
    if (isDirty) {
      bool success = true;
      if (widget.validate != null) {
        success = widget.validate!(text);
      } else if (widget.asyncValidate != null) {
        success = await widget.asyncValidate!(text);
      }
      if (mounted) {
        setState(() {
          isCorrect = success;
        });
      }
    }
  }
  Widget renderTip (TipType tipType, bool hideIcon) {
    if (hideIcon) {
      return Container();
    }
    switch(tipType) {
      case TipType.error:
        return SvgPicture.asset(
            isCorrect ? 'assets/images/public/success_tip.svg' : 'assets/images/public/error_tip.svg',
            width: 15,
            height: 15
        );
      default:
        return Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 20,
            color: ColorsUtil.hexColor(0xFFC633)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.keepShow && (!isDirty && widget.showSuccess) || (isCorrect && !widget.showSuccess) || !widget.showMessage) {
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
            this.renderTip(widget.tipType, widget.hideIcon),
            Padding(
                padding: EdgeInsets.only(left: widget.hideIcon ? 0 :6),
                child: Text(widget.message, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500))
            )
          ]
      ),
    );
  }
}