import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class AddChainDialog extends StatefulWidget {
  AddChainDialog({
    required this.nodeUrl,
    required this.nodeName,
    required this.url,
    required this.onConfirm,
    this.iconUrl,
    this.onCancel,
  });

  final String nodeUrl;
  final String nodeName;
  final String url;
  final String? iconUrl;
  final Function() onConfirm;
  final Function()? onCancel;

  @override
  _AddChainDialogState createState() => new _AddChainDialogState();
}

class _AddChainDialogState extends State<AddChainDialog> {
  AppStore store = globalAppStore;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
  }

  void _confirm() async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final name = widget.nodeName;
    final address = widget.nodeUrl;
    setState(() {
      submitting = true;
    });
    String? networkID = await webApi.setting.fetchNetworkId(widget.nodeUrl);

    if (networkID == null) {
      setState(() {
        submitting = false;
      });
      UI.toast(dic.urlError_1);
      return;
    }
    CustomNode endpoint =
        CustomNode(name: name, url: address, networkID: networkID);
    List<CustomNode> endpoints =
        List<CustomNode>.of(store.settings!.customNodeList);
    CustomNode? matchingNode;
    try {
      matchingNode = defaultNetworkList.firstWhere(
        (node) => node.networkID == endpoint.networkID,
        orElse: () => throw Exception('No matching networkID found'),
      );
    } catch (e) {
      matchingNode = null;
    }
    if (matchingNode != null) {
      endpoint.txUrl = matchingNode.txUrl;
      endpoint.explorerUrl = matchingNode.explorerUrl;
    }
    endpoints.add(endpoint);
    await store.settings!.setCustomNodeList(endpoints);
    setState(() {
      submitting = false;
    });
    widget.onConfirm();
  }

  void onConfirm() {
    _confirm();
  }

  void onCancel() {
    final onCancel = widget.onCancel;
    if (onCancel != null) {
      onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
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
                  BrowserDialogTitleRow(title: dic.addNetWork),
                  Container(
                    color: Color(0xFFD65A5A).withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: EdgeInsets.only(top: 20),
                    child: Text(dic.nodeAlert,
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
                          ZkAppWebsite(icon: widget.iconUrl, url: widget.url),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(dic.allowSiteAddNode,
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
                                    color: Colors.black.withValues(alpha: 0.1),
                                    width: 0.5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text(dic.name,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text(widget.nodeName,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w400)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text(dic.nodeAddress,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  child: Text(widget.nodeUrl,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withValues(alpha: 0.8),
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
                    submitting: submitting,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
