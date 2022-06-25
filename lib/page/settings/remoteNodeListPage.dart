import 'package:auro_wallet/common/components/customNodeDialog.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/components/customPromptDialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RemoteNodeListPage extends StatefulWidget {
  final SettingsStore store;
  static final String route = '/profile/endpoint';
  RemoteNodeListPage(this.store);
  @override
  _RemoteNodeListPageState createState() => _RemoteNodeListPageState();
}

class _RemoteNodeListPageState extends State<RemoteNodeListPage> {

  final Api api = webApi;

  void _addCustomNode(CustomNode? originEndpoint) async {
    var i18n = I18n.of(context).main;
    var isEdit = originEndpoint != null;
    List<String>? inputs = await showDialog<List<String>>(
      context: context,
      builder: (_) {
        return CustomNodeDialog(
            name: isEdit ? originEndpoint.name : '',
            url: isEdit ? originEndpoint.url : '',
            onOk:(String? name, String? url) {
              if (name == null || name.isEmpty
                  || url == null || url.isEmpty
              ) {
                UI.toast(i18n['urlError_1']!);
                return false;
              }
              return true;
            }
        );
      },
    );
    if (inputs == null) {
      return null;
    }
    String name = inputs[0].trim();
    String url = inputs[1].trim();
    if (name.length > 50 || url.length > 500) {
      UI.toast('text too long!');
      return;
    }
    CustomNode endpoint = CustomNode(name: name, url: url);
    var uri = Uri.tryParse(endpoint.url);
    if (uri == null || !uri.isAbsolute) {
      UI.toast(i18n['urlError_1']!);
      return;
    }
    List<CustomNode> endpoints = List<CustomNode>.of(widget.store.customNodeListV2);
    if (endpoints.any((element) => element.url == endpoint.url)
        || GRAPH_QL_MAINNET_NODE_URL == endpoint.url
        || GRAPH_QL_TESTNET_NODE_URL == endpoint.url
    ) {
      if (!(isEdit && endpoint.url == originEndpoint.url)) {
        UI.toast(i18n['urlError_3']!);
        return;
      }
    }

    EasyLoading.show(status: '');
    String? chainId = await webApi.setting.fetchChainId(endpoint.url);
    if(chainId == null) {
      UI.toast(i18n['urlError_1']!);
      EasyLoading.dismiss();
      return;
    }
    endpoint.chainId = chainId;
    List<NetworkType> fetchNetworkTypes = await webApi.setting.fetchNetworkTypes();
    final targetNetworks = fetchNetworkTypes.where((element) => element.chainId == endpoint.chainId);

    // only support mainnet and testnet
    if (targetNetworks.isEmpty || (targetNetworks.first.type != '0' && targetNetworks.first.type != '1')) {
      UI.toast(i18n['urlError_1']!);
      EasyLoading.dismiss();
      return;
    }
    endpoint.networksType = targetNetworks.first.type;
    if (isEdit) {
      widget.store.updateCustomNode(endpoint, originEndpoint);
      if (widget.store.endpoint == originEndpoint.url) {
        if (originEndpoint.url != endpoint.url
            || originEndpoint.chainId != endpoint.chainId
        ) {
          await widget.store.setEndpoint(endpoint.url);
          webApi.updateGqlClient(endpoint.url);
          webApi.refreshNetwork();
        }
      }
    } else {
      endpoints.add(endpoint);
      await widget.store.setEndpoint(endpoint.url);
      await widget.store.setCustomNodeList(endpoints);
      webApi.updateGqlClient(endpoint.url);
      webApi.refreshNetwork();
    }
    EasyLoading.dismiss();
  }
  void _editNode(CustomNode endpoint) async {
    this._addCustomNode(endpoint);
  }
  void _removeNode (CustomNode endpoint) async {
    var i18n = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      i18n['confirmDeleteNode']!
    ], okText: i18n['confirm']!, cancelText: i18n['cancel']!);
    if (rejected != true) {
      return;
    }
    List<CustomNode> endpoints = List<CustomNode>.of(widget.store.customNodeListV2);
    endpoints.removeWhere((endpointItem)=> endpointItem.url == endpoint.url);
    if(widget.store.endpoint == endpoint.url) {
      await widget.store.setEndpoint(GRAPH_QL_MAINNET_NODE_URL);
      webApi.updateGqlClient(GRAPH_QL_MAINNET_NODE_URL);
      webApi.refreshNetwork();
    }
    widget.store.setCustomNodeList(endpoints);
  }
  void onChangeEndpoint (bool checked, String key) async {
    if (checked) {
      await widget.store.setEndpoint(key);
      webApi.updateGqlClient(key);
      webApi.refreshNetwork();
    }
  }
  Widget _renderCustomNodeList(BuildContext context) {
    var i18n = I18n.of(context).main;
    final theme = Theme.of(context).textTheme;
    List<CustomNode> endpoints = List<CustomNode>.of(widget.store.customNodeListV2);
    if (endpoints.length == 0) {
      return Container();
    }
    final networks = widget.store.networks;
    List<Widget> list = endpoints.map((endpoint) {
      final filterNetworks = networks.where((element) => element.chainId == endpoint.chainId);
      NetworkType? networkType;
      if (filterNetworks.isNotEmpty) {
        networkType = filterNetworks.first;
      }
      final tagStr = networkType != null ? networkType.name : "Unknown";
      return Padding(
        key: Key(endpoint.url),
        padding: EdgeInsets.only(top: 10),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30,),
              child: NodeItem(
                text: endpoint.name,
                value: endpoint.url,
                checked: widget.store.endpoint == endpoint.url,
                onChecked: onChangeEndpoint,
                tag: tagStr,
              ),
          ),
          secondaryActions: <Widget>[
            SlideAction(
              // color: Colors.transparent,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                color: ColorsUtil.hexColor(0x59c49c),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white,),
                    Text(
                      i18n['edit']!,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              onTap: () {
                _editNode(endpoint);
              },
            ),
            IconSlideAction(
              caption: i18n['delete']!,
              color: ColorsUtil.hexColor(0xF95051),
              icon: Icons.delete,
              onTap: () {
                _removeNode(endpoint);
              },
            ),
          ],
        ),
      );
    })
        .toList();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 20),
            child: Text(i18n['customNetwork']!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666))),
          ),
          ...list
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n['networkConfig']!),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(
          builder: (_){
            return Column(
              children: [
                Expanded(
                  child: ListView(padding: EdgeInsets.only(top: 8),
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(i18n['defaultNetwork']!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666))),
                              NodeItem(
                                margin: EdgeInsets.only(top: 10),
                                text: 'Mainnet',
                                value: GRAPH_QL_MAINNET_NODE_URL,
                                onChecked: onChangeEndpoint,
                                checked: GRAPH_QL_MAINNET_NODE_URL == widget.store.endpoint,
                                tag: null,
                              ),
                              NodeItem(
                                margin: EdgeInsets.only(top: 10),
                                text: 'Devnet',
                                value: GRAPH_QL_TESTNET_NODE_URL,
                                onChecked: onChangeEndpoint,
                                checked: GRAPH_QL_TESTNET_NODE_URL == widget.store.endpoint,
                                tag: null,
                              )
                            ],
                          ),
                        ),
                        _renderCustomNodeList(context),
                      ]
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: NormalButton(
                    text: I18n.of(context).main['addNetWork']!,
                    onPressed: () {
                      _addCustomNode(null);
                    },
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class NodeItem extends StatelessWidget {
  NodeItem(
      {
        this.checked = false,
        required this.text,
        required this.value,
        required this.onChecked,
        required this.tag,
        this.margin = const EdgeInsets.only(top: 0),
      });
  final bool checked;
  final String text;
  final String value;
  final String? tag;
  final void Function(bool, String) onChecked;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return FormPanel(
        margin: margin,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    flex:1,
                    child: Text(Fmt.breakWord(text)!,
                      overflow: TextOverflow.ellipsis,
                      style: theme.headline4!.copyWith(color: ColorsUtil.hexColor(0x01000D), fontWeight: FontWeight.w500)),
                  ),
                  tag != null ? Container(
                    margin: EdgeInsets.only(left: 5),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: ColorsUtil.hexColor(0xDDDDDD),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(tag!, style: theme.headline6!.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                  ) : Container()
                ],
              ),
              Text(Fmt.breakWord(value)!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x999999))),
            ],
          ),
          trailing: RoundCheckBox(
            size: 30,
            borderColor: ColorsUtil.hexColor(0xcccccc),
            isChecked: checked,
            uncheckedColor: Colors.white,
            checkedColor: ColorsUtil.hexColor(0x59c49c),
            // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
            onTap: (bool? checkedFlag) {
              onChecked(checkedFlag!, value);
            },
          ),
          onTap: () => onChecked(!checked, value),
        )
    );
  }
}