import 'dart:async';

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'persistentLedgerBleSearchManager.dart';
import 'appLedgerBleConnectionManager.dart';

class LedgerInit {
  static StreamSubscription<LedgerDevice>? cancelScan;
  static int _scanGeneration = 0;

  /// Invalidates the current scan before cancelling it so a late stream
  /// callback cannot update a newer dialog session.
  static Future<void> stopScanLoop({Ledger? ledger}) async {
    final generation = ++_scanGeneration;
    final subscription = cancelScan;
    cancelScan = null;
    await subscription?.cancel();
    if (generation != _scanGeneration) return;
    if (ledger != null) {
      try {
        await ledger.stopScanning();
      } catch (error, stackTrace) {
        ledgerErrorLog('BLE stop scan', error, stackTrace: stackTrace);
      }
    }
  }

  static Future<void> scanLoop(Ledger ledger,
      {void Function(LedgerDevice)? onScanSuccess}) async {
    final activeGeneration = ++_scanGeneration;
    final previousSubscription = cancelScan;
    cancelScan = null;
    await previousSubscription?.cancel();
    if (activeGeneration != _scanGeneration) {
      return;
    }
    try {
      await ledger.stopScanning();
    } catch (error, stackTrace) {
      ledgerErrorLog('BLE stop previous scan', error, stackTrace: stackTrace);
    }
    if (activeGeneration != _scanGeneration) {
      return;
    }
    late final StreamSubscription<LedgerDevice> subscription;
    subscription = ledger.scan().listen((device) async {
      if (activeGeneration != _scanGeneration || cancelScan != subscription) {
        return;
      }
      cancelScan = null;
      await subscription.cancel();
      if (activeGeneration != _scanGeneration) return;
      try {
        await ledger.stopScanning();
      } catch (error, stackTrace) {
        ledgerErrorLog('BLE stop after Ledger discovery', error,
            stackTrace: stackTrace);
      }
      if (activeGeneration != _scanGeneration) return;
      onScanSuccess?.call(device);
    }, onDone: () async {
      if (activeGeneration != _scanGeneration || cancelScan != subscription) {
        return;
      }
      cancelScan = null;
    }, onError: (error) async {
      if (activeGeneration != _scanGeneration || cancelScan != subscription) {
        return;
      }
      cancelScan = null;
      ledgerErrorLog('Ledger scan stream', error);
    });
    cancelScan = subscription;
  }

  static Future<Ledger> init() async {
    final store = globalAppStore;
    if (store.ledger?.ledgerInstance == null) {
      final options = LedgerOptions(
        // PersistentLedgerBleSearchManager owns discovery lifetime and does
        // not use this duration; retain it for the Ledger API contract.
        scanMode: ScanMode.lowLatency,
        maxScanDuration: const Duration(seconds: 15),
        // Pairing confirmation happens outside the app.
        prescanDuration: const Duration(seconds: 8),
        connectionTimeout: const Duration(seconds: 30),
      );
      late final Ledger ledger;
      bool isCurrentDevice(LedgerDevice device) =>
          identical(store.ledger?.ledgerInstance, ledger) &&
          store.ledger?.ledgerDevice?.id == device.id;
      ledger = Ledger(
        options: options,
        bleSearchManager: PersistentLedgerBleSearchManager(
          options: options,
          onPermissionRequest: _requestPermissions,
        ),
        bleConnectionManager: AppLedgerBleConnectionManager(
          options: options,
          onPermissionRequest: _requestPermissions,
          onSessionClosed: (device, error) {
            if (!isCurrentDevice(device)) return;
            store.ledger!.setDevice(null);
            store.ledger!.recordFailure(error);
          },
          onOperationError: (device, error) {
            if (isCurrentDevice(device)) store.ledger!.recordFailure(error);
          },
          onActivityChanged: (device, pending) {
            if (isCurrentDevice(device)) {
              store.ledger!.operationPending = pending;
            }
          },
        ),
        onPermissionRequest: _requestPermissions,
      );
      store.ledger?.setLedger(ledger);
      return ledger;
    }
    return store.ledger!.ledgerInstance!;
  }

  static Future<bool> _requestPermissions(BleStatus status) async {
    final statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
    if (statuses.values.any((permissionStatus) => permissionStatus.isDenied)) {
      return false;
    }
    if (status == BleStatus.ready) {
      return true;
    }
    try {
      await FlutterReactiveBle()
          .statusStream
          .firstWhere((value) => value == BleStatus.ready)
          .timeout(const Duration(seconds: 5));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  static dispose() async {
    final store = globalAppStore;
    final ledgerInstance = store.ledger?.ledgerInstance;
    store.ledger?.setLedger(null);
    store.ledger?.setDevice(null);
    if (ledgerInstance != null) {
      try {
        await ledgerInstance.stopScanning();
      } catch (error, stackTrace) {
        ledgerErrorLog(
          'Ledger dispose stop scan',
          error,
          stackTrace: stackTrace,
        );
      }
      try {
        await ledgerInstance.dispose();
      } catch (error, stackTrace) {
        ledgerErrorLog('Ledger dispose', error, stackTrace: stackTrace);
      }
    }
    await stopScanLoop(ledger: ledgerInstance);
  }
}
