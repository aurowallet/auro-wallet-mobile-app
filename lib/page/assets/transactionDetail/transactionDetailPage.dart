import 'dart:convert';

import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/customDivider.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/zkUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionDetailPage extends StatelessWidget {
  TransactionDetailPage(this.store);

  static final String route = '/assets/tx';
  final AppStore store;

  Widget _buildLabel(String name) {
    return Container(
        padding: EdgeInsets.only(left: 0),
        child: Text(name,
            style: TextStyle(
                color: Color(0xFF808080),
                fontWeight: FontWeight.w500,
                fontSize: 12)));
  }

  String capitalize(String s) {
    if (s.isNotEmpty && s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    }
    return s;
  }

  List<Widget> _buildListView(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    Map params = ModalRoute.of(context)!.settings.arguments as Map;
    TransferData tx = params['data'];
    String txKindLow = tx.type.toLowerCase();

    String tokenId = params['tokenId'];
    int tokenDecimal = params['tokenDecimal'];
    String tokenSymbol = params['tokenSymbol'];

    bool isMainToken = tokenId == ZK_DEFAULT_TOKEN_ID;

    final success = tx.success;
    final pending = tx.isPending;

    String symbol = isMainToken ? COIN.coinSymbol : tokenSymbol;
    int decimals = isMainToken ? COIN.decimals : tokenDecimal;
    Map? tokenTxData;

    String? showToAddress = "";
    String showAmount;
    if (!isMainToken) {
      if (txKindLow == "zkapp_token") {
        showToAddress = tx.receiver;
        showAmount = Fmt.balance(tx.amount, tokenDecimal) + " " + tokenSymbol;
        tokenTxData = {"isZkReceive": false};
      } else {
        Map txData = jsonDecode(tx.transaction!);
        List<dynamic> accountUpdates = txData['accountUpdates'];
        Map<String, dynamic> updateInfo = getZkAppUpdateInfo(accountUpdates,
            store.wallet!.currentAddress, tx.sender ?? "", tokenId);
        tokenTxData = updateInfo;
        showToAddress = updateInfo['to'];
        String amount =
            Fmt.balance(updateInfo['totalBalanceChange'], tokenDecimal);
        showAmount = amount + " " + tokenSymbol;
      }
    } else {
      if (txKindLow == "zkapp") {
        Map txData = jsonDecode(tx.transaction!);
        List<dynamic> accountUpdates = txData['accountUpdates'];
        Map<String, dynamic> updateInfo = getZkAppUpdateInfo(
          accountUpdates,
          store.wallet!.currentAddress,
          tx.sender ?? "",
          tokenId,
        );
        showToAddress = updateInfo['to'];
        showAmount =
            '${Fmt.balance(updateInfo['totalBalanceChange'], decimals)} $symbol';
      } else {
        showToAddress = tx.receiver;
        showAmount =
            '${Fmt.balance(tx.amount, decimals, minLength: 4, maxLength: decimals)} $symbol';
      }
    }
    String statusIcon;
    String statusText;
    Color statusColor;
    switch (tx.status) {
      case 'applied':
        statusText = dic.applied;
        statusColor = ColorsUtil.hexColor(0x38d79f);
        break;
      case 'failed':
        statusText = dic.failed;
        statusColor = ColorsUtil.hexColor(0xE84335);
        break;
      case 'pending':
        statusText = dic.pending;
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
      case 'signed':
        statusText = dic.signed;
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
      default:
        statusText = tx.status.toUpperCase();
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
    }

    bool isCommonTx = txKindLow != "zkapp" && txKindLow != "zkapp_token";

    String txType = tx.type;
    if (txKindLow == "stake_delegation") {
      txType = "delegation";
    }

    if (isCommonTx) {
      txType = capitalize(txType);
    }
    if (txKindLow == "zkapp_token") {
      txType = "zkApp Token";
    }
    bool isOut = tx.sender == store.wallet!.currentAddress;
    switch (txKindLow) {
      case 'delegation':
      case 'stake_delegation':
        {
          statusIcon = 'record_stake';
        }
        break;
      case "zkapp":
      case "zkapp_token":
        if (!isMainToken) {
          statusIcon = tokenTxData?['isZkReceive'] == true ? 'tx_in' : 'tx_out';
        } else {
          statusIcon = 'tx_zkapp';
        }
        break;
      default:
        {
          statusIcon = isOut ? 'record_out' : 'record_in';
        }
        break;
    }

    final items = [
      TxInfoItem(label: dic.txType, title: txType),
      TxInfoItem(label: dic.amount, title: showAmount),
      TxInfoItem(
        label: dic.toAddress,
        title: showToAddress,
        copyText: showToAddress,
      ),
      TxInfoItem(
          label: dic.fromAddress,
          title: tx.sender,
          copyText: tx.sender,
          showScamTag: tx.isFromAddressScam == true),
      TxInfoItem(label: dic.memo2, title: tx.memo, copyText: tx.memo),
      TxInfoItem(
        label: 'Nonce',
        title: tx.nonce != null ? tx.nonce.toString() : null,
      ),
      tx.fee != null
          ? TxInfoItem(
              label: dic.fee,
              title:
                  '${Fmt.balance(tx.fee!, COIN.decimals, maxLength: COIN.decimals)} ${COIN.coinSymbol}',
            )
          : null,
      TxInfoItem(
        label: dic.time,
        title: txKindLow == "zkapp_token"
            ? Fmt.dateTimeWithTimeZoneFromTimestamp(int.parse(tx.time ?? "0"))
            : Fmt.dateTimeWithTimeZone(tx.time),
      ),
      TxInfoItem(
        label: dic.txHash,
        title: tx.hash,
        copyText: tx.hash,
      ),
    ];
    var list = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                width: 48,
                height: 48,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(48.0)),
                    color: statusColor),
                child: SvgPicture.asset(
                  'assets/images/assets/$statusIcon.svg',
                  width: 48,
                  height: 48,
                  color: Colors.white,
                ),
              )),
          Text(statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          CustomDivider(margin: const EdgeInsets.only(top: 20)),
        ],
      ),
    ];
    items.forEach((i) {
      if (i == null || i.title == null || i.title!.isEmpty) {
        return;
      }
      var baseCon = Container(
          padding: EdgeInsets.only(top: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildLabel(i.label),
            CopyContainer(
              child: RichText(
                  text: TextSpan(
                text: i.title!,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                children: <WidgetSpan>[
                  WidgetSpan(
                      child: Container(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: i.showScamTag == true
                        ? ScamTag()
                        : SizedBox(
                            height: 0,
                          ),
                  ))
                ],
              )),
              text: i.copyText,
            ),
          ]));

      list.add(baseCon);
    });
    if (txKindLow == "zkapp_token" && tx.failureReason != null) {
      list.add(_buildRiskTip(context, tx));
    }
    return list;
  }

  Widget _buildRiskTip(BuildContext context, TransferData tx) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Color(0xFFD65A5A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFD65A5A), width: 1)),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/webview/icon_alert.svg',
                height: 30,
                width: 30,
              ),
              Text(dic.failed,
                  style: TextStyle(
                      color: Color(0xFFD65A5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Text(tx.failureReason ?? "",
              style: TextStyle(
                  color: Color(0xFFD65A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    Map params = ModalRoute.of(context)!.settings.arguments as Map;

    TransferData tx = params['data'];
    bool showExplorer = tx.type != "zkapp_token";
    return Scaffold(
      appBar: AppBar(
        title: Text('${dic.details}'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 30, right: 20, left: 20),
                children: _buildListView(context),
              ),
            ),
            showExplorer
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tx.hash.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30)
                                  .copyWith(bottom: 30),
                              child: BrowserLink(
                                '${store.settings!.currentNode?.explorerUrl}/tx/${tx.hash}',
                                text: dic.goToExplrer,
                              ))
                          : Container()
                    ],
                  )
                : SizedBox(
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}

class TxInfoItem {
  TxInfoItem(
      {required this.label, this.title, this.copyText, this.showScamTag});
  final String label;
  final String? title;
  final String? copyText;
  final bool? showScamTag;
}
