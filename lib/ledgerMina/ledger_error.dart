import 'package:ledger_flutter/ledger_flutter.dart';

import 'ledger_status_code.dart';

enum LedgerFailureType {
  rejected,
  busy,
  locked,
  appNotOpen,
  unsupported,
  pairing,
  other,
}

extension LedgerFailureTypeX on LedgerFailureType {
  /// Busy can settle after pairing; user-action and pairing errors cannot.
  bool get canRetryReadiness =>
      this == LedgerFailureType.busy || this == LedgerFailureType.other;

  /// Generic communication failures resume discovery; other errors wait for
  /// an explicit device-row retry. Rejection is presented as a toast.
  bool get requiresConnectionAction =>
      this != LedgerFailureType.other && this != LedgerFailureType.rejected;
}

LedgerFailureType classifyLedgerErrorCode(int errorCode) {
  switch (errorCode.toUnsigned(16)) {
    // Mina app versions report a user rejection as 0x6985, 0x6986, or
    // 0x5501. Keep these separate from 0x9001, the actual device-busy code.
    case LedgerStatusCode.userRejected:
    case LedgerStatusCode.transactionRejected:
    case LedgerStatusCode.userRefused:
      return LedgerFailureType.rejected;
    case LedgerStatusCode.deviceBusy:
      return LedgerFailureType.busy;
    case LedgerStatusCode.deviceLocked:
      return LedgerFailureType.locked;
    case LedgerStatusCode.mobileMinaAppNotOpen:
    case LedgerStatusCode.minaAppNotOpen:
      return LedgerFailureType.appNotOpen;
    case LedgerStatusCode.instructionUnsupported:
    case LedgerStatusCode.claUnsupported:
      return LedgerFailureType.unsupported;
    default:
      return LedgerFailureType.other;
  }
}

LedgerFailureType classifyLedgerError(Object error) {
  final failure = error is LedgerException
      ? classifyLedgerErrorCode(error.errorCode)
      : LedgerFailureType.other;
  final message = error is LedgerException ? error.message : '$error';
  return isLedgerPairingMismatch(failure, message)
      ? LedgerFailureType.pairing
      : failure;
}

/// A text match is only a fallback for platform errors that have no known
/// Ledger APDU status. Status words always carry the more specific cause.
bool isLedgerPairingMismatch(LedgerFailureType failure, String message) {
  if (failure != LedgerFailureType.other) {
    return false;
  }
  final normalized = message.toLowerCase();
  return normalized.contains('peer removed pairing information') ||
      (normalized.contains('cberror') &&
          RegExp(r'\bcode\s*=?\s*14\b').hasMatch(normalized));
}

/// Logs failed Ledger operations without exposing device IDs, addresses, APDU
/// payloads, transaction bodies, or signatures.
void ledgerErrorLog(String stage, Object error, {StackTrace? stackTrace}) {
  final ledgerError = error is LedgerException ? error : null;
  final code = ledgerError?.errorCode;
  final codeText = code == null
      ? 'none'
      : '$code (0x${code.toUnsigned(16).toRadixString(16).padLeft(4, '0')})';
  final failure = classifyLedgerError(error);
  final message = ledgerError?.message;
  final detail = message == null || message.isEmpty
      ? error.toString()
      : message;
  final trace = stackTrace?.toString().split('\n').take(5).join('\n');
  print(
    '[LEDGER-ERROR] stage=$stage type=${error.runtimeType} '
    'code=$codeText failure=$failure message=$detail'
    '${trace == null ? '' : '\n$trace'}',
  );
}
