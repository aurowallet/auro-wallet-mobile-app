import 'package:auro_wallet/common/components/Separator.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/components/networkItem.dart';
import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/store/settings/types/customNodeV2.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class RemoteNodeListPage extends StatefulWidget {
  final AppStore store;
  SettingsStore settingStore;
  static final String route = '/profile/endpoint';

  RemoteNodeListPage(this.store) : settingStore = store.settings!;

  @override
  _RemoteNodeListPageState createState() => _RemoteNodeListPageState();
}

class _RemoteNodeListPageState extends State<RemoteNodeListPage> {
  final Api api = webApi;

  bool isEditing = false;

  void _addCustomNode(CustomNodeV2? originEndpoint) async {
    await Navigator.of(context).pushNamed(NodeEditPage.route, arguments: {
      "name": originEndpoint?.name,
      "address": originEndpoint?.url,
      "removeNode": originEndpoint != null ? _removeNode : null
    });
    setState(() {
      isEditing = false;
    });
  }

  void _editNode(CustomNodeV2 endpoint) async {
    this._addCustomNode(endpoint);
  }

  void _removeNode(String url) async {
    List<CustomNodeV2> endpoints =
        List<CustomNodeV2>.of(widget.settingStore.customNodeListV2);
    endpoints.removeWhere((endpointItem) => endpointItem.url == url);
    if (widget.settingStore.currentNode?.url == url) {
      await widget.settingStore
          .setCurrentNode(netConfigMap[NetworkTypes.mainnet]!);
      webApi.updateGqlClient(GRAPH_QL_MAINNET_NODE_URL);
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
        await widget.settingStore.setCurrentNode(node);
        webApi.updateGqlClient(key);
        webApi.refreshNetwork();
        Navigator.of(context).pop();
      }
    }
  }

  Widget _renderCustomNodeList(BuildContext context, bool isEditing) {
    final theme = Theme.of(context).textTheme;
    List<CustomNodeV2> endpoints =
        List<CustomNodeV2>.of(widget.settingStore.customNodeListV2);
    if (endpoints.length == 0) {
      return Container();
    }
    final networks = widget.settingStore.networks;
    List<Widget> list = endpoints.map((endpoint) {
      final filterNetworks =
          networks.where((element) => element.chainId == endpoint.chainId);
      NetworkType? networkType;
      if (filterNetworks.isNotEmpty) {
        networkType = filterNetworks.first;
      }
      final tagStr = networkType != null ? networkType.name : "Unknown";
      return Padding(
          key: Key(endpoint.url),
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: NetworkItem(
            text: endpoint.name,
            value: endpoint.url,
            chainId: endpoint.chainId,
            checked: widget.settingStore.currentNode?.url == endpoint.url,
            onChecked: onChangeEndpoint,
            tag: tagStr,
            isEditing: isEditing,
            editable: true,
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

  String? getChainIdFromStore(String id) {
    final networks = widget.settingStore.networks;
    final NetworkType? types = networks
        .map((e) => e as NetworkType?)
        .firstWhere((element) => element?.type == id, orElse: () => null);
    return types?.chainId;
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
            List<CustomNodeV2> endpoints =
                List<CustomNodeV2>.of(widget.settingStore.customNodeListV2);
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
          CustomNodeV2 mainnetConfig = netConfigMap[NetworkTypes.mainnet]!;
          CustomNodeV2 devnetConfig = netConfigMap[NetworkTypes.devnet]!;
          CustomNodeV2 berkeleyConfig = netConfigMap[NetworkTypes.berkeley]!;
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
                          text: mainnetConfig.name,
                          value: mainnetConfig.url,
                          onChecked: onChangeEndpoint,
                          checked: mainnetConfig.url ==
                              widget.settingStore.currentNode?.url,
                          tag: null,
                          chainId:
                              getChainIdFromStore(mainnetConfig.id as String),
                          isEditing: isEditing,
                          iconUrl: "assets/images/stake/icon_mina_color.png",
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
                          text: devnetConfig.name,
                          value: devnetConfig.url,
                          onChecked: onChangeEndpoint,
                          checked: devnetConfig.url ==
                              widget.settingStore.currentNode?.url,
                          tag: null,
                          chainId:
                              getChainIdFromStore(devnetConfig.id as String),
                          isEditing: isEditing,
                          iconUrl: 'assets/images/stake/icon_mina_gray.svg',
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NetworkItem(
                          text: berkeleyConfig.name,
                          value: berkeleyConfig.url,
                          onChecked: onChangeEndpoint,
                          checked: berkeleyConfig.url ==
                              widget.settingStore.currentNode?.url,
                          tag: null,
                          chainId:
                              getChainIdFromStore(berkeleyConfig.id as String),
                          isEditing: isEditing,
                          iconUrl: 'assets/images/stake/icon_mina_gray.svg',
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
