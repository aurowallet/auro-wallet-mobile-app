import 'package:auro_wallet/page/settings/nodes/nodeEditPage.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
    await Navigator.of(context).pushNamed(NodeEditPage.route, arguments: {
      "name": originEndpoint?.name,
      "address": originEndpoint?.url,
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
        List<CustomNode>.of(widget.store.customNodeListV2);
    endpoints.removeWhere((endpointItem) => endpointItem.url == url);
    if (widget.store.currentNode?.url == url) {
      await widget.store.setCurrentNode(mainNetNode);
      webApi.updateGqlClient(GRAPH_QL_MAINNET_NODE_URL);
      webApi.refreshNetwork();
    }
    widget.store.setCustomNodeList(endpoints);
  }

  void onChangeEndpoint(bool checked, String key) async {
    if (checked) {
      final nodes =
          widget.store.allNodes.where((element) => element.url == key);
      if (nodes.length > 0) {
        final node = nodes.first;
        await widget.store.setCurrentNode(node);
        webApi.updateGqlClient(key);
        webApi.refreshNetwork();
        Navigator.of(context).pop();
      }
    }
  }

  Widget _renderCustomNodeList(BuildContext context, bool isEditing) {
    var i18n = I18n.of(context).main;
    final theme = Theme.of(context).textTheme;
    List<CustomNode> endpoints =
        List<CustomNode>.of(widget.store.customNodeListV2);
    if (endpoints.length == 0) {
      return Container();
    }
    final networks = widget.store.networks;
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
          child: NodeItem(
            text: endpoint.name,
            value: endpoint.url,
            chainId: endpoint.chainId,
            checked: widget.store.currentNode?.url == endpoint.url,
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
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Text(i18n['customNetwork']!,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ),
        ...list
      ],
    ));
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
          Observer(builder: (_) {
            List<CustomNode> endpoints =
                List<CustomNode>.of(widget.store.customNodeListV2);
            return endpoints.length > 0
                ? TextButton(
                    child: Text(
                      isEditing ? i18n['save']! : i18n['edit']!,
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
          final networks = widget.store.networks;
          final NetworkType? mainnet = networks
              .map((e) => e as NetworkType?)
              .firstWhere((element) => element?.type == '0',
                  orElse: () => null);
          final NetworkType? testnet = networks
              .map((e) => e as NetworkType?)
              .firstWhere((element) => element?.type == '1',
                  orElse: () => null);

          return Column(
            children: [
              Expanded(
                child: ListView(padding: EdgeInsets.only(top: 20), children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      i18n['defaultNetwork']!,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NodeItem(
                          margin: EdgeInsets.only(top: 10),
                          text: 'Mainnet',
                          value: GRAPH_QL_MAINNET_NODE_URL,
                          onChecked: onChangeEndpoint,
                          checked: GRAPH_QL_MAINNET_NODE_URL ==
                              widget.store.currentNode?.url,
                          tag: null,
                          chainId: mainnet?.chainId,
                          isEditing: isEditing,
                        ),
                        NodeItem(
                          margin: EdgeInsets.only(top: 10),
                          text: 'Devnet',
                          value: GRAPH_QL_TESTNET_NODE_URL,
                          onChecked: onChangeEndpoint,
                          checked: GRAPH_QL_TESTNET_NODE_URL ==
                              widget.store.currentNode?.url,
                          tag: null,
                          chainId: testnet?.chainId,
                          isEditing: isEditing,
                        )
                      ],
                    ),
                  ),
                  _renderCustomNodeList(context, isEditing),
                ]),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
                child: NormalButton(
                  text: I18n.of(context).settings['addNetWork']!,
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

class NodeItem extends StatelessWidget {
  NodeItem({
    this.checked = false,
    required this.text,
    required this.value,
    required this.onChecked,
    required this.tag,
    required this.isEditing,
    this.chainId,
    this.editable = false,
    this.onEdit,
    this.endpoint,
    this.margin = const EdgeInsets.only(top: 0),
  });

  final bool checked;
  final bool isEditing;
  final bool editable;
  final String text;
  final String? chainId;
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
    return Padding(
      padding: margin,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Color(0xFFF9FAFC),
          child: InkWell(
              onTap: onPressed,
              child: Container(
                  padding: EdgeInsets.all(16).copyWith(bottom: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.05), width: 1)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                      child: Text(Fmt.breakWord(text)!,
                                          // overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  ColorsUtil.hexColor(0x01000D),
                                              fontWeight: FontWeight.w500))),
                                  tag != null
                                      ? Container(
                                          margin: EdgeInsets.only(left: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                ColorsUtil.hexColor(0xDDDDDD),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(tag!,
                                              style: theme.headline6!.copyWith(
                                                  color: Color(0x4D000000),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        )
                                      : Container()
                                ],
                              )),
                              chainId != null
                                  ? Container(
                                      margin: EdgeInsets.only(left: 5),
                                      alignment: Alignment.center,
                                      child: Text(
                                          Fmt.address(chainId,
                                              pad: 6, padSame: true),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              fontWeight: FontWeight.w400)),
                                    )
                                  : Container()
                            ],
                          ),
                          Text(Fmt.breakWord(value)!,
                              style: theme.headline5!.copyWith(
                                  color: ColorsUtil.hexColor(0x999999),
                                  fontSize: 12)),
                        ],
                      )),
                      isEditing
                          ? Container(
                              width: 32,
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 6,
                                margin: EdgeInsets.only(
                                  left: 14,
                                ),
                                child: editable
                                    ? SvgPicture.asset(
                                        'assets/images/assets/right_arrow.svg',
                                        width: 6,
                                        height: 12)
                                    : Container(),
                              ))
                          : Container(
                              width: 32,
                              child: Center(
                                child: checked
                                    ? Padding(
                                        padding: EdgeInsets.only(left: 14),
                                        child: RoundCheckBox(
                                          size: 18,
                                          borderColor: Colors.transparent,
                                          isChecked: checked,
                                          uncheckedColor: Colors.white,
                                          checkedColor:
                                              Theme.of(context).primaryColor,
                                          checkedWidget: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
                                          onTap: (bool? checkedFlag) {
                                            onChecked(checkedFlag!, value);
                                          },
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                    ],
                  ))),
        ),
      ),
    );
  }
}
