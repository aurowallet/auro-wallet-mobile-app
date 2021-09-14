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
      margin:const EdgeInsets.only(top: 10, left: 28, right: 28),
      child: TextField(
        controller: editingController,
        autocorrect: false,
        style:const TextStyle(
            fontSize: 16.0,
            color: Colors.black
        ),
        decoration: InputDecoration(
            hintText: i18n['searchPlaceholder']!,
            prefixIcon: const Icon(Icons.search,),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            border:const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)))),
      ),
    );
  }
}
