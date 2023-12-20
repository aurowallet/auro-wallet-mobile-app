import 'package:auro_wallet/common/components/customDropdownButton.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/utils/UI.dart';

class NodeSelectionDropdown extends StatefulWidget {
  NodeSelectionDropdown({required this.store});

  final AppStore store;

  @override
  _NodeSelectionDropdownState createState() => _NodeSelectionDropdownState();
}

class _NodeSelectionDropdownState extends State<NodeSelectionDropdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onChoose(String? endpoint) async {
    if (endpoint != null) {
      final nodes = widget.store.settings!.allNodes
          .where((element) => element.url == endpoint);
      if (nodes.length > 0) {
        final node = nodes.first;
        await widget.store.assets!.clearAllTxs();
        widget.store.assets!.setTxsLoading(true);
        await widget.store.settings!.setCurrentNode(node);
        webApi.updateGqlClient(endpoint);
        webApi.staking.refreshStaking();
        globalBalanceRefreshKey.currentState!.show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
        items: [
          DropdownItem(text: 'Mainnet', value: mainNetNode.url),
          ...widget.store.settings!.customNodeListV2.map((e) {
            return DropdownItem(
                text: Fmt.stringSlice(e.name, 8, withEllipsis: true),
                value: e.url);
          }).toList(),
          DropdownItem(text: "", value: "networkDivider"),
          DropdownItem(text: 'Devnet', value: devNetNode.url),
        ],
        onChoose: onChoose,
        // value: GRAPH_QL_TESTNET_NODE_URL
        value: widget.store.settings!.currentNode!.url);
  }
}
