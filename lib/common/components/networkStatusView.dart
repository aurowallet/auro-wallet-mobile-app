import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/page/settings/components/networkIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NetworkStatusView extends StatefulWidget {
  NetworkStatusView({
    this.chainId,
  });
  final String? chainId;

  @override
  _NetworkStatusViewState createState() => new _NetworkStatusViewState();
}

class _NetworkStatusViewState extends State<NetworkStatusView> {
  final store = globalAppStore;

  @override
  Widget build(BuildContext context) {
    CustomNode? nextEndpoint = findNodeByNetworkId(
      defaultNetworkList,
      store.settings?.customNodeList ?? [],
      widget.chainId,
    );
    if (nextEndpoint == null) {
      nextEndpoint = store.settings!.currentNode;
    }
    return Container(
        decoration: BoxDecoration(
            color: Color(0x1A000000), borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Observer(builder: (_) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              nextEndpoint != null
                  ? NetworkIcon(endpoint: nextEndpoint, size: 24)
                  : SizedBox(),
              Container(
                width: 4,
              ),
              Text(
                nextEndpoint?.name ?? "",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black),
              )
            ],
          );
        }));
  }
}
