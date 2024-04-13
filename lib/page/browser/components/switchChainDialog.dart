import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/browser/components/zkAppBottomButton.dart';
import 'package:auro_wallet/page/browser/components/zkAppWebsite.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwitchChainDialog extends StatefulWidget {
  SwitchChainDialog({
    required this.chainId,
    required this.url,
    required this.onConfirm,
    this.iconUrl,
    this.onCancel,
    this.gqlUrl,
  });

  final String chainId;
  final String url;
  final String? iconUrl;
  final Function(String, String) onConfirm;
  final Function()? onCancel;
  final String? gqlUrl;

  @override
  _SwitchChainDialogState createState() => new _SwitchChainDialogState();
}

class _SwitchChainDialogState extends State<SwitchChainDialog> {
  AppStore store = globalAppStore;
  late CustomNodeV2 showNode;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    setNextChainConfig();
  }

  CustomNodeV2 setNextChainConfig() {
    bool changeByUrl = widget.gqlUrl != null;
    CustomNodeV2 nextNode;
    dynamic nodes = store.settings!.allNodes.where((element) {
      if (!changeByUrl) {
        return element.netType!.name == widget.chainId.toLowerCase();
      } else {
        return element.url.toLowerCase() == widget.gqlUrl?.toLowerCase();
      }
    });
    final defaultNodes =
        nodes.where((element) => element.isDefaultNode == true);
    if (changeByUrl) {
      nextNode = nodes.first;
    } else {
      nextNode = defaultNodes.length > 0 ? defaultNodes.first : nodes.first;
    }
    setState(() {
      showNode = nextNode;
    });
    return nextNode;
  }

  void onConfirm() async {
    setState(() {
      submitting = true;
    });
    bool changeByUrl = widget.gqlUrl != null;

    print(' ConnectDialog  onConfirm');
    store.settings!.allNodes.where((element) {
      if (!changeByUrl) {
        return element.netType!.name == widget.chainId.toLowerCase();
      } else {
        return element.url.toLowerCase() == widget.gqlUrl?.toLowerCase();
      }
    });

    await store.assets!.clearAllTxs();
    store.assets!.setTxsLoading(true);
    await store.settings!.setCurrentNode(showNode);
    webApi.updateGqlClient(showNode.url);
    webApi.staking.refreshStaking();
    globalBalanceRefreshKey.currentState?.show();

    String networkName = showNode.name;
    String chainId = showNode.netType!.name;

    widget.onConfirm(networkName, chainId);
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
                  BrowserDialogTitleRow(title: dic.switchNetwork),
                  Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZkAppWebsite(icon: widget.iconUrl, url: widget.url),
                          Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              child: Observer(builder: (_) {
                                return Text(dic.allowSwitch,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: ColorsUtil.hexColor(0x808080),
                                        fontWeight: FontWeight.w400));
                              })),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ChainItem(
                                    title: dic.current,
                                    chainId: store.settings!.currentNode
                                        ?.netType!.name as String,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start),
                                SvgPicture.asset(
                                  'assets/images/assets/right_arrow.svg',
                                  height: 14,
                                  color: Color(0xFF594AF1),
                                ),
                                ChainItem(
                                    title: dic.target,
                                    chainId:
                                        showNode?.netType!.name.toLowerCase() ??
                                            "",
                                    crossAxisAlignment: CrossAxisAlignment.end),
                              ])
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
