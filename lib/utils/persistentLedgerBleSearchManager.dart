import 'dart:async';

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

typedef BleDeviceScan =
    Stream<DiscoveredDevice> Function(
      List<Uuid> services,
      ScanMode mode,
      bool requireLocationServicesEnabled,
    );

class PersistentLedgerBleSearchManager extends BleSearchManager {
  static const serviceId = '13D63400-2C97-0004-0000-4C6564676572';

  final LedgerOptions _defaultOptions;
  final PermissionRequestCallback? _onPermissionRequest;
  final BleDeviceScan _scanForDevices;
  final Duration _restartDelay;
  final BleStatus Function() _statusProvider;

  final _scannedIds = <String>{};
  StreamController<LedgerDevice>? _controller;
  StreamSubscription<DiscoveredDevice>? _subscription;
  Timer? _restartTimer;
  LedgerOptions? _activeOptions;
  bool _isScanning = false;
  Future<void>? _interruption;
  Future<void>? _stopping;
  int _scanSession = 0;

  PersistentLedgerBleSearchManager({
    required LedgerOptions options,
    PermissionRequestCallback? onPermissionRequest,
    FlutterReactiveBle? bleManager,
    BleDeviceScan? scanForDevices,
    Duration restartDelay = const Duration(seconds: 1),
    BleStatus Function()? statusProvider,
  }) : _defaultOptions = options,
       _onPermissionRequest = onPermissionRequest,
       _restartDelay = restartDelay,
       _statusProvider = statusProvider ?? (() => FlutterReactiveBle().status),
       _scanForDevices =
           scanForDevices ??
           ((services, mode, requireLocationServicesEnabled) =>
               (bleManager ?? FlutterReactiveBle()).scanForDevices(
                 withServices: services,
                 scanMode: mode,
                 requireLocationServicesEnabled: requireLocationServicesEnabled,
               ));

  @override
  Stream<LedgerDevice> scan({LedgerOptions? options}) {
    final controller = _controller;
    if (controller != null && !controller.isClosed) {
      return controller.stream;
    }

    _activeOptions = options ?? _defaultOptions;
    _scannedIds.clear();
    _isScanning = true;
    final session = ++_scanSession;
    late final StreamController<LedgerDevice> nextController;
    nextController = StreamController<LedgerDevice>.broadcast(
      onListen: () => unawaited(_startNativeScan(session)),
      onCancel: () {
        if (identical(_controller, nextController)) unawaited(stop());
      },
    );
    _controller = nextController;
    return nextController.stream;
  }

  bool _isActiveSession(int session) => _isScanning && _scanSession == session;

  Future<void> _startNativeScan(int session) async {
    if (!_isActiveSession(session) || _subscription != null) return;
    await _stopping;
    if (!_isActiveSession(session) || _subscription != null) return;

    final interruption = _interruption;
    if (interruption != null) {
      await interruption;
      if (!_isActiveSession(session) || _subscription != null) return;
    }

    try {
      final granted = (await _onPermissionRequest?.call(status)) ?? true;
      if (!_isActiveSession(session)) return;
      if (!granted) {
        ledgerErrorLog(
          'BLE scan permission',
          StateError('Bluetooth is not ready'),
        );
        _scheduleRestart(session);
        return;
      }

      final options = _activeOptions!;
      _subscription =
          _scanForDevices(
            const <Uuid>[],
            options.scanMode,
            options.requireLocationServicesEnabled,
          ).listen(
            (device) {
              if (!_isActiveSession(session)) return;
              if (!isLedgerCandidate(device) ||
                  _scannedIds.contains(device.id)) {
                return;
              }
              _scannedIds.add(device.id);
              _controller?.add(
                LedgerDevice(
                  id: device.id,
                  name: device.name,
                  connectionType: ConnectionType.ble,
                  rssi: device.rssi,
                ),
              );
            },
            onDone: () =>
                unawaited(_handleInterruption(session)),
            onError: (Object error, StackTrace stackTrace) {
              ledgerErrorLog('BLE native scan', error, stackTrace: stackTrace);
              unawaited(_handleInterruption(session));
            },
          );
    } catch (error, stackTrace) {
      ledgerErrorLog('BLE scan startup', error, stackTrace: stackTrace);
      await _handleInterruption(session);
    }
  }

  static bool isLedgerCandidate(DiscoveredDevice device) {
    bool isLedgerService(Uuid uuid) =>
        uuid.toString().toUpperCase() == serviceId;
    return device.serviceUuids.any(isLedgerService) ||
        device.serviceData.keys.any(isLedgerService);
  }

  Future<void> _handleInterruption(int session) {
    if (!_isActiveSession(session)) return Future<void>.value();
    final interruption = _interruption;
    if (interruption != null) {
      return interruption;
    }
    final nextInterruption = _cancelAndRestart(session);
    _interruption = nextInterruption;
    unawaited(
      nextInterruption.whenComplete(() {
        if (identical(_interruption, nextInterruption)) {
          _interruption = null;
        }
      }),
    );
    return nextInterruption;
  }

  Future<void> _cancelAndRestart(int session) async {
    final subscription = _subscription;
    _subscription = null;
    try {
      await subscription?.cancel();
    } catch (error, stackTrace) {
      ledgerErrorLog(
        'BLE native scan cancellation',
        error,
        stackTrace: stackTrace,
      );
    }
    _scheduleRestart(session);
  }

  void _scheduleRestart(int session) {
    if (!_isActiveSession(session) || _restartTimer?.isActive == true) return;
    _restartTimer = Timer(_restartDelay, () {
      _restartTimer = null;
      if (_isActiveSession(session)) {
        unawaited(_startNativeScan(session));
      }
    });
  }

  @override
  Future<void> stop() {
    _scanSession++;
    _isScanning = false;
    _restartTimer?.cancel();
    _restartTimer = null;
    final subscription = _subscription;
    _subscription = null;
    final controller = _controller;
    _controller = null;
    final previousStop = _stopping;
    final interruption = _interruption;
    return _stopping = () async {
      await previousStop;
      await interruption;
      try {
        await subscription?.cancel();
      } catch (error, stackTrace) {
        ledgerErrorLog('BLE scan cleanup', error, stackTrace: stackTrace);
      }
      await controller?.close();
    }();
  }

  @override
  Future<void> dispose() => stop();

  BleStatus get status => _statusProvider();
}
