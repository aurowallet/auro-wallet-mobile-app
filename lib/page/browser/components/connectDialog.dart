import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class ConnectDialog extends StatefulWidget {
  ConnectDialog({
    required this.url,
    this.iconUrl,
    this.onConfirm,
    this.onCancel,
  });

  final String url;
  final Function()? onConfirm;
  final Function()? onCancel;
  final String? iconUrl;

  @override
  _ConnectDialogState createState() => new _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  @override
  void initState() {
    super.initState();
  }

  void onConfirm() {
    print(' ConnectDialog  onConfirm');
    widget.onConfirm!();
  }

  void onCancel() {
    print(' ConnectDialog  onCancel');
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
                  BrowserDialogTitleRow(title: "Connection Request"),
                  Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZkAppWebsite(icon: widget.iconUrl!, url: widget.url),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                                "This website would like to view account:",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontWeight: FontWeight.w400)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text("Account 1 (B62456...123456)",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                                "* Make sure you only connect to trusted sites.",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontWeight: FontWeight.w400)),
                          ),
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
