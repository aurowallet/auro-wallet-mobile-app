import 'dart:convert';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/browserTab.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:flutter/material.dart';

class SignatureDialog extends StatefulWidget {
  SignatureDialog({
    required this.content,
    required this.url,
    this.iconUrl,
    this.onConfirm,
    this.onCancel,
  });

  final Object content;
  final String url;
  final String? iconUrl;
  final Function()? onConfirm;
  final Function()? onCancel;

  @override
  _SignatureDialogState createState() => new _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  String currentChainId = "Mainnet";

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
    widget.onConfirm!();
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
      return Text('Error: Unknown content type'); // if error disable confirm
    }
  }

  @override
  Widget build(BuildContext context) {
    Map userInfo = {
      "accountName": "xxx",
      "address": "B62456...123456",
      "balance": "123.4321 MINA",
    };
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
                    title: "Signature Request",
                    chainId: currentChainId,
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
                                      child: Text(userInfo['accountName'],
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
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
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text("Balance",
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      child: Text(userInfo['balance'],
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
                                tabTitles: ["Content"],
                                tabContents: [
                                  TabBorderContent(tabContent: _build())
                                ],
                              ))
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
