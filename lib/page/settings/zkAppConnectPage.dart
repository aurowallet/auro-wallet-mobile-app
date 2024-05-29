import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ZkAppConnectPage extends StatefulWidget {
  final AppStore store;
  static final String route = '/profile/zkAppConnect';
  ZkAppConnectPage(this.store);
  @override
  _ZkAppConnectPageState createState() => _ZkAppConnectPageState();
}

class _ZkAppConnectPageState extends State<ZkAppConnectPage> {
  final Api api = webApi;

  Widget _renderEmpty() {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/setting/empty_contact.svg',
          width: 100,
          height: 100,
        ),
        Text(
          dic.noConnectedApps,
          style: TextStyle(
              color: Colors.black.withOpacity(0.3),
              fontSize: 12,
              fontWeight: FontWeight.w400),
        )
      ],
    ));
  }

  Widget _renderConnectList(BuildContext context) {
    List<String> zkAppConnectList =
        widget.store.browser?.zkAppConnectingList ?? [];
    if (zkAppConnectList.length == 0) {
      return this._renderEmpty();
    }
    return ListView.separated(
        itemCount: zkAppConnectList.length,
        separatorBuilder: (BuildContext context, int index) => Container(
              color: Colors.black.withOpacity(0.1),
              height: 0.5,
              margin: EdgeInsets.symmetric(vertical: 0),
            ),
        itemBuilder: (BuildContext context, int index) {
          final zkAppItem = zkAppConnectList[index];
          return Padding(
            key: Key(zkAppItem),
            padding: EdgeInsets.zero,
            child: ZkAppConnectItem(
              url: zkAppItem,
              store: widget.store,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.appConnection),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Observer(builder: (_) {
          return Column(
            children: [
              Expanded(
                child: _renderConnectList(context),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ZkAppConnectItem extends StatelessWidget {
  ZkAppConnectItem({
    required this.url,
    required this.store,
  });
  final String url;
  final AppStore store;

  void _onClick() async {
    await store.browser?.removeZkAppConnect(store.wallet!.currentAddress, url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(url,
                    softWrap: true,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600))),
            InkWell(
              onTap: _onClick,
              child: SvgPicture.asset(
                'assets/images/setting/icon_delete.svg',
              ),
            )
          ],
        ));
  }
}
