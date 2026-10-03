import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';

/// Text for a Ledger failure during address retrieval or signing.
/// Connection transport/pairing errors retain their dedicated modal messages.
String ledgerFailureMessage(AppLocalizations dic, LedgerFailureType failure) {
  switch (failure) {
    case LedgerFailureType.rejected:
      return dic.ledgerReject;
    case LedgerFailureType.busy:
      return dic.ledgerBusyTip;
    case LedgerFailureType.locked:
      return dic.unlockLedger;
    case LedgerFailureType.appNotOpen:
      return dic.openMinaApp;
    case LedgerFailureType.unsupported:
      return dic.ledgerZkAppUpdateRequired;
    case LedgerFailureType.pairing:
      return dic.ledgerPairingError;
    case LedgerFailureType.pairingIncomplete:
      return dic.ledgerConnectionError;
    case LedgerFailureType.other:
      return dic.buildFailed;
  }
}
