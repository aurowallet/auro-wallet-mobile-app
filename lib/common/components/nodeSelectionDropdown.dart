import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/outlinedButtonSmall.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:mobx/mobx.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/common/components/nodeSelectionDialog.dart';

class NodeSelectionDropdown extends StatefulWidget {
  NodeSelectionDropdown({required this.store});
  final SettingsStore store;
  @override
  _NodeSelectionDropdownState createState() => _NodeSelectionDropdownState();
}

class _NodeSelectionDropdownState extends State<NodeSelectionDropdown> {
  bool netSelectionVisibility = false;
  String? netName;
  ReactionDisposer? _monitorFeeDisposer;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
  void _onToggle() async {
    setState(() {
      netSelectionVisibility = !netSelectionVisibility;
    });
    CustomNode? endpoint = await showModalBottomSheet<CustomNode?>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled:true,
        builder: (BuildContext context) {
          return NodeSelectionDialog(
              onSelectNode: (node){
                Navigator.of(context).pop(node);
              },
              settingsStore: widget.store
          );
        }
    );
    setState(() {
      netSelectionVisibility = !netSelectionVisibility;
    });
    if (endpoint != null && endpoint.url != widget.store.endpoint) {
      await widget.store.setEndpoint(endpoint.url);
      webApi.updateGqlClient(endpoint.url);
      webApi.staking.refreshStaking();
      globalBalanceRefreshKey.currentState!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButtonSmall(
        color: Colors.transparent,
        borderColor: Colors.white,
        padding: EdgeInsets.fromLTRB(18, 4, 12, 4),
        active: true,
        onPressed: _onToggle,
        radius: 30,
        content: Fmt.breakWord(netName) ?? "",
        shadowColor: Colors.transparent,
        suffixIcon: Icon(
          !netSelectionVisibility ? Icons.keyboard_arrow_down_sharp : Icons.keyboard_arrow_up_sharp, color: Colors.white,
        )
    );
  }
}