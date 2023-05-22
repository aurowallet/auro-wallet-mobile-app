import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/i18n/index.dart';
import 'package:auro_wallet/utils/ledgerInit.dart';
import 'package:flutter/material.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:mobx/mobx.dart';

class LedgerStatus extends StatefulWidget {
  LedgerStatus();

  @override
  _LedgerStatusState createState() => new _LedgerStatusState();
}

class _LedgerStatusState extends State<LedgerStatus> {
  final store = globalAppStore;
  bool ledgerStatus = false;
  ReactionDisposer? _monitorFeeDisposer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitorFeeDisposer =
          reaction((_) => store.ledger!.ledgerDevice, monitorLedgerStatus);
      monitorLedgerStatus(store.ledger!.ledgerDevice);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_monitorFeeDisposer != null) {
      _monitorFeeDisposer!();
      LedgerInit.dispose();
    }
  }

  void monitorLedgerStatus(LedgerDevice? ledgerDevice) async {
    print('monitorLedgerStatus');
    if (ledgerDevice != null) {
      print('ledgerDevice not null');
      final minaApp =
          MinaLedgerApp(store.ledger!.ledgerInstance!, accountIndex: 0);
      try {
        final version = await minaApp.getVersion(ledgerDevice);
        print(version.versionName);
        setState(() {
          ledgerStatus = true;
        });
      } on LedgerException catch (e) {
        print('get version failed');
        setState(() {
          ledgerStatus = false;
        });
      }
    } else {
      print('init ledger and scan');
      LedgerInit.initAndScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).ledger;
    return Container(
      // height: 20,
      margin: EdgeInsets.only(right: 64),
      decoration: BoxDecoration(
          color: Color(0x1A000000), borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: ledgerStatus ? Color(0xFF0DB27C) : Color(0xFFD65A5A),
                borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 4,
          ),
          Text(
            dic['ledgerStatus']!,
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
          )
        ],
      ),
    );
  }
}
