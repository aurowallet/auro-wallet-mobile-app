class ErrorCodes {
  static const int userRejectedRequest = 1002;
  static const int userDisconnect = 1001;
  static const int noWallet = 20001;
  static const int verifyFailed = 20002;
  static const int invalidParams = 20003;
  static const int notSupportChain = 20004;
  static const int zkChainPending = 20005;
  static const int unsupportMethod = 20006;
  static const int internal = 21001;
  static const int throwError = 22001;
  static const int originDismatch = 23001;
  static const int notFound = 404;
}

const String FALLBACK_MESSAGE =
    "Unspecified error message. This is a bug, please report it.";

const Map<int, Map<String, String>> errorMessages = {
  ErrorCodes.userRejectedRequest: {
    "message": "User rejected the request.",
  },
  ErrorCodes.userDisconnect: {
    "message": "User disconnect, please connect first.",
  },
  ErrorCodes.noWallet: {
    "message": "Please create or restore wallet first.",
  },
  ErrorCodes.verifyFailed: {
    "message": "Verify failed.",
  },
  ErrorCodes.invalidParams: {
    "message": "Invalid method parameter(s).",
  },
  ErrorCodes.notSupportChain: {
    "message": "Not support chain.",
  },
  ErrorCodes.zkChainPending: {
    "message": "Request already pending. Please wait.",
  },
  ErrorCodes.unsupportMethod: {
    "message": "Method not supported.",
  },
  ErrorCodes.internal: {
    "message": "Transaction error.",
  },
  ErrorCodes.throwError: {
    "message": FALLBACK_MESSAGE,
  },
  ErrorCodes.originDismatch: {
    "message": "Origin dismatch.",
  },
  ErrorCodes.notFound: {
    "message": "Not found.",
  },
};
