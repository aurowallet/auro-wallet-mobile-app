import 'package:auro_wallet/store/app.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LedgerInit {
  static scan(Ledger ledger) async {
    final store = globalAppStore;
    await ledger.stopScanning();
    print('stopScanning finished');
    ledger.scan().listen((device) async {
      await ledger.stopScanning();
      await ledger.connect(device);
      if (store.ledger?.ledgerInstance != null) {
        store.ledger?.setDevice(device);
      }
    });
  }

  static Future<Ledger> init() async {
    final store = globalAppStore;
    await store.ledger?.ledgerInstance?.dispose();
    await store.ledger?.ledgerInstance?.stopScanning();
    print('dispose finished');
    store.ledger?.setDevice(null);
    store.ledger?.setLedger(null);
    final options = LedgerOptions(
      maxScanDuration: const Duration(milliseconds: 15000),
    );
    final ledger = Ledger(
      options: options,
      onPermissionRequest: (status) async {
        // Location was granted, now request BLE
        Map<Permission, PermissionStatus> statuses = await [
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
    // await ledger.close(ConnectionType.ble);
    store.ledger?.setLedger(ledger);
    return ledger;
  }

  static initAndScan() async {
    final ledger = await init();
    await scan(ledger);
  }

  static dispose() async {
    final store = globalAppStore;
    if (store.ledger?.ledgerInstance != null) {
      await store.ledger?.ledgerInstance?.stopScanning();
      await store.ledger?.ledgerInstance?.dispose();
      store.ledger?.setLedger(null);
      store.ledger?.setDevice(null);
    }
  }
}
