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
  final void Function(LedgerDevice device, bool pending)? onPairingChanged;
  StreamSubscription<BleStatus>? _statusSubscription;
  late final StreamSubscription<ConnectionStateUpdate> _connectionEvents;
  final _latestConnectionStates = <String, ConnectionStateUpdate>{};
  final _deviceEvents = StreamController<ConnectionStateUpdate>.broadcast();
  final _sessions = <LedgerDevice, _ConnectionSession>{};
  bool _disposed = false;

  AppLedgerBleConnectionManager({
    required LedgerOptions options,
    this.onPermissionRequest,
    this.onSessionClosed,
    this.onOperationError,
    this.onActivityChanged,
    this.onPairingChanged,
    FlutterReactiveBle? bleManager,
  }) : _options = options,
       _bleManager = bleManager ?? FlutterReactiveBle() {
    // Android's event-channel onCancel disconnects ALL devices and disposes
    // the native connection collection. Keep this channel alive independently
    // of scans and individual connections until the manager itself is disposed.
    _connectionEvents = _bleManager.connectedDeviceStream.listen(
      (update) {
        _recordConnectionState(update);
      },
      onError: (Object error, StackTrace stackTrace) {
        _deviceEvents.addError(error, stackTrace);
        _invalidateConnections(error);
      },
      onDone: () => _invalidateConnections(
        LedgerException(message: 'Ledger Bluetooth connection events ended.'),
      ),
    );
  }

  @override
  Future<void> connect(LedgerDevice device, {
    LedgerOptions? options,
    bool nativeConnectionEstablished = false,
  }) {
    if (_disposed) {
      return Future.error(LedgerException(message: 'Ledger manager disposed.'));
    }
    final existing = _sessions[device];
    if (existing != null && !existing.stopped) {
      return existing.ready.future;
    }
    // Own a queued retry immediately, so disconnect can cancel it while the
    // previous native subscription is still being released.
    final session = _ConnectionSession(previous: existing);
    _sessions.remove(device); // Replace same-ID metadata with the new selection.
    _sessions[device] = session;
    unawaited(_connect(device, session, options ?? _options,
        nativeConnectionEstablished: nativeConnectionEstablished));
    return session.ready.future;
  }

  Future<void> _connect(
    LedgerDevice device,
    _ConnectionSession session,
    LedgerOptions options, {
    required bool nativeConnectionEstablished,
  }) async {
    try {
      final previous = session.previous;
      if (previous != null) {
        // connect reuses active sessions; a predecessor is already stopped.
        await previous.cleanup;
        session.previous = null;
        if (session.stopped) return;
        // The observed native link belonged to the session just released.
        nativeConnectionEstablished = false;
      }
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
          .connectToDevice(
            id: device.id,
            // Discovery has already identified the device by advertisement or
            // GATT service. A connected Ledger need not advertise again.
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
      // The plugin may not emit another connected event for a link that was
      // already established. The recovery caller has just observed that event;
      // own its subscription and validate GATT now instead of waiting for a
      // duplicate event. A late event is handled by the same initializing guard.
      if (nativeConnectionEstablished && !session.stopped &&
          !session.initializing) {
        session.initializing = true;
        unawaited(_initialize(device, session, options));
      }
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
        onPairingChanged: (pending) {
          if (identical(_sessions[device], session)) {
            onPairingChanged?.call(device, pending);
          }
        },
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
    for (final id in _latestConnectionStates.keys.toList()) {
      _recordConnectionState(ConnectionStateUpdate(deviceId: id,
          connectionState: DeviceConnectionState.disconnected, failure: null));
    }
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
    // Publish cleanup before notifying observers, which may synchronously retry.
    final cleanup = Completer<void>();
    session.cleanup = cleanup.future;
    session.stopped = true;
    session.timeout?.cancel();
    if (identical(_sessions[device], session)) {
      _recordConnectionState(ConnectionStateUpdate(deviceId: device.id,
          connectionState: DeviceConnectionState.disconnected, failure: null));
      onSessionClosed?.call(device, error);
    }
    if (reportError) {
      ledgerErrorLog('BLE session closed', error, stackTrace: stackTrace);
    }
    if (!session.ready.isCompleted) {
      session.ready.completeError(error, stackTrace);
    }
    unawaited(_cleanup(device, session).then(cleanup.complete,
        onError: cleanup.completeError));
    return cleanup.future;
  }

  Future<void> _cleanup(LedgerDevice device, _ConnectionSession session) async {
    await session.previous?.cleanup;
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

  void _recordConnectionState(ConnectionStateUpdate update) {
    if (_deviceEvents.isClosed) return;
    if (update.connectionState == DeviceConnectionState.disconnected) {
      _latestConnectionStates.remove(update.deviceId);
    } else {
      _latestConnectionStates[update.deviceId] = update;
    }
    _deviceEvents.add(update);
  }
  @override
  Stream<BleStatus> get statusStateChanges => _bleManager.statusStream;
  @override
  Stream<ConnectionStateUpdate> get deviceStateChanges {
    if (_disposed) return const Stream.empty();
    // A scanner may subscribe after the native channel's initial event. Replay
    // the latest states without opening/cancelling a native subscription.
    return Stream<ConnectionStateUpdate>.multi((controller) {
      final subscription = _deviceEvents.stream.listen(
        controller.addSync,
        onError: controller.addErrorSync,
        onDone: controller.closeSync,
      );
      for (final state in _latestConnectionStates.values) {
        controller.addSync(state);
      }
      controller.onCancel = subscription.cancel;
    }, isBroadcast: true);
  }
  @override
  List<LedgerDevice> get devices => _sessions.entries
      .where((e) => !e.value.stopped &&
          e.value.ready.isCompleted)
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
    await _connectionEvents.cancel();
    await _deviceEvents.close();
    _latestConnectionStates.clear();
  }
}

Duration _connectionTimeout(Duration? configuredTimeout) =>
    configuredTimeout ?? const Duration(seconds: 30);

class _ConnectionSession {
  _ConnectionSession({this.previous});
  _ConnectionSession? previous;
  final ready = Completer<void>();
  StreamSubscription<ConnectionStateUpdate>? subscription;
  Timer? timeout;
  AppLedgerGattGateway? gateway;
  bool stopped = false;
  bool initializing = false;
  int pendingOperations = 0;
  Future<void>? cleanup;
}
