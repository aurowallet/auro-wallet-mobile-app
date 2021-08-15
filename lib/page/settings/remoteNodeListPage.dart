import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/formPanel.dart';
import 'package:circular_check_box/circular_check_box.dart';
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
  final Function changeEndpoint;
  RemoteNodeListPage(this.store, this.changeEndpoint);
  @override
  _RemoteNodeListPageState createState() => _RemoteNodeListPageState();
}

class _RemoteNodeListPageState extends State<RemoteNodeListPage> {

  final Api api = webApi;

  void _addCustomNode() async {
    var i18n = I18n.of(context).main;
    String? endpoint = await showDialog<String>(
      context: context,
      builder: (_) {
        return CustomPromptDialog(
            title: i18n['addNetWork']!,
            placeholder: 'https://',
            onOk:(String? text) {
              if (text == null || text.isEmpty) {
                UI.toast(i18n['urlError_1']!);
                return false;
              }
              return true;
            }
        );
      },
    );
    if (endpoint == null || endpoint.isEmpty) {
      return;
    }
    endpoint = endpoint.trim();
    var uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.isAbsolute) {
      UI.toast(i18n['urlError_1']!);
      return;
    }
    EasyLoading.show(status: '');
    bool isValid = await webApi.setting.validateGraphqlEndpoint(endpoint);
    if(!isValid) {
      UI.toast(i18n['urlError_1']!);
      EasyLoading.show(status: '');
      return;
    }
    List<String> endpoints = List<String>.of(widget.store.customNodeList);
    endpoints.add(endpoint);
    widget.store.setEndpoint(endpoint);
    widget.store.setCustomNodeList(endpoints);
    EasyLoading.dismiss();
  }
  void _removeNode (String endpoint) async {
    var i18n = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      i18n['confirmDeleteNode']!
    ], okText: i18n['confirm']!, cancelText: i18n['cancel']!);
    if (rejected != true) {
      return;
    }
    List<String> endpoints = List<String>.of(widget.store.customNodeList);
    endpoints.remove(endpoint);
    if(widget.store.endpoint == endpoint) {
      widget.store.setEndpoint(GRAPTH_QL_NODE_URL);
    }
    widget.store.setCustomNodeList(endpoints);
  }
  void onChangeEndpoint (bool checked, String key) {
    if (checked) {
      widget.store.setEndpoint(key);
      widget.changeEndpoint(key);
    }
  }
  Widget _renderCustomNodeList(BuildContext context) {
    var i18n = I18n.of(context).main;
    List<String> endpoints = List<String>.of(widget.store.customNodeList);
    if (endpoints.length == 0) {
      return Container();
    }
    List<Widget> list = endpoints
        .map((endpoint) {
      return Padding(
        key: Key(endpoint),
        padding: EdgeInsets.only(top: 10),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30,),
              child: NodeItem(
                text: endpoint,
                value: endpoint,
                checked: widget.store.endpoint == endpoint,
                onChecked: onChangeEndpoint,
              ),
          ),
          secondaryActions: <Widget>[
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
            child: Text(i18n['customNetwork']!, style: TextStyle(color: ColorsUtil.hexColor(0x666666), fontSize: 16)),
          ),
          ...list
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;

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
                              Text(i18n['defaultNetwork']!, style: TextStyle(color: ColorsUtil.hexColor(0x666666), fontSize: 16)),
                              NodeItem(
                                margin: EdgeInsets.only(top: 10),
                                text: GRAPTH_QL_NODE_URL,
                                value: GRAPTH_QL_NODE_URL,
                                onChecked: onChangeEndpoint,
                                checked: GRAPTH_QL_NODE_URL == widget.store.endpoint,
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
                    onPressed: _addCustomNode,
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
        this.margin = const EdgeInsets.only(top: 0),
      });
  final bool checked;
  final String text;
  final String value;
  final void Function(bool, String) onChecked;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return FormPanel(
        margin: margin,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: null,
          title: Text(text, style: TextStyle(color: ColorsUtil.hexColor(0x01000D), fontWeight: FontWeight.w500)),
          trailing: CircularCheckBox(
            value: checked,
            checkColor: Colors.white,
            activeColor: ColorsUtil.hexColor(0x59c49c),
            // inactiveColor: ColorsUtil.hexColor(0xCCCCCC),
            onChanged: (bool? checkedFlag) {
              onChecked(checkedFlag!, value);
            },
          ),
          onTap: () => onChecked(!checked, value),
        )
    );
  }
}