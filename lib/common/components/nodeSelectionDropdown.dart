import 'package:auro_wallet/common/components/customDropdownButton.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/utils/UI.dart';

class NodeSelectionDropdown extends StatefulWidget {
  NodeSelectionDropdown({required this.store});

  final SettingsStore store;

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
      await widget.store.setEndpoint(endpoint);
      webApi.updateGqlClient(endpoint);
      webApi.staking.refreshStaking();
      globalBalanceRefreshKey.currentState!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton(
        items: [
          DropdownItem(text: 'Mainnet', value: GRAPH_QL_MAINNET_NODE_URL),
          DropdownItem(text: 'Devnet', value: GRAPH_QL_TESTNET_NODE_URL),
          ...widget.store.customNodeListV2.map((e) {
            return DropdownItem(text: e.name, value: e.url);
          }).toList()
        ],
        onChoose: onChoose,
        // value: GRAPH_QL_TESTNET_NODE_URL
        value: widget.store.endpoint);
  }
}
