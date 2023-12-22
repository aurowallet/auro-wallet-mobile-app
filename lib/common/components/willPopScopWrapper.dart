import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/i18n/index.dart';

class WillPopScopWrapper extends StatelessWidget {
  WillPopScopWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: child,
      onWillPop: () async {
        if (Platform.isAndroid) {
          bool? res = await UI.showConfirmDialog(
            context: context,
            contents: [I18n.of(context).main['exitConfirm']!],
            okText: I18n.of(context).main['confirm']!,
            cancelText: I18n.of(context).main['cancel']!,
          );
          if (res == null || res == false) {
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        } else {
          return Future.value(true);
        }
      },
    );
  }
}
