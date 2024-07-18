import 'package:auro_wallet/common/components/TxAction/TxActionRow.dart';
import 'package:auro_wallet/common/components/browserLink.dart';
import 'package:auro_wallet/common/components/homeListTip.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';
import 'package:auro_wallet/common/components/scamTag.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/assets/transactionDetail/transactionDetailPage.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/accountInfo.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/utils/zkUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TxListView extends StatefulWidget {
  TxListView(this.store,
      {this.isInModal,
      required this.txList,
      required this.isLoading,
      required this.tokenId,
      required this.tokenDecimal,
      required this.tokenSymbol});

  final bool? isInModal;
  final AppStore store;
  final List<TransferData> txList;
  final bool isLoading;
  final String tokenId;
  final int tokenDecimal;
  final String tokenSymbol;

  @override
  _TxListViewState createState() => _TxListViewState(store, isInModal);
}

class _TxListViewState extends State<TxListView> with WidgetsBindingObserver {
  _TxListViewState(this.store, this.isInModal);
  final bool? isInModal;
  final AppStore store;

  Widget _buildTxList(List<TransferData> txs,BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    String currentAddress = store.wallet!.currentAddress;
    List<Widget> res = [];

    res.addAll(txs.map((i) {
      return TransferListItem(
        store: store,
        data: i,
        currentAddress: currentAddress,
        tokenId: widget.tokenId,
        tokenDecimal: widget.tokenDecimal,
        tokenSymbol: widget.tokenSymbol,
      );
    }));
    String? browserLink = store.settings!.currentNode?.explorerUrl;
    res.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: BrowserLink(
              '$browserLink/account/$currentAddress/txs',
              text: dic.goToExplorer,
            ))
      ],
    ));
    return Ink(
        color: Color(0xFFFFFFFF),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 0),
          children: res,
        ));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;

    Widget nextWidget = SizedBox(
      height: 0,
    );
    String currentAddress = store.wallet!.currentAddress;

    if (widget.isLoading) {
      if (widget.txList.length > 0) {
        nextWidget = _buildTxList(widget.txList,context);
      } else {
        nextWidget = Ink(
            color: Color(0xFFFFFFFF),
            child: Container(
              child: Center(
                child: LoadingCircle(),
              ),
            ));
      }
    } else {
      if (widget.txList.length > 0) {
        nextWidget = _buildTxList(widget.txList,context);
      } else {
        Token mainTokenNetInfo = store.assets!.mainTokenNetInfo;
        bool isAccountExist = int.parse(mainTokenNetInfo.tokenAssestInfo?.inferredNonce??"-1") >= 0; 
        if (isAccountExist) {
          nextWidget = HomeListTip();
        } else {
          nextWidget = Wrap(
            children: [EmptyTxListTip()],
          );
        }
      }
    }

    return Expanded(
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          margin: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  bottom: BorderSide(
                color: Colors.black.withOpacity(0.1),
                width: 0.5,
              ))),
          child: Text(
            dic.history,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              letterSpacing: -0.3,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(child: nextWidget)
      ]),
    );
  }
}

class TransferListItem extends StatelessWidget {
  TransferListItem(
      {required this.store,
      required this.data,
      required this.tokenId,
      required this.currentAddress,
      required this.tokenSymbol,
      required this.tokenDecimal});

  final AppStore store;
  final TransferData data;
  final String tokenId;
  final String currentAddress;
  final int tokenDecimal;
  final String tokenSymbol;

  void _viewRecordDetail(BuildContext context) {
    Navigator.pushNamed(context, TransactionDetailPage.route, arguments: {
      "data": data,
      "tokenId": tokenId,
      "tokenDecimal": tokenDecimal,
      "tokenSymbol": tokenSymbol
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOut = data.sender == currentAddress;
    bool isMainToken = tokenId == ZK_DEFAULT_TOKEN_ID;
    Map? tokenTxData;
    if (!isMainToken) {
      tokenTxData =
          getTokenZkTxItemInfo(data, tokenId, tokenDecimal, currentAddress);
    }

    String? address;
    String showAmount = "";

    if (!isMainToken) {
      address = tokenTxData?['showAddress'];
      showAmount = (tokenTxData?['isZkReceive'] == true ? '-' : '+') +
          tokenTxData?['amount'];
    } else {
      address = isOut ? data.receiver : data.sender;
      showAmount =
          (isOut ? '-' : '+') + Fmt.balance(data.amount, COIN.decimals);
    }

    String title = '';
    if (address == null) {
      title = data.type.toUpperCase();
    } else {
      title = Fmt.address(address, pad: 8);
    }
    var theme = Theme.of(context).textTheme;
    AppLocalizations dic = AppLocalizations.of(context)!;
    String icon = '';
    Color statusColor;
    switch (data.type.toLowerCase()) {
      case 'delegation':
      case 'stake_delegation':
        {
          icon = 'tx_stake';
        }
        break;
      case "zkapp":
        if (!isMainToken) {
          icon = tokenTxData?['isZkReceive'] == true ? 'tx_in' : 'tx_out';
        } else {
          icon = 'tx_zkapp';
        }
        break;
      default:
        {
          icon = isOut ? 'tx_out' : 'tx_in';
        }
        break;
    }
    String statusText;
    switch (data.status) {
      case 'applied':
        statusText = dic.applied;
        break;
      case 'failed':
        statusText = dic.failed;
        break;
      case 'pending':
        statusText = dic.pending;
        break;
      default:
        statusText = data.status.toUpperCase();
        break;
    }
    switch (data.status) {
      case 'applied':
        statusColor = ColorsUtil.hexColor(0x00C89C);
        break;
      case 'failed':
        statusColor = ColorsUtil.hexColor(0xE84335);
        break;
      default:
        statusColor = ColorsUtil.hexColor(0xFFC633);
        break;
    }
    Color bgColor =
        data.status != 'pending' ? Colors.transparent : Color(0xFFF9FAFC);

    return new Material(
      color: bgColor,
      child: InkWell(
          onTap: () {
            _viewRecordDetail(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                  width: 0.5,
                ))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 28,
                            margin: EdgeInsets.only(right: 8),
                            child: SvgPicture.asset(
                              'assets/images/assets/$icon.svg',
                              width: 28,
                            )),
                        Expanded(
                          flex: 1,
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$title',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                      data.isFromAddressScam == true
                                          ? ScamTag()
                                          : SizedBox(height: 0),
                                    ]),
                                Text(
                                  '$showAmount',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(top: 4)),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data.isPending
                                        ? 'Nonce ' + data.nonce.toString()
                                        : Fmt.dateTimeFromUTC(data.time),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: ColorsUtil.hexColor(0x96969A)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 5),
                                    child: Center(
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: statusColor),
                                      ),
                                    ),
                                  ),
                                ]),
                          ]),
                        )
                      ],
                    ),
                    data.status == 'pending'
                        ? Container(
                            margin: EdgeInsets.only(left: 36),
                            child: Column(children: [
                              Padding(padding: EdgeInsets.only(top: 6)),
                              TxActionRow(store: store, data: data)
                            ]))
                        : Container()
                  ],
                )),
          )),
    );
  }
}
