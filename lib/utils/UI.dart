import 'dart:async';
import 'package:auro_wallet/common/components/TxAction/txActionDialog.dart';
import 'package:auro_wallet/common/components/importLedgerDialog.dart';
import 'package:auro_wallet/common/components/networkSelectionDialog.dart';
import 'package:auro_wallet/common/components/tokenTxDialog.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/token/component/tokenManageDialog.dart';
import 'package:auro_wallet/page/assets/token/component/tokenSelectDialog.dart';
import 'package:auro_wallet/page/browser/components/accountSelectDialog.dart';
import 'package:auro_wallet/page/browser/components/addChainDialog.dart';
import 'package:auro_wallet/page/browser/components/advanceDialog.dart';
import 'package:auro_wallet/page/browser/components/connectDialog.dart';
import 'package:auro_wallet/page/browser/components/signTransactionDialog.dart';
import 'package:auro_wallet/page/browser/components/signatureDialog.dart';
import 'package:auro_wallet/page/browser/components/switchChainDialog.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/tokenPendingTx.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auro_wallet/common/regInputFormatter.dart';
import 'package:auro_wallet/common/components/txConfirmDialog.dart';
import 'package:auro_wallet/common/components/customAlertDialog.dart';
import 'package:auro_wallet/common/components/customConfirmDialog.dart';
import 'package:auro_wallet/common/components/passwordInputDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auro_wallet/store/wallet/types/walletData.dart';

class UI {
  static void copyAndNotify(BuildContext context, String? text) {
    Clipboard.setData(ClipboardData(text: text ?? ''));
    AppLocalizations dic = AppLocalizations.of(context)!;
    UI.toast('${dic.copySuccess}');
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
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } catch (err) {
      print(err);
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
        AppLocalizations dic = AppLocalizations.of(context)!;
        return WillPopScope(
          onWillPop: () async => !disableBack,
          child: CustomAlertDialog(
            title: dic.prompt,
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
      String? accountName,
      String password = ""}) {
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
            accountName: accountName,
            password: password);
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
        AppLocalizations dic = AppLocalizations.of(context)!;
        return CustomConfirmDialog(
          title: title ?? dic.prompt,
          okText: okText,
          okColor: okColor,
          cancelText: cancelText,
          contents: contents,
          icon: icon,
        );
      },
    );
  }

  static Future<String?> showPasswordDialog({
    required BuildContext context,
    required WalletData wallet,
    bool inputPasswordRequired = false,
    bool isTransaction = false,
    AppStore? store,
  }) {
    if (isTransaction) {
      final isTransactionEnable = webApi.account.getTransactionPwdEnabled();
      if (!isTransactionEnable && store != null) {
        String pwd = store.wallet!.runtimePwd;
        if (pwd.isNotEmpty) {
          return Future.value(pwd);
        }
      }
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (_) {
        return PasswordInputDialog(
            wallet: wallet, inputPasswordRequired: inputPasswordRequired);
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
            txData: txData,
            modalType: modalType,
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

  static Future<void> showConnectAction({
    required BuildContext context,
    required String url,
    String? iconUrl,
    required Future<void> Function() onConfirm,
    Function()? onCancel,
    String? buttonText,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return ConnectDialog(
            url: url,
            iconUrl: iconUrl,
            onConfirm: () async {
              onConfirm();
              Navigator.of(context).pop();
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
            });
      },
    );
  }

  static Future<void> showSwitchChainAction({
    required BuildContext context,
    required String networkID,
    required String url,
    String? iconUrl,
    String? gqlUrl,
    required Future Function(String, String) onConfirm,
    Function()? onCancel,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SwitchChainDialog(
            networkID: networkID,
            url: url,
            iconUrl: iconUrl,
            gqlUrl: gqlUrl,
            onConfirm: (String networkName, String networkID) async {
              await onConfirm(networkName, networkID);
              Navigator.of(context).pop();
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
            });
      },
    );
  }

  static Future<void> showAddChainAction({
    required BuildContext context,
    required String nodeUrl,
    required String nodeName,
    required String url,
    String? iconUrl,
    required Function() onConfirm,
    Function()? onCancel,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return AddChainDialog(
            nodeUrl: nodeUrl,
            nodeName: nodeName,
            url: url,
            iconUrl: iconUrl,
            onConfirm: () {
              onConfirm();
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
            });
      },
    );
  }

  static Future<void> showSignatureAction({
    required BuildContext context,
    required Object content,
    required String url,
    required String method,
    String? iconUrl,
    required Future<void> Function(Map) onConfirm,
    Function()? onCancel,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SignatureDialog(
            method: method,
            content: content,
            url: url,
            iconUrl: iconUrl,
            onConfirm: (Map data) async {
              onConfirm(data);
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
            });
      },
    );
  }

  static Future<void> showSignTransactionAction({
    required BuildContext context,
    required SignTxDialogType signType,
    required String to,
    required int nonce,
    String? zkNonce,
    String? amount,
    String? fee,
    String? memo,
    Object? transaction,
    bool? onlySign,
    Map<String, dynamic>? feePayer,
    required String url,
    String? iconUrl,
    required Future<String> Function(String, int) onConfirm,
    Function()? onCancel,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SignTransactionDialog(
            signType: signType,
            to: to,
            amount: amount,
            zkNonce: zkNonce,
            fee: fee,
            memo: memo,
            feePayer: feePayer,
            transaction: transaction,
            onlySign: onlySign,
            url: url,
            iconUrl: iconUrl,
            preNonce: nonce,
            onConfirm: (String hash, int nonce) async {
              await onConfirm(hash, nonce);
              Navigator.of(context).pop();
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
            });
      },
    );
  }

  static Future<void> showAccountSelectAction({
    required BuildContext context,
    required Function(String) onSelectAccount,
    String? buttonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return AccountSelectDialog(
          onSelectAccount: (String address) {
            onSelectAccount(address);
          },
        );
      },
    );
  }

  static Future<void> showAdvance({
    required BuildContext context,
    required double fee,
    required int nonce,
    required Function(double, int) onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AdvanceDialog(
          nextStateFee: fee,
          nonce: nonce,
          onConfirm: (double fee, int nonce) {
            onConfirm(fee, nonce);
          },
        );
      },
    );
  }

  static Future<void> showNetworkSelectDialog({
    required BuildContext context,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return NetworkSelectionDialog();
      },
    );
  }

  static Future<void> showTokenSelectDialog({
    required BuildContext context,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return TokenSelectionDialog();
      },
    );
  }

  static Future<void> showTokenManageDialog({
    required BuildContext context,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return TokenManageDialog();
      },
    );
  }

  static Future<bool?> showTokenTxDialog({
    required BuildContext context,
    required List<TokenPendingTx> txList,
    Function()? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return TokenTxDialog(
          txList: txList,
          onOk: () {
            if (onConfirm != null) {
              onConfirm();
            }
          },
        );
      },
    );
  }
}

final GlobalKey<RefreshIndicatorState> globalBalanceRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

final GlobalKey<RefreshIndicatorState> globalStakingRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

final GlobalKey<RefreshIndicatorState> globalTokenRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
