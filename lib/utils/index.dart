import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/store/assets/types/token.dart';

String getMessageFromCode(int code,
    [String fallbackMessage = FALLBACK_MESSAGE]) {
  final Map<String, String>? messageMap = errorMessages[code];

  final String? message = messageMap?["message"];

  return message ?? fallbackMessage;
}

int compareTokens(Token a, Token b) {
  double? amountA = a.tokenBaseInfo?.showAmount;
  double? amountB = b.tokenBaseInfo?.showAmount;

  if (amountA != null && amountB != null) {
    if (amountA > amountB) {
      return -1;
    } else if (amountA < amountB) {
      return 1;
    }
  } else if (amountA != null) {
    return -1;
  } else if (amountB != null) {
    return 1;
  }

  double balanceA = a.tokenBaseInfo?.showBalance ?? 0;
  double balanceB = b.tokenBaseInfo?.showBalance ?? 0;

  if (balanceA > balanceB) {
    return -1;
  } else if (balanceA < balanceB) {
    return 1;
  } else {
    String symbolA = a.tokenNetInfo?.tokenSymbol ?? "";
    String symbolB = b.tokenNetInfo?.tokenSymbol ?? "";
    return symbolA.compareTo(symbolB);
  }
}

/// check token build body
bool verifyTokenCommand(Map<String, dynamic> sourceData, String sendTokenId,
    Map<String, dynamic> buildZkCommand) {
  final String sender = sourceData['sender'];
  final String receiver = sourceData['receiver'];
  final num amount = sourceData['amount'];
  final double sourceAmount = amount.toDouble();

  bool senderVerified = false;
  bool receiverVerified = false;

  List<dynamic> accountUpdates = buildZkCommand['accountUpdates'];

  for (var accountUpdate in accountUpdates) {
    final Map<String, dynamic> body = accountUpdate['body'];
    final String publicKey = body['publicKey'];
    final String balanceChangeMagnitude = body['balanceChange']['magnitude'];
    final double changeBalance = double.parse(balanceChangeMagnitude);
    final String balanceChangeSgn = body['balanceChange']['sgn'];
    final String tokenId = body['tokenId'];

    if (tokenId == sendTokenId) {
      if (publicKey == sender) {
        if (changeBalance == sourceAmount && balanceChangeSgn == 'Negative') {
          senderVerified = true;
        }
      }

      if (publicKey == receiver) {
        if (changeBalance == sourceAmount && balanceChangeSgn == 'Positive') {
          receiverVerified = true;
        }
      }
    }
  }

  return senderVerified && receiverVerified;
}

String getReadableNetworkId(String networkId) {
  return networkId.replaceAll(':', '_');
}

bool isValidHttpUrl(String? url) {
  try {
    if (url == null || url.isEmpty) {
      return false;
    }
    if (!url.startsWith('http')||!url.startsWith('https')) {
      return false;
    }
    if (url.endsWith('.')) {
      return false;
    }
    List<String> parts = url.split('.');
    if (parts.length < 2) {
      return false;
    }
    for (int i = 0; i < parts.length - 1; i++) {
      if (parts[i].isNotEmpty && parts[i + 1].isNotEmpty) {
        return true;
      }
    }
    return false;
  } catch (e) {
    return true;
  }
}

String getRealErrorMsg(dynamic error) {
  String errorMessage = '';

  try {
    if (error is Error) {
      errorMessage = error.toString();
    } else if (error is Map && error['message'] != null) {
      errorMessage = error['message'];
    } else if (error is List && error.isNotEmpty) {
      // PostError handling
      if (error[0] is Map && error[0]['message'] != null) {
        errorMessage = error[0]['message'];
      }
      // BuildError handling
      if (errorMessage.isEmpty && error.length > 1 && error[1] is Map && error[1]['c'] != null) {
        errorMessage = error[1]['c'];
      }
    } else if (error is String) {
      int lastErrorIndex = error.lastIndexOf('Error:');
      if (lastErrorIndex != -1) {
        errorMessage = error.substring(lastErrorIndex);
      } else {
        errorMessage = error;
      }
    }
  } catch (e) {
    // Catching any unexpected errors
  }

  return errorMessage;
}