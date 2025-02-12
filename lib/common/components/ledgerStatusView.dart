import 'dart:async';

import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/ledger/ledger.dart';
import 'package:auro_wallet/utils/UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

class LedgerStatusView extends StatefulWidget {
  LedgerStatusView();

  @override
  _LedgerStatusViewState createState() => new _LedgerStatusViewState();
}

class _LedgerStatusViewState extends State<LedgerStatusView> {
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
    return Observer(builder: (_) {
      bool ledgerAvailable = true;
      if (store.ledger!.ledgerStatus != LedgerStatusTypes.unknown) {
        ledgerAvailable =
            store.ledger!.ledgerStatus == LedgerStatusTypes.available;
      } else {
        ledgerAvailable = ledgerStatus;
      }
      return GestureDetector(
          onTap: () {
            UI.toast(
                ledgerAvailable ? dic.ledgerConnected : dic.ledgerNotConnected);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            child: SvgPicture.asset(
              'assets/images/ledger/icon_legder_status.svg',
              width: 28,
              height: 30,
              colorFilter: ColorFilter.mode(ledgerAvailable ? Color(0xFF0DB27C) : Color(0xFFD65A5A), BlendMode.srcIn)
            ),
          ));
    });
  }
}
