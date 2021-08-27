import 'package:flutter/cupertino.dart';
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
        this.padding = const EdgeInsets.only(top: 20),
        this.maxLength,
        this.focusNode,
        this.placeholder = '',
        this.backgroundColor = const Color.fromRGBO(246, 247, 248, 1.0),
        this.borderColor = Colors.transparent,
        this.focusColor = Colors.transparent,
        this.inputPadding = const EdgeInsets.only(top: 10),
        this.suffixIcon,
        this.autoFocus = false,
      });
  final int? maxLength;
  final bool autoFocus;
  final String? label;
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
  final int maxLines;
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
  TextEditingController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? new TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.initialValue != null) {
        _controller!.text =  widget.initialValue!;
      }
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
    OutlineInputBorder border = OutlineInputBorder(
      gapPadding: 0,
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
          width: widget.borderColor == Colors.transparent ? 0 : 1,
          style: BorderStyle.solid,
          color: widget.borderColor
      ),
    );
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.label == null ? Container() : Flexible(
                  child: Text(
                    widget.label!,
                    textAlign: TextAlign.left,
                    style: theme.headline5,
                  )),
              widget.rightWidget == null ? Container() : widget.rightWidget!,
            ],
          ),
          Padding(
            padding: widget.label != null || widget.rightWidget != null ? widget.inputPadding : EdgeInsets.all(0),
            child:  TextField(
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              cursorColor: Colors.black,
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
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                fillColor: widget.backgroundColor,
                enabledBorder: border,
                suffixIcon: widget.isPassword ? _buildSuffixIcon() : (widget.suffixIcon ?? null),
                // enabledBorder: InputBorder.none,
                focusedBorder: border.copyWith(
                  borderSide: border.borderSide.copyWith(
                      color: widget.focusColor
                  ),
                ),
                // focusColor: this.borderColor,
                // enabledBorder: InputBorder.none,
                // errorBorder: InputBorder.none,
                // disabledBorder: InputBorder.none,
              ),
            )
            ,),

        ],
      ),
    );

  }
}

