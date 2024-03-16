import 'package:auro_wallet/browser/components/browserBaseUi.dart';
import 'package:auro_wallet/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class AddChainDialog extends StatefulWidget {
  AddChainDialog({
    required this.nodeUrl,
    required this.nodeName,
    this.onConfirm,
    this.onCancel,
  });

  final String nodeUrl;
  final String nodeName;
  final Function()? onConfirm;
  final Function()? onCancel;

  @override
  _AddChainDialogState createState() => new _AddChainDialogState();
}

class _AddChainDialogState extends State<AddChainDialog> {
  @override
  void initState() {
    super.initState();
  }


  void onConfirm() {
    widget.onConfirm!();
  }

  void onCancel() {
    widget.onCancel!();
  }

  @override
  Widget build(BuildContext context) {
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
                  BrowserDialogTitleRow(title: "Add Network"),
                  Container(
                    color: Color(0xFFD65A5A).withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                        "Only add nodes that you trust. Using unknown nodes can be risky.",
                        style: TextStyle(
                            fontSize: 14,
                            color: ColorsUtil.hexColor(0xD65A5A),
                            fontWeight: FontWeight.w400)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZkAppWebsite(
                              icon:
                                  "https://test-zkapp.aurowallet.com/imgs/auro.png",
                              url:
                                  "https://aurowallet.github.io/auro-test-dapp/https://aurowallet.github.io/auro-test-dapp/"),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text("Allow this site to add a network?",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontWeight: FontWeight.w400)),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1),
                                    width: 0.5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text("Name",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.8),
                                          fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text(widget.nodeName,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.8),
                                          fontWeight: FontWeight.w400)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text("Node URL",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.8),
                                          fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  child: Text(widget.nodeUrl,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.8),
                                          fontWeight: FontWeight.w400)),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
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
