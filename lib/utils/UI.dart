import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/regInputFormatter.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/customAlertDialog.dart';
import 'package:auro_wallet/common/components/customConfirmDialog.dart';
import 'package:auro_wallet/common/components/passwordInputDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:update_app/update_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';
class UI {
  static void copyAndNotify(BuildContext context, String? text) {
    Clipboard.setData(ClipboardData(text: text ?? ''));
    final Map<String, String> dic = I18n.of(context).main;
    UI.toast('${dic['copySuccess']!}');
  }

  static void toast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0
    );
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      try {
        await launch(url);
      } catch (err) {
        print(err);
      }
    } else {
      print('Could not launch $url');
    }
  }

  static void showTxConfirm({
    required BuildContext context,
    required String title,
    required List<TxItem> items,
    Function()? onConfirm,
    String? buttonText,
    bool disabled = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled:true,
      builder: (BuildContext context) {
        return TxConfirmDialog(
            title: title,
            items: items, disabled: disabled,
            buttonText: buttonText,
            onConfirm: (){
              Navigator.pop(context);
              if (onConfirm != null) {
                onConfirm();
              }
            });
      },
    );
  }

  static Future<void> showAlertDialog({required BuildContext context,required List<String> contents,CrossAxisAlignment? crossAxisAlignment}) {
    return showDialog<String>(
      context: context,
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).main;
        return CustomAlertDialog(
          title: dic['prompt']!,
          contents:contents,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          onOk: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required List<String> contents,
    String? okText,
    String? cancelText
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).main;
        return CustomConfirmDialog(
          title: dic['prompt']!,
          okText: okText,
          cancelText: cancelText,
          contents: contents
        );
      },
    );
  }

  static Future<String?> showPasswordDialog({
    required BuildContext context,
    required WalletData wallet,
    bool validate = false
  }) {
    return showDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          wallet: wallet,
          validate: validate
        );
      },
    );
  }

  static TextInputFormatter decimalInputFormatter(int decimals) {
    return RegExInputFormatter.withRegex(
        '^[0-9]{0,$decimals}(\\.[0-9]{0,$decimals})?\$');
  }

  static unfocus(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}

final GlobalKey<RefreshIndicatorState> globalBalanceRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

final GlobalKey<RefreshIndicatorState> globalStakingRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
