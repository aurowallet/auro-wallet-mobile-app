import 'package:auro_wallet/common/components/inputErrorTip.dart';
import 'package:auro_wallet/common/components/inputItem.dart';
import 'package:auro_wallet/common/consts/apiConfig.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/store/settings/types/networkType.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/settings/settings.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/common/components/normalButton.dart';

class NodeEditPage extends StatefulWidget {
  final SettingsStore store;
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
      final Map args =
      ModalRoute.of(context)!.settings.arguments as Map;
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
    });
  }
  @override
  void dispose() {
    super.dispose();
    _addressCtrl.dispose();
    _nameCtrl.dispose();
  }

  void _monitorSummitStatus() {
    if (_addressCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      if (!submitDisabled) {
        setState((){
          submitDisabled = true;
        });
      }
    } else if(submitDisabled) {
      setState((){
        submitDisabled = false;
      });
    }
  }

  void _confirm() async {
    _addressFocus.unfocus();
    var i18n = I18n.of(context).main;
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
    CustomNode endpoint = CustomNode(name: name, url: address);
    setState(() {
      submitting = true;
    });
    String? chainId = await webApi.setting.fetchChainId(endpoint.url);
    if(chainId == null) {
      UI.toast(i18n['urlError_1']!);
      setState(() {
        submitting = false;
      });
      return;
    }
    endpoint.chainId = chainId;
    List<NetworkType> fetchNetworkTypes = await webApi.setting.fetchNetworkTypes();
    final targetNetworks = fetchNetworkTypes.where((element) => element.chainId == endpoint.chainId);

    // only support mainnet and testnet
    if (targetNetworks.isEmpty || (targetNetworks.first.type != '0' && targetNetworks.first.type != '1')) {
      UI.toast(i18n['urlError_1']!);
      setState(() {
        submitting = false;
      });
      return;
    }
    endpoint.networksType = targetNetworks.first.type;
    List<CustomNode> endpoints = List<CustomNode>.of(widget.store.customNodeListV2);
    if (isEdit) {
      final Map args =
      ModalRoute.of(context)!.settings.arguments as Map;
      final initName = args['name'] as String;
      final initAddress = args['address'] as String;
      var originEndpoint = new CustomNode(name: initName, url: initAddress);
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
    setState(() {
      submitting = false;
    });
    Navigator.of(context).pop();
  }

  Future<bool> _validateAddress(String address) async {
    var i18n = I18n.of(context).main;
    var uri = Uri.tryParse(address);
    String? error;
    final Map args =
    ModalRoute.of(context)!.settings.arguments as Map;
    final originEndpoint = args['address'] as String?;
    if (uri == null || !uri.isAbsolute) {
      error = i18n['urlError_1']!;
    }
    List<CustomNode> endpoints = List<CustomNode>.of(widget.store.customNodeListV2);
    if (endpoints.any((element) => element.url == address)
        || GRAPH_QL_MAINNET_NODE_URL == address
        || GRAPH_QL_TESTNET_NODE_URL == address
    ) {
      if (!(isEdit && address == originEndpoint)) {
        error = i18n['urlError_3']!;
      }
    }
    setState(() {
      errorText = error;
      addressError = error != null;
    });
    return error == null;
  }
  _onDelete() async {
    final Map args =
    ModalRoute.of(context)!.settings.arguments as Map;
    final removeNode = args['removeNode'] as void Function(String);
    var i18n = I18n.of(context).main;
    bool? rejected = await UI.showConfirmDialog(context: context, contents: [
      i18n['confirmDeleteNode']!
    ], okText: i18n['confirm']!, cancelText: i18n['cancel']!);
    if (rejected != true) {
      return;
    }
    removeNode(args['address'] as String);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var i18n = I18n.of(context).main;
    var i18nSettings = I18n.of(context).settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? i18nSettings['editNetWork']! : i18nSettings['addNetWork']!),
        centerTitle: true,
        actions: isEdit ? [
          TextButton(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent)
            ),
            child: Text(i18n['delete']!, style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD65A5A)
            ),),
            onPressed: _onDelete,
          )
        ] : [],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  children: <Widget>[
                    Container(
                      child: Text(i18nSettings['nodeAlert']!,
                          style: TextStyle(
                              color: Color(0xFFD65A5A),
                              fontWeight: FontWeight.w500
                          )
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Color(0x1AD65A5A),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: Wrap(
                        children: [
                          InputItem(
                            padding: const EdgeInsets.only(top: 0),
                            label: i18n['networkName']!,
                            controller: _nameCtrl,
                            maxLength: 8,
                          ),
                          InputItem(
                            label: i18nSettings['nodeAddress'],
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
                            keepShow: false,
                            hideIcon: true,
                            focusNode: _addressFocus,
                          ),
                        ],
                      ),)
                  ]
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 38, right: 38, top: 12, bottom: 30),
              child: NormalButton(
                submitting: submitting,
                disabled: addressError || _nameCtrl.text.isEmpty,
                text: I18n.of(context).main['confirm']!,
                onPressed: _confirm ,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

