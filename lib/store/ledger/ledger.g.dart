// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LedgerStore on LedgerBase, Store {
  late final _$ledgerDeviceAtom =
      Atom(name: 'LedgerBase.ledgerDevice', context: context);

  @override
  LedgerDevice? get ledgerDevice {
    _$ledgerDeviceAtom.reportRead();
    return super.ledgerDevice;
  }

  @override
  set ledgerDevice(LedgerDevice? value) {
    _$ledgerDeviceAtom.reportWrite(value, super.ledgerDevice, () {
      super.ledgerDevice = value;
    });
  }

  late final _$ledgerInstanceAtom =
      Atom(name: 'LedgerBase.ledgerInstance', context: context);

  @override
  Ledger? get ledgerInstance {
    _$ledgerInstanceAtom.reportRead();
    return super.ledgerInstance;
  }

  @override
  set ledgerInstance(Ledger? value) {
    _$ledgerInstanceAtom.reportWrite(value, super.ledgerInstance, () {
      super.ledgerInstance = value;
    });
  }

  late final _$ledgerStatusAtom =
      Atom(name: 'LedgerBase.ledgerStatus', context: context);

  @override
  LedgerStatusTypes get ledgerStatus {
    _$ledgerStatusAtom.reportRead();
    return super.ledgerStatus;
  }

  @override
  set ledgerStatus(LedgerStatusTypes value) {
    _$ledgerStatusAtom.reportWrite(value, super.ledgerStatus, () {
      super.ledgerStatus = value;
    });
  }

  late final _$LedgerBaseActionController =
      ActionController(name: 'LedgerBase', context: context);

  @override
  void setDevice(LedgerDevice? device) {
    final _$actionInfo =
        _$LedgerBaseActionController.startAction(name: 'LedgerBase.setDevice');
    try {
      return super.setDevice(device);
    } finally {
      _$LedgerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLedger(Ledger? ledger) {
    final _$actionInfo =
        _$LedgerBaseActionController.startAction(name: 'LedgerBase.setLedger');
    try {
      return super.setLedger(ledger);
    } finally {
      _$LedgerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLedgerStatus(LedgerStatusTypes status) {
    final _$actionInfo = _$LedgerBaseActionController.startAction(
        name: 'LedgerBase.setLedgerStatus');
    try {
      return super.setLedgerStatus(status);
    } finally {
      _$LedgerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
ledgerDevice: ${ledgerDevice},
ledgerInstance: ${ledgerInstance},
ledgerStatus: ${ledgerStatus}
    ''';
  }
}
