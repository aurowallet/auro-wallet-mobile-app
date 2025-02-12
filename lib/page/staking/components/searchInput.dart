
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchInput extends StatelessWidget {
  SearchInput(
      {required this.editingController,
      this.placeholder,
      this.onSubmit,
      this.commentFocus,
      this.isReadOnly,
      this.onClickInput,
      this.customMargin,
      this.suffixIcon});

  final TextEditingController editingController;
  final String? placeholder;
  final Function? onSubmit;
  final FocusNode? commentFocus;
  final bool? isReadOnly;
  final void Function()? onClickInput;
  final EdgeInsetsGeometry? customMargin;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool lastReadStatus = isReadOnly ?? false;
    return Container(
      margin:
          customMargin ?? const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: TextField(
        onTap: onClickInput,
        readOnly: lastReadStatus,
        textInputAction: TextInputAction.go,
        focusNode: commentFocus,
        onSubmitted: (value) {
          if (this.onSubmit != null) {
            this.onSubmit!(value);
          }
        },
        controller: editingController,
        autocorrect: false,
        style: const TextStyle(
          fontSize: 14.0,
          height: 17 / 14,
          color: Colors.black,
        ),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.05),
            hintText: placeholder != null ? placeholder : dic.searchPlaceholder,
            hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black.withValues(alpha: 0.3)),
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 9, bottom: 8, left: 8, right: 12),
              child: SvgPicture.asset(
                'assets/images/public/search.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Color(0x80000000), BlendMode.srcIn)
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
            suffixIcon: suffixIcon??null,
            suffixIconConstraints: BoxConstraints(minWidth: 16, minHeight: 16),
            contentPadding: EdgeInsets.only(right: 8),
            isDense: true,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(6))),
            focusColor: Colors.black,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(6)))),
      ),
    );
  }
}
