/// Status codes used by the Mina application and Ledger error handling.
abstract final class LedgerStatusCode {
  static const errorExecution = 0x6400;
  static const errorEmptyBuffer = 0x6982;
  static const errorOutputBufferTooSmall = 0x6983;
  static const errorUnknown = 0x6F00;

  static const success = 0x9000;

  static const userRejected = 0x6985;
  static const transactionRejected = 0x6986;
  static const userRefused = 0x5501;
  static const deviceBusy = 0x9001;
  static const deviceLocked = 0x5515;
  static const mobileMinaAppNotOpen = 0x6511;
  static const minaAppNotOpen = 0x6e01;
  static const instructionUnsupported = 0x6d00;
  static const claUnsupported = 0x6e00;
}
