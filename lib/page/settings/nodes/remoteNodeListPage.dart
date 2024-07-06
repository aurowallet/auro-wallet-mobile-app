import 'package:auro_wallet/common/components/Separator.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/components/networkItem.dart';
import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class RemoteNodeListPage extends StatefulWidget {
  final AppStore store;
  final SettingsStore settingStore;
  static final String route = '/profile/endpoint';

  RemoteNodeListPage(this.store) : settingStore = store.settings!;

  @override
  _RemoteNodeListPageState createState() => _RemoteNodeListPageState();
}

class _RemoteNodeListPageState extends State<RemoteNodeListPage> {
  final Api api = webApi;

  bool isEditing = false;

  void _addCustomNode(CustomNode? originEndpoint) async {
    await Navigator.of(context).pushNamed(NodeEditPage.route, arguments: {
      "name": originEndpoint?.name,
      "address": originEndpoint?.url,
      "networkID": originEndpoint?.networkID,
      "removeNode": originEndpoint != null ? _removeNode : null
    });
    setState(() {
      isEditing = false;
    });
  }

  void _editNode(CustomNode endpoint) async {
    this._addCustomNode(endpoint);
  }

  void _removeNode(String url) async {
    List<CustomNode> endpoints =
        List<CustomNode>.of(widget.settingStore.customNodeList);
    endpoints.removeWhere((endpointItem) => endpointItem.url == url);
    if (widget.settingStore.currentNode?.url == url) {
      CustomNode mainnetEndpoint = defaultNetworkList
          .firstWhere((network) => network.networkID == networkIDMap.mainnet);
      await widget.settingStore.setCurrentNode(mainnetEndpoint);
      webApi.updateGqlClient(mainnetEndpoint.url);
      webApi.refreshNetwork();
    }
    widget.settingStore.setCustomNodeList(endpoints);
  }

  void onChangeEndpoint(bool checked, String key) async {
    if (checked) {
      final nodes =
          widget.settingStore.allNodes.where((element) => element.url == key);
      if (nodes.length > 0) {
        final node = nodes.first;
        await widget.store.assets!.clearAllTxs();
        widget.store.assets!.setTxsLoading(true);
        await widget.settingStore.setCurrentNode(node);
        webApi.updateGqlClient(key);
        webApi.refreshNetwork();
        Navigator.of(context).pop();
      }
    }
  }

  Widget _renderCustomNodeList(BuildContext context, bool isEditing) {
    List<CustomNode> endpoints =
        List<CustomNode>.of(widget.settingStore.customNodeList);
    if (endpoints.length == 0) {
      return Container();
    }
    List<Widget> list = endpoints.map((endpoint) {
      return Padding(
          key: Key(endpoint.url),
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: NetworkItem(
            onChecked: onChangeEndpoint,
            isEditing: isEditing,
            onEdit: _editNode,
            endpoint: endpoint,
          ));
    }).toList();
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...list],
    ));
  }

  _onEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic.network),
        centerTitle: true,
        actions: [
          Observer(builder: (_) {
            List<CustomNode> endpoints =
                List<CustomNode>.of(widget.settingStore.customNodeList);
            return endpoints.length > 0
                ? TextButton(
                    child: Text(
                      isEditing ? dic.save : dic.edit,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor),
                    ),
                    onPressed: _onEdit,
                  )
                : Container();
          })
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(builder: (_) {
          CustomNode mainnetConfig = defaultNetworkList.firstWhere(
              (network) => network.networkID == networkIDMap.mainnet);
          CustomNode devnetConfig = defaultNetworkList.firstWhere(
              (network) => network.networkID == networkIDMap.testnet);
          CustomNode zekotestnetConfig = defaultNetworkList.firstWhere(
              (network) => network.networkID == networkIDMap.zekotestnet);
          return Column(
            children: [
              Expanded(
                child: ListView(padding: EdgeInsets.only(top: 20), children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NetworkItem(
                          onChecked: onChangeEndpoint,
                          isEditing: isEditing,
                          endpoint: mainnetConfig,
                        ),
                      ],
                    ),
                  ),
                  _renderCustomNodeList(context, isEditing),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              Separator(color: ColorsUtil.hexColor(0x808080)),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(dic.testnet,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorsUtil.hexColor(0x808080),
                                  fontWeight: FontWeight.w400)),
                        ),
                        Expanded(
                          child:
                              Separator(color: ColorsUtil.hexColor(0x808080)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NetworkItem(
                          onChecked: onChangeEndpoint,
                          isEditing: isEditing,
                          endpoint: devnetConfig,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NetworkItem(
                          onChecked: onChangeEndpoint,
                          isEditing: isEditing,
                          endpoint: zekotestnetConfig,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                child: NormalButton(
                  text: dic.addNetWork,
                  onPressed: () {
                    _addCustomNode(null);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
