import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/page/settings/Dev/TransactionPage.dart';
import 'package:auro_wallet/page/settings/Dev/constants.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class DevPage extends StatefulWidget {
  DevPage(this.store);
  static final String route = '/setting/devpage';
  final AppStore store;
  @override
  _DevState createState() => _DevState(store);
}

class _DevState extends State<DevPage> {
  _DevState(this.store);

  final AppStore store;

  Widget _renderDevEntryList(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.only(left: 16, right: 10),
      child: Column(
        children: [
          DevItem(
              title: dic.history,
              onTap: () => Navigator.of(context).pushNamed(
                    TransactionPage.route,
                    arguments: {
                      "type": DevPageTypes.transaction,
                      "title": dic.history,
                    },
                  )),
          DevItem(
            title: dic.pendingTx,
            onTap: () => Navigator.of(context).pushNamed(
              TransactionPage.route,
              arguments: {
                "type": DevPageTypes.pendingTx,
                "title": dic.pendingTx,
              },
            ),
          ),
          DevItem(
            title: "zkApp-" + dic.pendingTx,
            onTap: () => Navigator.of(context).pushNamed(
              TransactionPage.route,
              arguments: {
                "type": DevPageTypes.pendingZkTx,
                "title": "zkApp-" + dic.pendingTx,
              },
            ),
          ),
          DevItem(
            title: dic.tokens,
            onTap: () => Navigator.of(context).pushNamed(
              TransactionPage.route,
              arguments: {
                "type": DevPageTypes.balance,
                "title": dic.tokens,
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auro Dev"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Observer(
        builder: (_) {
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Container(
                padding: EdgeInsets.only(top: 20),
                child: _renderDevEntryList(context)),
          );
        },
      ),
    );
  }
}

class DevItem extends StatelessWidget {
  DevItem({required this.title, required this.onTap, this.value});

  final String title;
  final String? value;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          value != null
              ? Text(
                  value!,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0x4D000000)),
                )
              : Container(),
          Container(
            width: 30,
            height: 30,
            child: Center(
              child: Icon(Icons.arrow_forward_ios, size: 18),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
