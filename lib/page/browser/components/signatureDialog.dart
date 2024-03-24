import 'dart:convert';

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/browserTab.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/wallet/wallet.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/network.dart';
import 'package:flutter/material.dart';

class SignatureDialog extends StatefulWidget {
  SignatureDialog({
    required this.method,
    required this.content,
    required this.url,
    this.iconUrl,
    this.onConfirm,
    this.onCancel,
  });

  final Object content;
  final String method;
  final String url;
  final String? iconUrl;
  final Function(Map)? onConfirm;
  final Function()? onCancel;

  @override
  _SignatureDialogState createState() => new _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final store = globalAppStore;
  bool formatStatus = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onConfirm() async {
    print('onConfirm');
    AppLocalizations dic = AppLocalizations.of(context)!;
    final isLedger =
        store.wallet!.currentWallet.walletType == WalletStore.seedTypeLedger;
    if (!formatStatus) {
      UI.toast("Error: Unknown content type");
      return false;
    }
    if (!isLedger) {
      String? privateKey;
      String? password = await UI.showPasswordDialog(
          context: context,
          wallet: store.wallet!.currentWallet,
          inputPasswordRequired: false);
      if (password == null) {
        return false;
      }
      privateKey = await webApi.account.getPrivateKey(
          store.wallet!.currentWallet,
          store.wallet!.currentWallet.currentAccountIndex,
          password);
      if (privateKey == null) {
        UI.toast(dic.passwordError);
        return false;
      }
      setState(() {
        submitting = true;
      });
      Map signInfo = {
        "privateKey": privateKey,
        "type": "message",
        "publicKey": store.wallet!.currentAddress,
        "message": widget.content
      };
      late Map data;
      if (widget.method == 'mina_signMessage') {
        data = await webApi.account.signMessage(
          signInfo,
          context: context,
        );
      } else if (widget.method == 'mina_signFields') {
        data = await webApi.account.signFields(
          signInfo,
          context: context,
        );
      } else if (widget.method == 'mina_createNullifier') {
        data = await webApi.account.createNullifier(
          signInfo,
          context: context,
        );
      } else {
         setState(() {
        submitting = false;
      });
        // unsupport
        UI.toast(dic.notSupportNow);
        return false;
      }
      setState(() {
        submitting = false;
      });
      widget.onConfirm!(data);
      return true;
    } else {
      UI.toast(dic.ledgerNotSupportSign);
      return false;
    }
  }

  void onCancel() {
    widget.onCancel!();
  }

  Widget _build() {
    if (widget.content is String) {
      return Text(widget.content as String,
          style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400));
    } else if (widget.content is List<Map<String, String>>) {
      List<Map<String, String>> msgParams =
          widget.content as List<Map<String, String>>;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgParams
            .map((msgParam) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        msgParam['label'] as String,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                      SizedBox(
                          height: 10), // You can adjust this space as needed
                      Text(
                        msgParam['value'] as String,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    } else if (widget.content is List<dynamic>) {
      String showContent = jsonEncode(widget.content);
      return Text(showContent,
          style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400));
    } else {
      formatStatus = false;
      return Text('Error: Unknown content type'); // if error disable confirm
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    BigInt balance =
        store.assets!.accountsInfo[store.wallet!.currentAddress]?.total ??
            BigInt.from(0);
    String networkName =
        NetworkUtil.getNetworkName(store.settings!.currentNode);
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 16),
        child: SafeArea(
          child: Stack(
            children: [
              Wrap(
                children: [
                  BrowserDialogTitleRow(
                    title: dic.signatureRequest,
                    chainId: networkName,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZkAppWebsite(icon: widget.iconUrl!, url: widget.url),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                          Fmt.accountName(store.wallet!
                                              .currentWallet.currentAccount),
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      child: Text(
                                          '${Fmt.address(store.wallet!.currentAddress, pad: 6)}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    )
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(dic.amount,
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      child: Text(
                                          Fmt.balance(balance.toString(),
                                                  COIN.decimals) +
                                              " " +
                                              COIN.coinSymbol,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    )
                                  ]),
                            ],
                          ),
                          Container(
                              height: 200,
                              margin: EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: BrowserTab(
                                tabTitles: [dic.content],
                                tabContents: [
                                  TabBorderContent(tabContent: _build())
                                ],
                              ))
                        ],
                      )),
                  ZkAppBottomButton(
                      onConfirm: onConfirm,
                      onCancel: onCancel,
                      submitting: submitting)
                ],
              ),
            ],
          ),
        ));
  }
}
