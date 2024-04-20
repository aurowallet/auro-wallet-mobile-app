import 'package:auro_wallet/page/settings/components/networkIcon.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NetworkStatusView extends StatefulWidget {
  NetworkStatusView();

  @override
  _NetworkStatusViewState createState() => new _NetworkStatusViewState();
}

class _NetworkStatusViewState extends State<NetworkStatusView> {
  final store = globalAppStore;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Color(0x1A000000), borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Observer(builder: (_) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NetworkIcon(endpoint: store.settings!.currentNode!, size: 24),
              Container(
                width: 4,
              ),
              Text(
                store.settings!.currentNode!.name,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black),
              )
            ],
          );
        }));
  }
}
