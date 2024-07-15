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
bool verifyTokenCommand(Map<String, dynamic> sourceData, String sendTokenId, Map<String, dynamic> buildZkCommand) {
  final String sender = sourceData['sender'];
  final String receiver = sourceData['receiver'];
  final int amount = sourceData['amount'];

  bool senderVerified = false;
  bool receiverVerified = false;

  List<dynamic> accountUpdates = buildZkCommand['accountUpdates'];

  for (var accountUpdate in accountUpdates) {
    final Map<String, dynamic> body = accountUpdate['body'];
    final String publicKey = body['publicKey'];
    final String balanceChangeMagnitude = body['balanceChange']['magnitude'];
    final String balanceChangeSgn = body['balanceChange']['sgn'];
    final String tokenId = body['tokenId'];

    if (tokenId == sendTokenId) {
      if (publicKey == sender) {
        if (balanceChangeMagnitude == amount.toString() && balanceChangeSgn == 'Negative') {
          senderVerified = true;
        }
      }

      if (publicKey == receiver) {
        if (balanceChangeMagnitude == amount.toString() && balanceChangeSgn == 'Positive') {
          receiverVerified = true;
        }
      }
    }
  }

  return senderVerified && receiverVerified;
}