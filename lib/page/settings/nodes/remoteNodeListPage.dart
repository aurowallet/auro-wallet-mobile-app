import 'package:auro_wallet/common/components/customNodeDialog.dart';
import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  bool isEditing = false;
  void _addCustomNode(CustomNode? originEndpoint) async {
    var i18n = I18n.of(context).main;
    var isEdit = originEndpoint != null;
    var nodeInputs = await Navigator.of(context).pushNamed(NodeEditPage.route, arguments: {
      "name": originEndpoint?.name, "address": originEndpoint?.url });
    var inputs = nodeInputs as List<String>?;
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
  Widget _renderCustomNodeList(BuildContext context, bool isEditing) {
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
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: NodeItem(
            text: endpoint.name,
            value: endpoint.url,
            checked: widget.store.endpoint == endpoint.url,
            onChecked: onChangeEndpoint,
            tag: tagStr,
            isEditing: isEditing,
            editable: true,
            onEdit: _editNode,
            endpoint: endpoint,
          )
      );
    })
        .toList();
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Text(i18n['customNetwork']!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666))),
            ),
            ...list
          ],
        )
    );
  }
  _onEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n['networkConfig']!),
        centerTitle: true,
        actions: [
          TextButton(
            child: Text(isEditing ? i18n['save']! :i18n['edit']!, style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor
            ),),
            onPressed: _onEdit,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Observer(
            builder: (_){
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                        padding: EdgeInsets.only(top: 8),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(i18n['defaultNetwork']!, style: theme.headline5!.copyWith(color: ColorsUtil.hexColor(0x666666))),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NodeItem(
                                  margin: EdgeInsets.only(top: 10),
                                  text: 'Mainnet',
                                  value: GRAPH_QL_MAINNET_NODE_URL,
                                  onChecked: onChangeEndpoint,
                                  checked: GRAPH_QL_MAINNET_NODE_URL == widget.store.endpoint,
                                  tag: null,
                                  isEditing: isEditing,
                                ),
                                NodeItem(
                                  margin: EdgeInsets.only(top: 10),
                                  text: 'Devnet',
                                  value: GRAPH_QL_TESTNET_NODE_URL,
                                  onChecked: onChangeEndpoint,
                                  checked: GRAPH_QL_TESTNET_NODE_URL == widget.store.endpoint,
                                  tag: null,
                                  isEditing: isEditing,
                                )
                              ],
                            ),
                          ),
                          _renderCustomNodeList(context, isEditing),
                        ]
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                    child: NormalButton(
                      text: I18n.of(context).settings['addNetWork']!,
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
        required this.isEditing,
        this.editable = false,
        this.onEdit,
        this.endpoint,
        this.margin = const EdgeInsets.only(top: 0),
      });
  final bool checked;
  final bool isEditing;
  final bool editable;
  final String text;
  final String value;
  final String? tag;
  final CustomNode? endpoint;
  final void Function(bool, String) onChecked;
  final void Function(CustomNode)? onEdit;
  final EdgeInsetsGeometry margin;
  onPressed() {
    if (isEditing && onEdit != null && endpoint != null) {
      onEdit!(endpoint!);
    } else {
      onChecked(!checked, value);
    }
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Container(
        margin: margin,
        child:ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF9FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5),
              minimumSize: Size(60, 32),
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.all(16).copyWith(bottom: 12),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Column(
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
                    )
                ),
                isEditing && editable ? Container(
                    width: 6,
                    margin: EdgeInsets.only(left: 14,),
                    child: SvgPicture.asset(
                        'assets/images/assets/right_arrow.svg',
                        width: 6,
                        height: 12
                    )
                ): Container(),
                checked && !isEditing ? Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: RoundCheckBox(
                    size: 18,
                    borderColor: Colors.transparent,
                    isChecked: checked,
                    uncheckedColor: Colors.white,
                    checkedColor: Theme.of(context).primaryColor,
                    checkedWidget: Icon(Icons.check, color: Colors.white, size: 12,),
                    // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
                    onTap: (bool? checkedFlag) {
                      onChecked(checkedFlag!, value);
                    },
                  ),) : Container()
              ],
            )
        ));
  }
}