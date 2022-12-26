import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/staking/staking.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SearchInput extends StatelessWidget {
  SearchInput({required this.editingController});
  final TextEditingController editingController;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> i18n = I18n.of(context).main;
    return Container(
      margin:const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: editingController,
        autocorrect: false,
        style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
        ),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.05),
            hintText: i18n['searchPlaceholder']!,
            hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.3)),
            prefixIcon: Icon(Icons.search, size: 26, color: Colors.black.withOpacity(0.5),),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40
            ),
            contentPadding:  EdgeInsets.symmetric(vertical: 0),
            isDense: true,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(6))
            ),
            focusColor: Colors.black,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(6))
            )
        ),
      ),
    );
  }
}
