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
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (Platform.isAndroid) {
          bool? res = await UI.showConfirmDialog(
            context: context,
            contents: [dic.exitConfirm],
            okText: dic.confirm,
            cancelText: dic.cancel,
          );
          if (res == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: child,
    );
  }
}
