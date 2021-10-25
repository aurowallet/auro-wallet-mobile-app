import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
enum TxItemTypes {
  address,
  amount,
  text
}
class TxItem {
  TxItem({required this.label,required this.value, this.type});
  final String label;
  final String value;
  final TxItemTypes? type;
}
class NodeSelectionDialog extends StatelessWidget {
  NodeSelectionDialog({
    required this.onSelectNode,
    required this.settingsStore,
  });

  final Function(CustomNode node) onSelectNode;
  final SettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n
        .of(context)
        .main;

    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )
            ),
            padding: EdgeInsets.only(left: 28, top: 22, right: 28, bottom: 16),
            child: SafeArea(
              child: Wrap(
                children: [
                  Center(child: Text(dic['network']!, style: TextStyle(
                    color: ColorsUtil.hexColor(0x090909),
                    fontSize: 20,
                    fontFamily: "PingFangSC-Medium",
                  )),),
                  Container(height: 5,),
                  NodeItem(
                    // noMargin: true,
                    onSelectNode: onSelectNode,
                    data: CustomNode(
                      name: 'Mainnet',
                      url: GRAPH_QL_MAINNET_NODE_URL,
                    ),
                  ),
                  NodeItem(
                    onSelectNode: onSelectNode,
                    data: CustomNode(
                      name: 'Testnet',
                      url: GRAPH_QL_TESTNET_NODE_URL,
                    ),
                  ),
                  ...settingsStore.customNodeListV2.map((e) {
                    return NodeItem(data: e, onSelectNode: onSelectNode,);
                  }).toList(),
                ],
              ),
            )
        ),
        Positioned(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.cancel, color: Colors.grey,),
            onTap: () => Navigator.pop(context),
          ),
          top: 22,
          right: 10,
        ),
      ],
    );
  }
}

class NodeItem extends StatelessWidget {
  NodeItem({required this.data, required this.onSelectNode, this.noMargin = false});
  final CustomNode data;
  final Function(CustomNode node) onSelectNode;
  bool noMargin;
  void _onClick() {
    onSelectNode(data);
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Padding(
      padding: noMargin ? EdgeInsets.zero : EdgeInsets.only(top: 15),
      child:  GestureDetector(
        onTap: _onClick,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
            // border: Border.all(color: Colors.grey),
            boxShadow: [
              BoxShadow(
                color: ColorsUtil.hexColor(0x252275, alpha: 0.1),
                blurRadius: 30.0, // has the effect of softening the shadow
                spreadRadius: 0, // has the effect of extending the shadow
                offset: Offset(
                  0, // horizontal, move right 10
                  12.0, // vertical, move down 10
                ),
              )
            ],
          ),
          child: Center(
            child: Text(data.name, style: theme.headline4!,),
          ),
        ),
      )
    );
  }
}