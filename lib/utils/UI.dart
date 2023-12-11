import 'dart:async';
import 'dart:io';
import 'package:auro_wallet/common/components/TxAction/txActionDialog.dart';
import 'package:auro_wallet/common/components/importLedgerDialog.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/regInputFormatter.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/customAlertDialog.dart';
import 'package:auro_wallet/common/components/customConfirmDialog.dart';
import 'package:auro_wallet/common/components/passwordInputDialog.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
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
        fontSize: 14.0);
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

  static Future<void> showTxConfirm({
    required BuildContext context,
    required String title,
    required List<TxItem> items,
    required Future<bool?> Function() onConfirm,
    String? buttonText,
    String? headLabel,
    Widget? headValue,
    bool disabled = false,
    bool isLedger = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return TxConfirmDialog(
            title: title,
            items: items,
            isLedger: isLedger,
            disabled: disabled,
            headerLabel: headLabel,
            headerValue: headValue,
            buttonText: buttonText,
            onConfirm: () async {
              bool? success = await onConfirm();
              if (success == false) {
                Navigator.of(context).pop();
              }
            });
      },
    );
  }

  static Future<void> showAlertDialog(
      {required BuildContext context,
      required List<String> contents,
      String? confirm,
      Function()? onConfirm,
      CrossAxisAlignment? crossAxisAlignment,
      bool barrierDismissible = true,
      bool disableBack = false}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).main;
        return WillPopScope(
          onWillPop: () async => !disableBack,
          child: CustomAlertDialog(
            title: dic['prompt']!,
            confirm: confirm,
            contents: contents,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
            onOk: () {
              Navigator.of(context).pop();
              if (onConfirm != null) {
                onConfirm();
              }
            },
          ),
        );
      },
    );
  }

  static Future<bool?> showImportLedgerDialog(
      {required BuildContext context,
      bool generateAddress = false,
      int? accountIndex,
      String? accountName}) {
    return showModalBottomSheet<bool?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return ImportLedger(
            generateAddress: generateAddress,
            accountIndex: accountIndex,
            accountName: accountName);
      },
    );
  }

  static Future<bool?> showConfirmDialog(
      {required BuildContext context,
      required List<String> contents,
      String? okText,
      String? title,
      Color? okColor,
      String? cancelText,
      Widget? icon}) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).main;
        return CustomConfirmDialog(
          title: title ?? dic['prompt']!,
          okText: okText,
          okColor: okColor,
          cancelText: cancelText,
          contents: contents,
          icon: icon,
        );
      },
    );
  }

  static Future<String?> showPasswordDialog(
      {required BuildContext context,
      required WalletData wallet,
      bool validate = false,
      bool inputPasswordRequired = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (_) {
        return PasswordInputDialog(
            wallet: wallet,
            validate: validate,
            inputPasswordRequired: inputPasswordRequired);
      },
    );
  }

  static TextInputFormatter decimalInputFormatter(int decimals) {
    return RegExInputFormatter.withRegex(
        '^[0-9]{0,}([\\.\\,][0-9]{0,$decimals})?\$');
  }

  static unfocus(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  static Future<void> showTxAction({
    required BuildContext context,
    required String title,
    required TransferData txData,
    required Future<bool?> Function() onConfirm,
    required TxActionType modalType,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return TxActionDialog(
            title: title,
            txData:txData,
            modalType:modalType,
            buttonText: buttonText,
            onConfirm: () async {
              bool? success = await onConfirm();
              if (success == false) {
                Navigator.of(context).pop();
              }
            });
      },
    );
  }
}

final GlobalKey<RefreshIndicatorState> globalBalanceRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

final GlobalKey<RefreshIndicatorState> globalStakingRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
