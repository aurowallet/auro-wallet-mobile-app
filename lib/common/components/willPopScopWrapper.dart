import 'dart:io';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/UI.dart';

class WillPopScopWrapper extends StatelessWidget {
  WillPopScopWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return new WillPopScope(
      child: child,
      onWillPop: () async {
        if (Platform.isAndroid) {
          bool? res = await UI.showConfirmDialog(
            context: context,
            contents: [dic.exitConfirm],
            okText: dic.confirm,
            cancelText: dic.cancel,
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
