import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/utils/ledgerInit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
  bool isScaning = false;

  // ReactionDisposer? _monitorDeviceDisposer;
  // ReactionDisposer? _statusTriggerDisposer;
  // StreamSubscription<ConnectionStateUpdate>? _deviceStateChangesDisposer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.ledger!.setLedgerStatus(LedgerStatusTypes.unknown);
      // _statusTriggerDisposer =
      //     reaction((_) => store.ledger!.ledgerStatusTrigger, (trigger) {
      //   monitorLedgerStatus(store.ledger!.ledgerDevice);
      // });
      // _monitorDeviceDisposer =
      //     reaction((_) => store.ledger!.ledgerDevice, monitorLedgerStatus);
      monitorLedgerStatus(store.ledger!.ledgerDevice);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // if (_statusTriggerDisposer != null) {
    //   _statusTriggerDisposer!();
    // }
    // _deviceStateChangesDisposer?.cancel();
  }

  // onScanSuccess(LedgerDevice device) async {
  //   if (!mounted) {
  //     return;
  //   }
  //   print('start connect in leger init');
  //   await store.ledger!.ledgerInstance?.connect(device);
  //   print('finish connect in leger init');
  //   if (store.ledger?.ledgerInstance != null) {
  //     print('set ledger device in ledger status');
  //     store.ledger?.setDevice(device);
  //     monitorLedgerStatus(device);
  //   }
  // }

  Future<void> monitorLedgerStatus(LedgerDevice? ledgerDevice) async {
    print('monitorLedgerStatus');
    if (!mounted) {
      return;
    }
    if (ledgerDevice != null) {
      print('ledgerDevice not null');
      final minaApp =
          MinaLedgerApp(store.ledger!.ledgerInstance!, accountIndex: 0);
      try {
        await minaApp.getVersion(ledgerDevice);
        // print(version.versionName);
        setState(() {
          ledgerStatus = true;
        });
      } on LedgerException catch (e) {
        print('get version failed');
        print(e.errorCode);
        setState(() {
          ledgerStatus = false;
        });
        // await Future.delayed(Duration(seconds: 2));
        // if (store.ledger!.ledgerDevice != null) {
        //   monitorLedgerStatus(store.ledger!.ledgerDevice);
        // }
      }
    } else {
      // print('init ledger and scan');
      // final ledger = await LedgerInit.init();
      //
      // _deviceStateChangesDisposer =
      //     ledger.deviceStateChanges.listen((event) async {
      //   print('deviceStateChanges1');
      //   print(event.connectionState);
      //   if (event.connectionState == DeviceConnectionState.disconnected) {
      //     if (store.ledger?.ledgerDevice != null) {
      //       // 进入ledger mina app会触发disconnect事件
      //       print('auto connect');
      //       await ledger.connect(store.ledger!.ledgerDevice!);
      //       await monitorLedgerStatus(store.ledger!.ledgerDevice);
      //     }
      //   }
      //   print(store.ledger!.ledgerInstance!.devices.length);
      // });
      // LedgerInit.scanLoop(ledger, onScanSuccess: onScanSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations dic = AppLocalizations.of(context)!;
    return Container(
      // height: 20,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          color: Color(0x1A000000), borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Observer(builder: (_) {
            bool ledgerAvailable = false;
            if (store.ledger!.ledgerStatus != LedgerStatusTypes.unknown) {
              ledgerAvailable =
                  store.ledger!.ledgerStatus == LedgerStatusTypes.available;
            } else {
              ledgerAvailable = ledgerStatus;
            }
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color:
                      ledgerAvailable ? Color(0xFF0DB27C) : Color(0xFFD65A5A),
                  borderRadius: BorderRadius.circular(4)),
            );
          }),
          Container(
            width: 4,
          ),
          Text(
            dic.ledgerStatus,
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black),
          )
        ],
      ),
    );
  }
}
