import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/copyContainer.dart';
import 'package:auro_wallet/common/components/customDivider.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
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
    final TransferData tx =
        ModalRoute.of(context)!.settings.arguments as TransferData;
    final success = tx.success;
    final pending = tx.isPending;

    final String symbol = COIN.coinSymbol;
    final int decimals = COIN.decimals;

    String statusIcon;
    String statusText;
    Color statusColor;
    if (pending) {
      statusColor = ColorsUtil.hexColor(0xFFC633);
      statusText = dic.pending;
    } else if (success == true) {
      statusColor = ColorsUtil.hexColor(0x38d79f);
      statusText = dic.applied;
    } else {
      statusColor = ColorsUtil.hexColor(0xE84335);
      statusText = dic.failed;
    }

    String typeCamelCase = tx.type.toLowerCase();
    bool isCommonTx = typeCamelCase != "zkapp";

    String txType = tx.type;
    if (typeCamelCase == "stake_delegation") {
      txType = "delegation";
    }

    if (isCommonTx) {
      txType = capitalize(txType);
    }
    bool isOut = tx.sender == store.wallet!.currentAddress;
    switch (tx.type.toLowerCase()) {
      case 'delegation':
      case 'stake_delegation':
        {
          statusIcon = 'record_stake';
        }
        break;
      case "zkapp":
        {
          statusIcon = 'record_zkapp';
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
      TxInfoItem(
        label: dic.amount,
        title:
            '${Fmt.balance(tx.amount, decimals, minLength: 4, maxLength: decimals)} $symbol',
      ),
      TxInfoItem(
          label: dic.fromAddress,
          title: tx.sender,
          copyText: tx.sender,
          showScamTag: tx.isFromAddressScam == true),
      TxInfoItem(
        label: dic.toAddress,
        title: tx.receiver,
        copyText: tx.receiver,
      ),
      TxInfoItem(label: dic.memo2, title: tx.memo, copyText: tx.memo),
      TxInfoItem(
        label: dic.time,
        title: Fmt.dateTimeWithTimeZone(tx.time),
      ),
      TxInfoItem(
        label: 'Nonce',
        title: tx.nonce != null ? tx.nonce.toString() : null,
      ),
      tx.fee != null
          ? TxInfoItem(
              label: dic.fee,
              title:
                  '${Fmt.balance(tx.fee!, decimals, maxLength: decimals)} $symbol',
            )
          : null,
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
    return list;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    final TransferData tx =
        ModalRoute.of(context)!.settings.arguments as TransferData;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tx.hash.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30)
                            .copyWith(bottom: 30),
                        child: BrowserLink(
                          '${!store.settings!.isMainnet ? TESTNET_TRANSACTIONS_EXPLORER_URL : MAINNET_TRANSACTIONS_EXPLORER_URL}/tx/${tx.hash}',
                          text: dic.goToExplrer,
                        ))
                    : Container()
              ],
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
