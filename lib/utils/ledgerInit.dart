import 'dart:async';

import 'package:auro_wallet/store/app.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LedgerInit {
  static StreamSubscription<LedgerDevice>? cancelScan;
  static List<void Function(LedgerDevice)> scanListeners = [];

  static offScanListener() {
    scanListeners.clear();
  }

  static bool scaning = false;

  static Future<void> scanLoop(Ledger ledger,
      {void Function(LedgerDevice)? onScanSuccess, recursion = false}) async {
    final store = globalAppStore;

    if (!recursion &&
        !scanListeners.contains(onScanSuccess) &&
        onScanSuccess != null) {
      scanListeners.add(onScanSuccess);
    }
    print('start scan');
    bool foundDevice = false;
    // if (!recursion && scaning) {
    //   return;
    // }
    // if (ledger.devices.length > 0 && onScanSuccess != null) {
    //   onScanSuccess(ledger.devices[0]);
    //   offScanListener(onScanSuccess);
    //   return;
    // }
    await cancelScan?.cancel();
    // cancelScan = null;
    if (!recursion) {
      await ledger.dispose();
      scaning = true;
    }
    try {
      await ledger.stopScanning();
      print('stop scan finish');
    } catch (e) {
      print('stop error');
    }
    cancelScan = ledger.scan().listen((device) async {
      print('scanced a device' + DateTime.now().toUtc().toString());
      foundDevice = true;
      scaning = false;
      cancelScan?.cancel();
      cancelScan = null;
      await ledger.stopScanning();
      scanListeners.forEach((callback) {
        callback(device);
      });
    }, onDone: () async {
      await cancelScan?.cancel();
      cancelScan = null;
      if (!foundDevice) {
        print('scanLoop start');
        await Future.delayed(Duration(seconds: 1));
        print('scanLoop again');
        await scanLoop(ledger, onScanSuccess: onScanSuccess, recursion: true);
        print('scanLoop finish');
      }
      print('scance' + foundDevice.toString());
      print(ledger.devices.length);
      print('ledger scan done' + DateTime.now().toUtc().toString());
    }, onError: (e) async {
      await cancelScan?.cancel();
      cancelScan = null;
      if (!foundDevice) {
        await Future.delayed(Duration(seconds: 1));
        await scanLoop(ledger, onScanSuccess: onScanSuccess, recursion: true);
      }
      print('ledger scan error' + DateTime.now().toUtc().toString());
      print(e);
    });
  }

  static Future<Ledger> init() async {
    final store = globalAppStore;
    // await store.ledger?.ledgerInstance?.dispose();
    // await store.ledger?.ledgerInstance?.stopScanning();
    print('ledger init');
    // store.ledger?.setDevice(null);
    // store.ledger?.setLedger(null);
    if (store.ledger?.ledgerInstance == null) {
      final options = LedgerOptions(
        maxScanDuration: const Duration(seconds: 15),
        // prescanDuration: const Duration(seconds: 20),
        // connectionTimeout: const Duration(seconds: 10),
        // scanMode: ScanMode.balanced
      );
      final ledger = Ledger(
        options: options,
        onPermissionRequest: (status) async {
          // Location was granted, now request BLE
          Map<Permission, PermissionStatus> statuses = await [
            Permission.location,
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.bluetoothAdvertise,
          ].request();

          if (status != BleStatus.ready) {
            return false;
          }
          return statuses.values.where((status) => status.isDenied).isEmpty;
        },
      );
      store.ledger?.setLedger(ledger);
      return ledger;
    }
    // await ledger.close(ConnectionType.ble);
    return store.ledger!.ledgerInstance!;
  }

  static dispose() async {
    print('dispose ledger');
    final store = globalAppStore;
    final ledgerInstance = store.ledger?.ledgerInstance;
    store.ledger?.setLedger(null);
    store.ledger?.setDevice(null);
    if (ledgerInstance != null) {
      await ledgerInstance.stopScanning();
      await ledgerInstance.dispose();
    }
    cancelScan?.cancel();
    cancelScan = null;
  }
}
