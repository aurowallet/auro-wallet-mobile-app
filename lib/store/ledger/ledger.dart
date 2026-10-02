import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/mina_ledger_application.dart';
import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:mobx/mobx.dart';

part 'ledger.g.dart';

class LedgerStore = LedgerBase with _$LedgerStore;

enum LedgerStatusTypes { unknown, available, unavailable }

enum LedgerReadiness { ready, connect, rejected, cancelled }

// Match MobX's nullable generic comparer so reportWrite can infer its type.
bool _sameLedgerDevice<T>(T? previous, T? next) =>
    identical(previous, next);

abstract class LedgerBase with Store {
  int _sessionRevision = 0;
  Future<void>? _statusCheck;
  bool operationPending = false;
  LedgerFailureType? lastFailure;

  @MakeObservable(equals: _sameLedgerDevice)
  LedgerDevice? ledgerDevice = null;

  @observable
  Ledger? ledgerInstance = null;

  @observable
  LedgerStatusTypes ledgerStatus = LedgerStatusTypes.unknown;

  @action
  void setDevice(LedgerDevice? device) {
    if (!identical(device, ledgerDevice)) {
      _invalidateSession();
      ledgerStatus = device == null
          ? LedgerStatusTypes.unavailable
          : LedgerStatusTypes.unknown;
    }
    ledgerDevice = device;
  }

  @action
  void setLedger(Ledger? ledger) {
    if (!identical(ledger, ledgerInstance)) {
      _invalidateSession();
      ledgerDevice = null;
      ledgerStatus = ledger == null
          ? LedgerStatusTypes.unavailable
          : LedgerStatusTypes.unknown;
    }
    ledgerInstance = ledger;
  }

  @action
  void setLedgerStatus(LedgerStatusTypes status) {
    _sessionRevision++;
    if (status == LedgerStatusTypes.available) lastFailure = null;
    ledgerStatus = status;
  }

  void _invalidateSession() {
    _sessionRevision++;
    _statusCheck = null;
    operationPending = false;
    lastFailure = null;
  }

  void recordFailure(Object error) {
    final failure = classifyLedgerError(error);
    if (failure == LedgerFailureType.rejected) return;
    lastFailure = failure;
    setLedgerStatus(LedgerStatusTypes.unavailable);
  }

  Future<void> disconnectSession(Ledger ledger, LedgerDevice device) async {
    if (identical(ledgerInstance, ledger) && ledgerDevice?.id == device.id &&
        !identical(ledgerDevice, device)) return;
    if (identical(ledgerInstance, ledger) && identical(ledgerDevice, device)) {
      setDevice(null);
    }
    try {
      await ledger.disconnect(device);
    } catch (error, stackTrace) {
      ledgerErrorLog('Ledger session cleanup', error, stackTrace: stackTrace);
    }
  }

  bool get isReady => ledgerInstance != null && ledgerDevice != null &&
      ledgerStatus == LedgerStatusTypes.available;

  Future<LedgerReadiness> prepareForTransaction({
    required String stage,
    required bool Function() isActive,
  }) async {
    final ledger = ledgerInstance;
    final device = ledgerDevice;
    bool isCurrent() => isActive() && identical(ledger, ledgerInstance) &&
        (ledgerDevice == null || identical(device, ledgerDevice));
    final pendingCheck = _statusCheck;
    await pendingCheck;
    if (!isCurrent()) return LedgerReadiness.cancelled;
    if (isReady) return LedgerReadiness.ready;
    if (pendingCheck != null && lastFailure == LedgerFailureType.rejected) {
      return LedgerReadiness.rejected;
    }
    if (ledger != null && device != null &&
        ledgerStatus == LedgerStatusTypes.unknown) {
      await refreshStatus(stage: stage, isActive: isActive);
      if (!isCurrent()) return LedgerReadiness.cancelled;
      if (isReady) return LedgerReadiness.ready;
      if (lastFailure == LedgerFailureType.rejected) {
        return LedgerReadiness.rejected;
      }
    } else if (ledger == null || device == null) {
      if (ledger == null && device != null) setDevice(null);
      setLedgerStatus(LedgerStatusTypes.unavailable);
    }
    return LedgerReadiness.connect;
  }

  Future<void> refreshStatus({
    String stage = 'Ledger status readiness',
    bool Function()? isActive,
  }) {
    if (_statusCheck != null) return _statusCheck!;
    if (operationPending) return Future<void>.value();
    final ledger = ledgerInstance;
    final device = ledgerDevice;
    if (ledger == null || device == null) {
      setLedgerStatus(LedgerStatusTypes.unavailable);
      return Future<void>.value();
    }
    final revision = _sessionRevision;
    bool isCurrent() =>
        (isActive?.call() ?? true) &&
        revision == _sessionRevision &&
        identical(ledger, ledgerInstance) &&
        identical(device, ledgerDevice);
    late final Future<void> check;
    check = (() async {
      try {
        await MinaLedgerApp(ledger).ensureMinaAppReady(device);
        if (isCurrent()) setLedgerStatus(LedgerStatusTypes.available);
      } catch (error, stackTrace) {
        ledgerErrorLog(
          stage,
          error,
          stackTrace: stackTrace,
        );
        if (isCurrent()) {
          lastFailure = classifyLedgerError(error);
          setLedgerStatus(LedgerStatusTypes.unavailable);
        }
      } finally {
        if (identical(_statusCheck, check)) _statusCheck = null;
      }
    })();
    return _statusCheck = check;
  }
}
