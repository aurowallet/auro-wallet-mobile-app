import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/browser/components/browserBaseUI.dart';
import 'package:auro_wallet/page/settings/components/networkItem.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:auro_wallet/utils/colorsUtil.dart';
import 'package:flutter/material.dart';

class NetworkSelectionDialog extends StatefulWidget {
  NetworkSelectionDialog();

  @override
  _NetworkSelectionDialogState createState() =>
      new _NetworkSelectionDialogState();
}

class _NetworkSelectionDialogState extends State<NetworkSelectionDialog> {
  final store = globalAppStore;
  bool _isCheck = false;
  List<CustomNode> topList = [];

  @override
  void initState() {
    super.initState();
    initShowList();
    initTestnetStatus();
  }

  void initTestnetStatus() async {
    setState(() {
      _isCheck = store.settings!.testnetShowStatus;
    });
  }

  void initShowList() {
    List<CustomNode> topListTemp = [];
    CustomNode mainnetConfig = defaultNetworkList
        .firstWhere((network) => network.networkID == networkIDMap.mainnet);
    topListTemp.add(mainnetConfig);
    topListTemp.addAll(store.settings!.customNodeList);
    setState(() {
      topList = topListTemp;
    });
  }

  void _changed(isCheck) {
    setState(() {
      _isCheck = isCheck;
    });
    store.settings!.setTestnetShowStatus(isCheck);
  }

  void onSelectNode(bool checkStatus, String checkedUrl) async { 
    if (checkStatus) {
      final nodes = store.settings!.allNodes
          .where((element) => element.url == checkedUrl); 
      if (nodes.length > 0) {
        final node = nodes.first;
        await store.assets!.clearAssestNodeCache();
        store.assets!.setAssetsLoading(true);
        await store.settings!.setCurrentNode(node); 
        webApi.updateGqlClient(checkedUrl);
        webApi.staking.refreshStaking();
        await store.assets!.loadTokenLocalConfigCache();
        await store.assets!.loadTokenInfoCache();
        webApi.assets.fetchTokenInfo();
        globalBalanceRefreshKey.currentState?.show();
        store.walletConnectService?.emitChainChanged(node.networkID); 
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    double height = MediaQuery.of(context).size.height;

    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            )),
        padding: EdgeInsets.only(top: 2, bottom: 16),
        child: SafeArea(
          child: Wrap(
            children: [
              BrowserDialogTitleRow(
                title: dic.network,
                showCloseIcon: true,
              ),
              Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                  constraints: BoxConstraints(
                    maxHeight: height * 0.3,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: topList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NetworkItem(
                        endpoint: topList[index],
                        onChecked: onSelectNode,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 10),
                  )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(dic.showTestnet,
                          style: TextStyle(
                              fontSize: 14,
                              color: ColorsUtil.hexColor(0x808080),
                              fontWeight: FontWeight.w400)),
                    ),
                    Switch(
                      value: _isCheck,
                      onChanged: _changed,
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: Color(0xFF594AF1),
                      inactiveTrackColor: Color(0xFFE9E9E9),
                    ),
                  ],
                ),
              ),
              _isCheck
                  ? Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Column(children: [
                        NetworkItem(
                          endpoint: defaultNetworkList.firstWhere((network) =>
                              network.networkID == networkIDMap.testnet),
                          onChecked: onSelectNode,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        NetworkItem(
                          endpoint: defaultNetworkList.firstWhere((network) =>
                              network.networkID ==
                              networkIDMap.zekotestnet),
                          onChecked: onSelectNode,
                        )
                      ]),
                    )
                  : Container()
            ],
          ),
        ));
  }
}
