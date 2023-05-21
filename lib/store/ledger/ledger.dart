import 'package:ledger_flutter/ledger_flutter.dart';
import 'package:mobx/mobx.dart';

part 'ledger.g.dart';

class LedgerStore = LedgerBase with _$LedgerStore;

abstract class LedgerBase with Store {
  @observable
  LedgerDevice? ledgerDevice = null;

  @observable
  Ledger? ledgerInstance = null;

  @action
  void setDevice(LedgerDevice? device) {
    ledgerDevice = device;
  }

  @action
  void setLedger(Ledger? ledger) {
    ledgerInstance = ledger;
  }
}
