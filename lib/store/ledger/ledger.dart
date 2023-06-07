import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:mobx/mobx.dart';

part 'ledger.g.dart';

class LedgerStore = LedgerBase with _$LedgerStore;

enum LedgerStatusTypes { unknown, available, unavailable }

abstract class LedgerBase with Store {
  @observable
  LedgerDevice? ledgerDevice = null;

  @observable
  Ledger? ledgerInstance = null;

  @observable
  LedgerStatusTypes ledgerStatus = LedgerStatusTypes.unknown;

  @action
  void setDevice(LedgerDevice? device) {
    ledgerDevice = device;
  }

  @action
  void setLedger(Ledger? ledger) {
    ledgerInstance = ledger;
  }

  @action
  void setLedgerStatus(LedgerStatusTypes status) {
    ledgerStatus = status;
  }
}
