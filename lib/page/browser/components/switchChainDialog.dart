import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchChainDialog extends StatefulWidget {
  SwitchChainDialog({
    required this.chainId,
    required this.url,
    this.iconUrl,
    this.onConfirm,
    this.onCancel,
  });

  final String chainId;
  final String url;
  final String? iconUrl;
  final Function()? onConfirm;
  final Function()? onCancel;

  @override
  _SwitchChainDialogState createState() => new _SwitchChainDialogState();
}

class _SwitchChainDialogState extends State<SwitchChainDialog> {
  String currentChainId = "currentChainId";

  @override
  void initState() {
    super.initState();
  }

  void onConfirm() {
    print(' SwitchChainDialog  onConfirm');
    widget.onConfirm!();
  }

  void onCancel() {
    print(' SwitchChainDialog  onCancel');
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
                  BrowserDialogTitleRow(title: "Switch Network"),
                  Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZkAppWebsite(icon: widget.iconUrl!, url: widget.url),
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text(
                                "Allow this site to switch the network?",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ColorsUtil.hexColor(0x808080),
                                    fontWeight: FontWeight.w400)),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ChainItem(
                                    title: "Current",
                                    chainId: currentChainId,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start),
                                SvgPicture.asset(
                                  'assets/images/assets/right_arrow.svg',
                                  height: 14,
                                  color: Color(0xFF594AF1),
                                ),
                                ChainItem(
                                    title: "Target",
                                    chainId: widget.chainId,
                                    crossAxisAlignment: CrossAxisAlignment.end),
                              ])
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

class ChainItem extends StatelessWidget {
  ChainItem({
    required this.title,
    required this.chainId,
    required this.crossAxisAlignment,
  });

  final String chainId;
  final String title;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: ColorsUtil.hexColor(0x808080),
                  fontWeight: FontWeight.w400)),
          SizedBox(width: 4),
          Text(chainId,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
