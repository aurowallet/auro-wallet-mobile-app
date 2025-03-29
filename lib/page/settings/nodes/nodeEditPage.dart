import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/components/normalButton.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';

class NodeEditPage extends StatefulWidget {
  final AppStore store;
  static final String route = '/profile/edit_nodes';

  NodeEditPage(this.store);

  @override
  _NodeEditPageState createState() => _NodeEditPageState();
}

class _NodeEditPageState extends State<NodeEditPage> {
  final Api api = webApi;
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _addressCtrl = new TextEditingController();
  FocusNode _addressFocus = new FocusNode();
  bool addressError = false;
  bool submitDisabled = true;
  bool isEdit = false;
  bool submitting = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map args = ModalRoute.of(context)!.settings.arguments as Map;
      final initName = args['name'] as String?;
      final initAddress = args['address'] as String?;
      if (initName != null) {
        _nameCtrl.text = initName;
      }
      if (initAddress != null) {
        _addressCtrl.text = initAddress;
        setState(() {
          isEdit = true;
        });
      }
      _monitorSummitStatus();
      _addressCtrl.addListener(_monitorSummitStatus);
      _nameCtrl.addListener(_monitorSummitStatus);
      _addressFocus.addListener(() {
        if (_addressFocus.hasFocus) {
          _onAddressFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _addressCtrl.dispose();
    _nameCtrl.dispose();
  }

  void _onAddressFocus() {
    setState(() {
      errorText = '';
      addressError = false;
    });
  }

  void _monitorSummitStatus() {
    if (_addressCtrl.text.isEmpty || _nameCtrl.text.isEmpty || addressError) {
      if (!submitDisabled) {
        setState(() {
          submitDisabled = true;
        });
      }
    } else if (submitDisabled) {
      setState(() {
        submitDisabled = false;
      });
    }
  }

  void _confirm() async {
    _addressFocus.unfocus();
    AppLocalizations dic = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    if (name.length > 50 || address.length > 500) {
      UI.toast('text too long!');
      return;
    }
    final valid = await _validateAddress(address);
    if (!valid) {
      return null;
    }
    setState(() {
      submitting = true;
    });
    String? networkID = await webApi.setting.fetchNetworkId(address);

    if (networkID == null) {
      setState(() {
        errorText = dic.urlError_1;
        addressError = true;
        submitting = false;
      });
      return;
    }
    CustomNode endpoint =
        CustomNode(name: name, url: address, networkID: networkID);
    CustomNode? matchingNode;
    try {
      matchingNode = defaultNetworkList.firstWhere(
        (node) => node.networkID == endpoint.networkID,
        orElse: () => throw Exception('No matching networkID found'),
      );
    } catch (e) {
      matchingNode = null;
    }

    print("back endpoint=3 ${matchingNode.toString()}");
    if (matchingNode != null) {
      endpoint.txUrl = matchingNode.txUrl;
      endpoint.explorerUrl = matchingNode.explorerUrl;
    }
    List<CustomNode> endpoints =
        List<CustomNode>.of(widget.store.settings!.customNodeList);
    if (isEdit) {
      final Map args = ModalRoute.of(context)!.settings.arguments as Map;
      final initName = args['name'] as String;
      final initAddress = args['address'] as String;
      final initNetworkID = args['networkID'] as String;
      var originEndpoint = new CustomNode(
          name: initName, url: initAddress, networkID: initNetworkID);
      widget.store.settings!.updateCustomNode(endpoint, originEndpoint);
      if (widget.store.settings!.currentNode?.url == originEndpoint.url) {
        if (originEndpoint.url != endpoint.url ||
            originEndpoint.networkID != endpoint.networkID) {
          await widget.store.assets!.clearAssestNodeCache();
          widget.store.assets!.setAssetsLoading(true);
          await widget.store.settings!.setCurrentNode(endpoint);
          webApi.updateGqlClient(endpoint.url);
          await widget.store.assets!.loadTokenLocalConfigCache();
          await widget.store.assets!.loadTokenInfoCache();
          webApi.assets.fetchTokenInfo();
          widget.store.triggerBalanceRefresh();
          widget.store.walletConnectService?.emitChainChanged(endpoint.networkID); 
        }
      }
    } else {
      endpoints.add(endpoint);
      await widget.store.assets!.clearAssestNodeCache();
      widget.store.assets!.setAssetsLoading(true);
      await widget.store.settings!.setCurrentNode(endpoint);
      await widget.store.settings!.setCustomNodeList(endpoints);
      webApi.updateGqlClient(endpoint.url);
      await widget.store.assets!.loadTokenLocalConfigCache();
      await widget.store.assets!.loadTokenInfoCache();
      webApi.assets.fetchTokenInfo();
      widget.store.triggerBalanceRefresh();
      widget.store.walletConnectService?.emitChainChanged(endpoint.networkID); 
    }
    setState(() {
      submitting = false;
    });
    Navigator.of(context).pop();
  }

  Future<bool> _validateAddress(String address) async {
    AppLocalizations dic = AppLocalizations.of(context)!;
    var uri = Uri.tryParse(address);
    String? error;
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final originEndpoint = args['address'] as String?;
    if (uri == null || !uri.isAbsolute) {
      error = dic.urlError_1;
    }
    List<CustomNode> endpoints =
        List<CustomNode>.of(widget.store.settings!.customNodeList);
    if (endpoints.any((element) => element.url == address) ||
        defaultNetworkList.any((node) => node.url == address)) {
      if (!(isEdit && address == originEndpoint)) {
        error = dic.urlError_3;
      }
    }
    setState(() {
      errorText = error;
      addressError = error != null;
    });
    return error == null;
  }

  _onDelete() async {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final removeNode = args['removeNode'] as void Function(String);
    AppLocalizations dic = AppLocalizations.of(context)!;
    bool? rejected = await UI.showConfirmDialog(
        context: context,
        contents: [dic.confirmDeleteNode],
        okText: dic.confirm,
        cancelText: dic.cancel);
    if (rejected != true) {
      return;
    }
    removeNode(args['address'] as String);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? dic.editNetWork : dic.addNetWork),
        centerTitle: true,
        actions: isEdit
            ? [
                TextButton(
                  style: ButtonStyle(
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent)),
                  child: Text(
                    dic.delete,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD65A5A)),
                  ),
                  onPressed: _onDelete,
                )
              ]
            : [],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Expanded(
              child:
                  ListView(padding: EdgeInsets.only(top: 0), children: <Widget>[
                Container(
                  child: Text(dic.nodeAlert,
                      style: TextStyle(
                          color: Color(0xFFD65A5A),
                          fontWeight: FontWeight.w500)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Color(0x1AD65A5A),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Wrap(
                    children: [
                      InputItem(
                        padding: const EdgeInsets.only(top: 0),
                        label: dic.name,
                        controller: _nameCtrl,
                        maxLength: 50,
                      ),
                      InputItem(
                        label: dic.nodeAddress,
                        placeholder: 'https://',
                        focusNode: _addressFocus,
                        padding: EdgeInsets.only(top: 22),
                        controller: _addressCtrl,
                        maxLines: 2,
                        isError: addressError,
                      ),
                      InputErrorTip(
                        padding: EdgeInsets.only(top: 8),
                        ctrl: _addressCtrl,
                        message: errorText ?? '',
                        asyncValidate: _validateAddress,
                        keepShow: addressError,
                        isError: addressError,
                        hideIcon: true,
                        focusNode: _addressFocus,
                      ),
                    ],
                  ),
                )
              ]),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
              child: NormalButton(
                submitting: submitting,
                disabled: addressError || _nameCtrl.text.isEmpty,
                text: dic.confirm,
                onPressed: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
