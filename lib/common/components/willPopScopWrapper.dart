import 'dart:io';

import 'package:flutter/cupertino.dart';
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
          bool? res = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(I18n.of(context).main['exit.confirm']!),
              actions: <Widget>[
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(I18n.of(context).main['cancel']!),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  /*Navigator.of(context).pop(true)*/
                  child: Text(I18n.of(context).main['confirm']!),
                ),
              ],
            ),
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
