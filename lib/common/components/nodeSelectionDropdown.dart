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
  String? netName;
  ReactionDisposer? _monitorFeeDisposer;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitorFeeDisposer = reaction((_) =>  widget.store.endpoint, this._setNetName);
    });
    netName = _getName(null);
    super.initState();
  }
  _setNetName (String? endpoint) {
    setState(() {
      netName = _getName(endpoint);
    });
  }
  @override
  void dispose() {
    if (_monitorFeeDisposer != null) {
      _monitorFeeDisposer!();
    }
    super.dispose();
  }

  String _getName(String? endpoint) {
    var currentEndpoint = endpoint ?? widget.store.endpoint;
    if (currentEndpoint == GRAPH_QL_MAINNET_NODE_URL) {
      return 'Mainnet';
    }
    if (currentEndpoint == GRAPH_QL_TESTNET_NODE_URL) {
      return 'Devnet';
    }
    try {
      var res =  widget.store.customNodeListV2.firstWhere((element) => element.url == currentEndpoint);
      return res.name;
    } catch (e) {
      return 'unknown';
    }
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
    return CustomDropdownButton(items: [
      DropdownItem(text: 'Mainnet', key: GRAPH_QL_MAINNET_NODE_URL),
      DropdownItem(text: 'Devnet', key: GRAPH_QL_TESTNET_NODE_URL),
      ...widget.store.customNodeListV2.map((e) {
        return DropdownItem(text: e.name, key: e.url);
      }).toList()
    ], onChoose: onChoose, value: widget.store.endpoint);
  }
}