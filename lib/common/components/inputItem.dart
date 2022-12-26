import 'dart:math';

import 'package:auro_wallet/common/components/customStyledText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';

class InputItem extends StatefulWidget {
  InputItem(
      {
        this.label,
        this.initialValue,
        this.onChange,
        this.rightWidget,
        this.inputFormatters,
        this.keyboardType = TextInputType.text,
        this.controller,
        this.maxLines = 1,
        this.isPassword = false,
        this.padding = const EdgeInsets.only(top: 22),
        this.maxLength,
        this.focusNode,
        this.labelAffix,
        this.placeholder = '',
        this.backgroundColor =  Colors.white,
        this.borderColor =  const Color(0x1A000000),
        this.focusColor = Colors.transparent,
        this.inputPadding = const EdgeInsets.only(top: 6),
        this.suffixIcon,
        this.labelStyle,
        this.autoFocus = false,
        this.isError,
      });
  final int? maxLength;
  final bool autoFocus;
  final bool? isError;
  final String? label;
  final Widget? labelAffix;
  final TextStyle? labelStyle;
  final Widget? rightWidget;
  final String? placeholder;
  final bool isPassword;
  final String? initialValue;
  final Function? onChange;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final EdgeInsetsGeometry padding;
  final FocusNode? focusNode;
  final int? maxLines;
  final Color backgroundColor;
  final Color borderColor;
  final Color focusColor;
  final EdgeInsetsGeometry inputPadding;
  final Widget? suffixIcon;

  @override
  _InputItemState createState() => _InputItemState();
}

class _InputItemState extends State<InputItem> {

  bool _passwordVisibility = false;
  int specialCharsCount = 0;
  TextEditingController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? new TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialValue != null) {
        _controller!.text =  widget.initialValue!;
      }
      _controller?.addListener(_onTextChange);
    });
  }
  _onTextChange() {
    final value = _controller!.text;
    int counter = 0;
    for (int i = 0; i < value.length; i++) {
      if (value.codeUnitAt(i) > 122) {
        counter++;
      }
    }
    setState(() {
      specialCharsCount = counter;
    });
  }
  Widget _buildSuffixIcon() {
    return IconButton(
      icon: Icon(!_passwordVisibility ? Icons.visibility : Icons.visibility_off, color: ColorsUtil.hexColor(0xB0B3BF)),
      onPressed: (){
        setState((){
          _passwordVisibility = !_passwordVisibility;
        });
      },);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var labelStyle = TextStyle(fontSize: 12, color: const Color(0xD9000000), fontWeight: FontWeight.w600);
    if (widget.labelStyle != null) {
      labelStyle = labelStyle.merge(widget.labelStyle);
    }
    OutlineInputBorder border = OutlineInputBorder(
      gapPadding: 0,
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
          width: widget.borderColor == Colors.transparent ? 0 : 0.5,
          style: BorderStyle.solid,
          color: widget.isError == true ? Color(0xFFD65A5A) : widget.borderColor
      ),
    );
    final labelWidget  = widget.label == null ? null : CustomStyledText(
      text: widget.label!,
      textAlign: TextAlign.left,
      style: labelStyle,
    );
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: widget.labelAffix != null ? Column(
                children: [
                  Row(
                    children: [
                      labelWidget == null ? Container() : labelWidget,
                      Flexible(child: widget.labelAffix!),
                    ],
                  )
                ],
              ): (labelWidget == null ? Container() : labelWidget)),
              widget.rightWidget == null ? Container() : widget.rightWidget!,
            ],
          ),
          Padding(
            padding: widget.label != null || widget.rightWidget != null ? widget.inputPadding : EdgeInsets.all(0),
            child:  TextField(
              maxLength: widget.maxLength != null ? max(widget.maxLength! - specialCharsCount, 0) : null,
              maxLines: widget.maxLines,
              cursorColor: Theme.of(context).primaryColor,
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
              controller: widget.controller,
              obscureText: widget.isPassword && !_passwordVisibility,
              focusNode: widget.focusNode,
              autocorrect: false,
              autofocus: widget.autoFocus,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                filled: true,
                isDense: true,
                counterText: "",
                contentPadding: EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    left: 12,
                    right: widget.suffixIcon != null ? 0 : 12),
                fillColor: widget.backgroundColor,
                enabledBorder: border,
                suffixIcon: widget.isPassword
                    ? _buildSuffixIcon()
                    : (widget.suffixIcon ?? null),
                // enabledBorder: InputBorder.none,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(
                    color: widget.isError == true ? Color(0xFFD65A5A) : Theme.of(context).primaryColor
                  )
                ),
                focusedErrorBorder: border.copyWith(
                    borderSide: BorderSide(
                        color: Color(0xFFD65A5A)
                    )
                ),
                // focusColor: this.borderColor,
                // enabledBorder: InputBorder.none,
                // errorText: widget.errorText,
                errorStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD65A5A)
                ),
                errorBorder: border.copyWith(
                    borderSide: BorderSide(
                        color: Color(0xFFD65A5A)
                    )
                ),
                // disabledBorder: InputBorder.none,
              ),
            )
            ,),

        ],
      ),
    );

  }
}

