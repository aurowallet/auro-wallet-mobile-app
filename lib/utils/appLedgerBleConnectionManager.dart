import 'dart:async';

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/utils/appLedgerGattGateway.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// Owns the native subscription from permission request through disconnection.
/// Late callbacks can only affect the session that created them.
class AppLedgerBleConnectionManager extends BleConnectionManager {
  final FlutterReactiveBle _bleManager;
  final LedgerOptions _options;
  final PermissionRequestCallback? onPermissionRequest;
  final void Function(LedgerDevice device, Object error)? onSessionClosed;
  final void Function(LedgerDevice device, Object error)? onOperationError;
  final void Function(LedgerDevice device, bool pending)? onActivityChanged;
  StreamSubscription<BleStatus>? _statusSubscription;
  final _sessions = <LedgerDevice, _ConnectionSession>{};
  bool _disposed = false;

  AppLedgerBleConnectionManager({
    required LedgerOptions options,
    this.onPermissionRequest,
    this.onSessionClosed,
    this.onOperationError,
    this.onActivityChanged,
    FlutterReactiveBle? bleManager,
  }) : _options = options,
       _bleManager = bleManager ?? FlutterReactiveBle();

  @override
  Future<void> connect(LedgerDevice device, {LedgerOptions? options}) {
    if (_disposed) {
      return Future.error(LedgerException(message: 'Ledger manager disposed.'));
    }
    final existing = _sessions[device];
    if (existing != null) {
      if (!existing.stopped) return existing.ready.future;
      return existing.cleanup!.then((_) => connect(device, options: options));
    }
    final session = _ConnectionSession();
    _sessions[device] = session;
    unawaited(_connect(device, session, options ?? _options));
    return session.ready.future;
  }

  Future<void> _connect(
    LedgerDevice device,
    _ConnectionSession session,
    LedgerOptions options,
  ) async {
    try {
      final granted = (await onPermissionRequest?.call(status)) ?? true;
      if (session.stopped) return;
      if (!granted) {
        throw LedgerException(message: 'Bluetooth permission was not granted.');
      }
      final timeout = _connectionTimeout(options.connectionTimeout);
      session.timeout = Timer(timeout, () {
        unawaited(
          _stop(
            device,
            session,
            LedgerException(message: 'Ledger Bluetooth connection timed out.'),
          ),
        );
      });
      _statusSubscription ??= _bleManager.statusStream.listen(
        (status) {
          if (status != BleStatus.ready) {
            _invalidateConnections(
              LedgerException(message: 'Ledger Bluetooth is not ready.'),
            );
          }
        },
        onError: (Object error) => _invalidateConnections(error),
        onDone: () {
          _statusSubscription = null;
          _invalidateConnections(
            LedgerException(message: 'Ledger Bluetooth status stream ended.'),
          );
        },
      );
      if (session.stopped) return;
      session.subscription = _bleManager
          .connectToAdvertisingDevice(
            id: device.id,
            // Discovery already verified the Ledger service. A reconnect prescan
            // must also accept an advertisement carrying it only as service data.
            withServices: const <Uuid>[],
            prescanDuration: options.prescanDuration,
            connectionTimeout: timeout,
          )
          .listen(
            (state) {
              if (session.stopped) return;
              if (state.connectionState == DeviceConnectionState.connected &&
                  !session.initializing) {
                session.initializing = true;
                unawaited(_initialize(device, session, options));
              } else if (state.connectionState ==
                  DeviceConnectionState.disconnected) {
                unawaited(
                  _stop(
                    device,
                    session,
                    LedgerException(
                      message:
                          'Ledger Bluetooth disconnected: '
                          '${state.failure?.message ?? 'no native failure detail'}',
                    ),
                  ),
                );
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              unawaited(_stop(device, session, error, stackTrace: stackTrace));
            },
            onDone: () {
              unawaited(
                _stop(
                  device,
                  session,
                  LedgerException(
                    message: 'Ledger Bluetooth connection stream ended.',
                  ),
                ),
              );
            },
          );
    } catch (error, stackTrace) {
      await _stop(device, session, error, stackTrace: stackTrace);
    }
  }

  Future<void> _initialize(
    LedgerDevice device,
    _ConnectionSession session,
    LedgerOptions options,
  ) async {
    try {
      List<DiscoveredService> services;
      while (true) {
        try {
          await _bleManager.discoverAllServices(device.id);
          if (session.stopped) return;
          final discovered = await _bleManager.getDiscoveredServices(device.id);
          services = discovered.map(_toLedgerService).toList();
          break;
        } catch (error) {
          if (session.stopped) return;
          if (!'$error'.toLowerCase().contains('bonding')) rethrow;
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (session.stopped) return;
        }
      }
      if (session.stopped) return;
      final gateway = AppLedgerGattGateway(
        bleManager: _bleManager,
        ledger: DiscoveredLedger(
          device: device,
          subscription: null, // This manager alone owns the native connection.
          services: services,
        ),
        mtu: options.mtu,
        onTransportError: (error) => unawaited(_stop(device, session, error)),
      );
      session.gateway = gateway;
      await gateway.start();
      if (session.stopped) return;
      session.timeout?.cancel();
      session.ready.complete();
    } catch (error, stackTrace) {
      await _stop(device, session, error, stackTrace: stackTrace);
    }
  }

  // The Ledger gateway uses UUID-based access. The new BLE API does not expose
  // instance IDs, which this gateway does not use.
  DiscoveredService _toLedgerService(Service service) => DiscoveredService(
    serviceId: service.id,
    serviceInstanceId: '',
    characteristicIds: service.characteristics.map((c) => c.id).toList(),
    characteristics: service.characteristics.map((c) => DiscoveredCharacteristic(
      characteristicId: c.id,
      characteristicInstanceId: '',
      serviceId: service.id,
      isReadable: c.isReadable,
      isWritableWithResponse: c.isWritableWithResponse,
      isWritableWithoutResponse: c.isWritableWithoutResponse,
      isNotifiable: c.isNotifiable,
      isIndicatable: c.isIndicatable,
    )).toList(),
  );

  void _invalidateConnections(Object error) {
    if (_disposed) return;
    for (final entry in _sessions.entries.toList()) {
      // Permission requests have their own readiness wait; they do not own a
      // native connection yet and must not be cancelled by its initial status.
      if (entry.value.timeout != null) {
        unawaited(_stop(entry.key, entry.value, error));
      }
    }
  }

  Future<void> _stop(
    LedgerDevice device,
    _ConnectionSession session,
    Object error, {
    StackTrace? stackTrace,
    bool reportError = true,
  }) {
    if (session.cleanup != null) return session.cleanup!;
    session.stopped = true;
    session.timeout?.cancel();
    if (identical(_sessions[device], session)) {
      onSessionClosed?.call(device, error);
    }
    if (reportError) {
      ledgerErrorLog('BLE session closed', error, stackTrace: stackTrace);
    }
    if (!session.ready.isCompleted) {
      session.ready.completeError(error, stackTrace);
    }
    return session.cleanup = _cleanup(device, session);
  }

  Future<void> _cleanup(LedgerDevice device, _ConnectionSession session) async {
    try {
      await session.gateway?.disconnect();
    } catch (error, stackTrace) {
      ledgerErrorLog('BLE gateway cleanup', error, stackTrace: stackTrace);
    }
    try {
      await session.subscription?.cancel();
    } catch (error, stackTrace) {
      ledgerErrorLog('BLE connection cleanup', error, stackTrace: stackTrace);
    } finally {
      if (identical(_sessions[device], session)) _sessions.remove(device);
    }
  }

  @override
  Future<T> sendOperation<T>(
    LedgerDevice device,
    LedgerOperation<T> operation,
    LedgerTransformer? transformer,
  ) async {
    final session = _sessions[device];
    if (session == null ||
        session.stopped ||
        !session.ready.isCompleted ||
        session.gateway == null) {
      throw LedgerException(message: 'Ledger BLE is not connected.');
    }
    session.pendingOperations++;
    onActivityChanged?.call(device, true);
    try {
      return await session.gateway!.sendOperation<T>(
        operation,
        transformer: transformer,
      );
    } catch (error) {
      if (!session.stopped && identical(_sessions[device], session)) {
        onOperationError?.call(device, error);
      }
      rethrow;
    } finally {
      session.pendingOperations--;
      if (!session.stopped && identical(_sessions[device], session)) {
        onActivityChanged?.call(device, session.pendingOperations > 0);
      }
    }
  }

  @override
  BleStatus get status => _bleManager.status;
  @override
  Stream<BleStatus> get statusStateChanges => _bleManager.statusStream;
  @override
  Stream<ConnectionStateUpdate> get deviceStateChanges =>
      _bleManager.connectedDeviceStream;
  @override
  List<LedgerDevice> get devices => _sessions.entries
      .where((e) => !e.value.stopped && e.value.ready.isCompleted)
      .map((e) => e.key)
      .toList();

  @override
  Future<void> disconnect(LedgerDevice device) async {
    final session = _sessions[device];
    if (session != null) {
      await _stop(
        device,
        session,
        LedgerException(message: 'Ledger Bluetooth connection cancelled.'),
        reportError: false,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _statusSubscription?.cancel();
    _statusSubscription = null;
    await Future.wait(_sessions.keys.toList().map(disconnect));
  }
}

Duration _connectionTimeout(Duration? configuredTimeout) =>
    configuredTimeout ?? const Duration(seconds: 30);

class _ConnectionSession {
  final ready = Completer<void>();
  StreamSubscription<ConnectionStateUpdate>? subscription;
  Timer? timeout;
  AppLedgerGattGateway? gateway;
  bool stopped = false;
  bool initializing = false;
  int pendingOperations = 0;
  Future<void>? cleanup;
}
