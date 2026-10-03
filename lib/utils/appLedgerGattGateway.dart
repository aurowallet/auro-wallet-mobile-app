import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show PlatformException;

import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_version_operation.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// App-owned GATT gateway for the Ledger BLE transport.
///
/// A Ledger can return an APDU response immediately after the final write.
/// The pending request is therefore registered before writing, and requests
/// are serialized because the Ledger application processes one APDU at a
/// time.
class AppLedgerGattGateway extends GattGateway {
  static const _serviceId = '13D63400-2C97-0004-0000-4C6564676572';
  static const _writeCharacteristicId = '13D63400-2C97-0004-0002-4C6564676572';
  static const _notifyCharacteristicId = '13D63400-2C97-0004-0001-4C6564676572';

  final FlutterReactiveBle _bleManager;
  final DiscoveredLedger _ledger;
  final LedgerGattReader _reader;
  final BlePacker _packer;
  // sendOperation serializes requests; only one response can be pending.
  _PendingOperation? _pendingOperation;

  DiscoveredCharacteristic? _writeCharacteristic;
  DiscoveredCharacteristic? _notifyCharacteristic;
  Future<void> _operationTail = Future<void>.value();
  int _mtu;
  bool _closed = false;
  bool _waitingForPairing = false;
  Object? _transportError;
  Future<void>? _closing;
  final _disconnected = Completer<void>();
  final Duration probeTimeout;
  final Duration publicKeyTimeout;
  final Duration writeTimeout;
  final Duration preparationTimeout;
  final void Function(Object error)? onTransportError;
  final void Function(bool pending)? onPairingChanged;

  AppLedgerGattGateway({
    required FlutterReactiveBle bleManager,
    required DiscoveredLedger ledger,
    LedgerGattReader? reader,
    BlePacker? packer,
    int mtu = 23,
    this.probeTimeout = const Duration(seconds: 10),
    this.publicKeyTimeout = const Duration(minutes: 2),
    this.writeTimeout = const Duration(seconds: 30),
    this.preparationTimeout = const Duration(seconds: 30),
    this.onTransportError,
    this.onPairingChanged,
  }) : _bleManager = bleManager,
       _ledger = ledger,
       _reader = reader ?? LedgerGattReader(),
       _packer = packer ?? LedgerPacker(),
       _mtu = mtu;

  @override
  Future<void> start() async {
    if (!isRequiredServiceSupported()) {
      throw LedgerException(
        message: 'Required Ledger BLE service not supported.',
      );
    }
    if (_closed) throw LedgerException(message: 'Ledger BLE disconnected.');
    try {
      _mtu = await _bleManager
          .requestMtu(deviceId: _ledger.device.id, mtu: _mtu)
          .timeout(const Duration(seconds: 5));
    } catch (error) {
      // A requested MTU is not a negotiated MTU. Fall back to ATT's minimum.
      _mtu = 23;
      ledgerErrorLog('GATT MTU negotiation', error);
    }
    if (_closed) throw LedgerException(message: 'Ledger BLE disconnected.');

    final notify = _notifyCharacteristic!;
    // Keep the known-good initialization order. The convenience API owns its
    // lookup; do not add write-characteristic polling after subscribing.
    _reader.read(
      _bleManager
          .subscribeToCharacteristic(
            QualifiedCharacteristic(
              serviceId: notify.serviceId,
              characteristicId: notify.characteristicId,
              deviceId: _ledger.device.id,
            ),
          )
          .transform(
            StreamTransformer<List<int>, List<int>>.fromHandlers(
              handleError: (Object error, StackTrace stackTrace, sink) {
                // CCCD errors alone do not prove a pairing failure. Only add
                // this context when Android explicitly reported BONDING.
                final failure = _waitingForPairing &&
                        '$error'.toLowerCase().contains(
                            'cannot write client characteristic config descriptor')
                    ? LedgerPairingIncompleteException(error)
                    : error;
                unawaited(_abort(failure));
              },
              handleDone: (sink) {
                unawaited(
                  _abort(
                    LedgerException(
                      message: 'Ledger notification stream ended.',
                    ),
                  ),
                );
                sink.close();
              },
            ),
          ),
      onData: _handleData,
      onError: _handleError,
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_closed) {
      throw _transportError ??
          LedgerException(message: 'Ledger BLE disconnected.');
    }
  }

  @override
  Future<T> sendOperation<T>(
    LedgerOperation operation, {
    LedgerTransformer? transformer,
  }) async {
    final previous = _operationTail;
    final turn = Completer<void>();
    _operationTail = turn.future;
    await previous;
    try {
      return await _sendOperation<T>(operation, transformer: transformer);
    } finally {
      turn.complete();
    }
  }

  Future<T> _sendOperation<T>(
    LedgerOperation operation, {
    LedgerTransformer? transformer,
  }) async {
    if (_closed || !isRequiredServiceSupported()) {
      throw LedgerException(
        message: 'Required Ledger BLE service not supported.',
      );
    }

    final writer = ByteDataWriter();
    final output = await operation.write(writer);
    if (_closed) throw LedgerException(message: 'Ledger BLE disconnected.');
    // The convenience write API queries services before every packet. Android
    // rejects that query during bonding even though no packet has been sent.
    // Resolve once per APDU, before its response timeout starts; only this
    // side-effect-free preparation may retry. Keep the notification stream alive.
    final Characteristic characteristic;
    try {
      characteristic = await Future.any<Characteristic>([
        _resolveWriteBeforeSending(),
        _disconnected.future.then((_) => throw _transportError!),
      ]).timeout(preparationTimeout);
    } catch (error) {
      final failure = error is TimeoutException && _waitingForPairing
          ? LedgerPairingIncompleteException(error)
          : error;
      await _abort(failure);
      if (identical(failure, error)) rethrow;
      throw failure;
    }
    if (_closed) throw _transportError!;
    final completion = Completer<T>();
    final pending = _PendingOperation(operation, transformer, completion);
    _pendingOperation = pending;

    // Attach response/error handlers before the first write. An APDU status
    // can arrive while Android is still acknowledging that write.
    final finished = Completer<void>();
    final result = Future.any<List<Object?>>([
      Future.wait<Object?>([completion.future, finished.future]),
      _disconnected.future.then((_) => throw _transportError!),
    ]);
    Timer? timer;
    // Silent public-key lookup still derives a key on the device and can show
    // Processing for longer than a connection probe. Address confirmation and
    // signing wait for the user; neither uses the short probe timeout.
    final timeout =
        operation is MinaVersionOperation || operation is MinaNameOperation
        ? probeTimeout
        : operation is MinaPublicKeyOperation && !operation.showAddressInDevice
        ? publicKeyTimeout
        : null;
    if (timeout != null) {
      timer = Timer(timeout, () {
        unawaited(
          _abort(
            TimeoutException(
              'Ledger APDU timed out: ${operation.runtimeType}.',
            ),
          ),
        );
      });
    }
    Future<void> writePackets() async {
      try {
        for (final payload in output) {
          for (final packet in _packer.pack(payload, _mtu)) {
            if (_closed)
              throw LedgerException(message: 'Ledger BLE disconnected.');
            await characteristic.write(packet, withResponse: true)
                .timeout(writeTimeout);
          }
        }
        finished.complete();
      } catch (error, stackTrace) {
        finished.completeError(error, stackTrace);
        unawaited(_abort(error));
      }
    }

    unawaited(writePackets());
    try {
      return (await result).first as T;
    } finally {
      timer?.cancel();
      if (identical(_pendingOperation, pending)) _pendingOperation = null;
    }
  }

  Future<Characteristic> _resolveWriteBeforeSending() async {
    final write = _writeCharacteristic!;
    final qualified = QualifiedCharacteristic(
      serviceId: write.serviceId,
      characteristicId: write.characteristicId,
      deviceId: _ledger.device.id,
    );
    while (true) {
      if (_closed) throw _transportError!;
      try {
        final characteristic = await _bleManager.resolveSingle(qualified);
        if (_closed) throw _transportError!;
        _setPairingPending(false);
        return characteristic;
      } catch (error) {
        if (_closed || error is! PlatformException ||
            error.code != 'service_discovery_failure' ||
            !(error.message ?? '').toLowerCase().contains('bonding is in progress')) {
          rethrow;
        }
        _setPairingPending(true);
        await Future.any<void>([
          Future<void>.delayed(const Duration(milliseconds: 500)),
          _disconnected.future,
        ]);
      }
    }
  }

  void _setPairingPending(bool pending) {
    if (_waitingForPairing == pending) return;
    _waitingForPairing = pending;
    onPairingChanged?.call(pending);
  }

  Future<void> _handleData(Uint8List data) async {
    final pending = _pendingOperation;
    if (pending == null) return;
    try {
      final reader = ByteDataReader();
      final transformer = pending.transformer;
      reader.add(
        transformer == null ? data : await transformer.onTransform([data]),
      );
      final response = await pending.operation.read(reader);
      if (identical(_pendingOperation, pending)) {
        _pendingOperation = null;
        pending.completion.complete(response);
      }
    } catch (error, stackTrace) {
      if (identical(_pendingOperation, pending)) {
        _completePendingError(error, stackTrace);
      }
    }
  }

  void _handleError(Object error) {
    ledgerErrorLog('GATT APDU response', error);
    _completePendingError(error, null);
  }

  void _completePendingError(Object error, StackTrace? stackTrace) {
    final pending = _pendingOperation;
    _pendingOperation = null;
    pending?.completion.completeError(error, stackTrace);
  }

  @override
  bool isRequiredServiceSupported() {
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    final service = getService(Uuid.parse(_serviceId));
    if (service == null) return false;
    _writeCharacteristic = getCharacteristic(
      service,
      Uuid.parse(_writeCharacteristicId),
    );
    _notifyCharacteristic = getCharacteristic(
      service,
      Uuid.parse(_notifyCharacteristicId),
    );
    return _writeCharacteristic != null && _notifyCharacteristic != null;
  }

  @override
  DiscoveredService? getService(Uuid service) {
    for (final candidate in _ledger.services) {
      if (candidate.serviceId == service) return candidate;
    }
    return null;
  }

  @override
  DiscoveredCharacteristic? getCharacteristic(
    DiscoveredService service,
    Uuid characteristic,
  ) {
    for (final candidate in service.characteristics) {
      if (candidate.characteristicId == characteristic) return candidate;
    }
    return null;
  }

  @override
  void onServicesInvalidated() {
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
  }

  @override
  Future<void> disconnect() => _abort(
    LedgerException(message: 'Ledger BLE disconnected.'),
    notifyManager: false,
  );

  Future<void> _abort(Object error, {bool notifyManager = true}) {
    if (_closing != null) return _closing!;
    _closed = true;
    _transportError = error;
    _setPairingPending(false);
    _disconnected.complete();
    if (notifyManager) ledgerErrorLog('GATT channel closed', error);
    _completePendingError(error, null);
    final closing = _closing = _release();
    if (notifyManager) scheduleMicrotask(() => onTransportError?.call(error));
    return closing;
  }

  Future<void> _release() async {
    try {
      await _reader.subscription?.cancel();
      _reader.reset();
    } catch (error, stackTrace) {
      ledgerErrorLog(
        'GATT notification cleanup',
        error,
        stackTrace: stackTrace,
      );
    } finally {
      try {
        await _ledger.subscription?.cancel();
      } catch (error, stackTrace) {
        ledgerErrorLog(
          'GATT connection cleanup',
          error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @override
  Future<void> close() => disconnect();
}

class _PendingOperation<T> {
  final LedgerOperation<T> operation;
  final LedgerTransformer? transformer;
  final Completer<T> completion;

  _PendingOperation(this.operation, this.transformer, this.completion);
}
