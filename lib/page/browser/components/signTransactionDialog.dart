import 'package:auro_wallet/common/components/TxAction/txAdvanceDialog.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/browserTab.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SignTxDialogType { Payment, Delegation, zkApp }

class SignTransactionDialog extends StatefulWidget {
  SignTransactionDialog({
    required this.signType,
    required this.to,
    this.amount,
    this.fee,
    this.memo,
    this.transaction,
    this.onConfirm,
    this.onCancel,
  });

  final SignTxDialogType signType;
  final String to;
  final String? amount;
  final String? fee;
  final String? memo;
  final Object? transaction;

  final Function()? onConfirm;
  final Function()? onCancel;

  @override
  _SignTransactionDialogState createState() =>
      new _SignTransactionDialogState();
}

class _SignTransactionDialogState extends State<SignTransactionDialog> {
  bool isRiskAddress = true;
  bool showRawDataStatus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onConfirm() {
    print('onConfirm');
    // if error disable confirm
  }

  void onCancel() {}

  Widget _buildAccountRow() {
    Map userInfo = {
      "accountName": "Zhangsan",
      "address": "B62456...123456",
      "balance": "123.4321 MINA",
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            child: Text(userInfo['accountName'],
                style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(userInfo['address'],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          )
        ]),
        SvgPicture.asset(
          'assets/images/assets/right_arrow.svg',
          height: 14,
          color: Color(0xFF594AF1),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                    margin: EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF594AF1), width: 1)),
                    child: Text(widget.signType.name,
                        style: TextStyle(
                            color: Color(0xFF594AF1),
                            fontSize: 10,
                            fontWeight: FontWeight.w500))),
                Text("To",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(widget.to,
                style: TextStyle(
                    color: isRiskAddress ? Colors.black : Color(0xFFD65A5A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          )
        ]),
      ],
    );
  }

  Widget _buildAmountRow() {
    return widget.amount != null
        ? Container(
            margin: EdgeInsets.only(top: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                child: Text("Amount",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(widget.amount! + " MINA",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              )
            ]),
          )
        : Container();
  }

  void showAdvanceDialog() async {
    String? nextFee = await showDialog<String>(
      context: context,
      builder: (_) {
        return TxAdvanceDialog(
          currentNonce: 0,
          nextStateFee: 0.01,
        );
      },
    );
    // if (nextFee!.isNotEmpty) {
    // nextStateFee = double.parse(nextFee);
    // }
  }

  Widget _buildFeeRow() {
    bool showDefault = true;
    bool showFeeHighTip = false;
    String showFee;
    if (widget.fee != null) {
      showFee = widget.fee!;
      showDefault = false;
      showFeeHighTip = true; // need check
    } else {
      showFee = "0.001";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  child: Text("Transaction Fee",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text(showFee + " MINA",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      showDefault
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                  color: Color(0xFF808080).withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3))),
                              child: Text('Default',
                                  style: TextStyle(
                                      color: Color(0xFF808080).withOpacity(0.5),
                                      fontSize: 12,
                                      height: 1.25,
                                      fontWeight: FontWeight.w500)),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                  color: Color(0xFF0DB27C).withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3))),
                              child: Text('Site suggested',
                                  style: TextStyle(
                                      color: Color(0xFF0DB27C),
                                      fontSize: 12,
                                      height: 1.25,
                                      fontWeight: FontWeight.w500)),
                            )
                    ],
                  ),
                )
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                    onTap: () => showAdvanceDialog(),
                    child: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Text("Advanced",
                          style: TextStyle(
                              color: Color(0xFF594AF1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ))
              ]),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text('Fees are much higher than average',
              style: TextStyle(
                  color: Color(0xFFE4B200),
                  fontSize: 12,
                  fontWeight: FontWeight.w400)),
        )
      ],
    );
  }

  Widget _buildMemoContent() {
    return Text(widget.memo!,
        style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400));
  }

  Widget _buildZkTransactionContent() {
    if (showRawDataStatus) {
      return Text('sourceData',
          style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400));
    } else {
      return Text('showData',
          style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400));
    }
  }

  void onClickRawData() {
    print('onClickRawData');
    setState(() {
      showRawDataStatus = !showRawDataStatus;
    });
  }

  Widget _buildTabRow() {
    List<String> tabTitleList = [];
    List<Widget> tabContengList = [];
    Widget? tabRightWidget;

    if (widget.transaction != null) {
      tabTitleList.add('Content');
      tabContengList
          .add(TabBorderContent(tabContent: _buildZkTransactionContent()));
      if (widget.signType == SignTxDialogType.zkApp) {
        String showContent = showRawDataStatus ? "Raw data</>" : "Show data ";
        tabRightWidget = GestureDetector(
          child: Container(
            padding: EdgeInsets.only(bottom: 5, top: 5, left: 5),
            child: Text(
              showContent,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF808080)),
            ),
          ),
          onTap: onClickRawData,
        );
      }
    }

    if (widget.memo != null) {
      tabTitleList.add('Memo');
      tabContengList.add(TabBorderContent(tabContent: _buildMemoContent()));
    }
    return Container(
        height: 200,
        margin: EdgeInsets.only(top: 20),
        width: double.infinity,
        child: BrowserTab(
            tabTitles: tabTitleList,
            tabContents: tabContengList,
            tabRightWidget: tabRightWidget));
  }

  Widget _buildRiskTip() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 20),
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
              SizedBox(
                width: 10,
              ),
              Text("WARNING",
                  style: TextStyle(
                      color: Color(0xFFD65A5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Text(
              'You are interacting with an address or contract that has been flagged as scam. If you sign, you could lose access to all of your NFTs and any funds or other assets in your wallet.',
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
    double screenHeight = MediaQuery.of(context).size.height;
    // Calculate 80% of the screen height
    double containerMaxHeight = screenHeight * 0.6;
    double minHeight = 200;
    if (containerMaxHeight <= minHeight) {
      containerMaxHeight = containerMaxHeight + 50;
    }

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
                    title: "Transaction Request",
                    chainId: "Mainnet",
                  ),
                  Container(
                      constraints: BoxConstraints(
                          minHeight: minHeight, maxHeight: containerMaxHeight),
                      child: SingleChildScrollView(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isRiskAddress ? _buildRiskTip() : Container(),
                                  ZkAppWebsite(
                                      icon:
                                          "https://test-zkapp.aurowallet.com/imgs/auro.png",
                                      url:
                                          "https://aurowallet.github.io/auro-test-dapp/https://aurowallet.github.io/auro-test-dapp/"),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  _buildAccountRow(),
                                  _buildAmountRow(),
                                  _buildFeeRow(),
                                  _buildTabRow()
                                ],
                              )))),
                  ZkAppBottomButton(
                    onConfirm: onConfirm,
                    onCancel: onCancel,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
