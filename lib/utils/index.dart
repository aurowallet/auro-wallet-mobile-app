import 'package:auro_wallet/common/consts/browser.dart';
import 'package:auro_wallet/store/assets/types/token.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';

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
  if (url == null || url.trim().isEmpty) {
    return false;
  }
  url = url.trim();
  final urlRegex = RegExp(
    r'^https?://'
    r'(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}'
    r'(?::[0-9]{1,5})?'
    r'(?:/[^?\s#]*)?'
    r'(?:\?[^#\s]*)?'
    r'(?:#[^\s]*)?$',
    caseSensitive: false,
  );
  if (!urlRegex.hasMatch(url)) {
    return false;
  }
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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
      if (errorMessage.isEmpty &&
          error.length > 1 &&
          error[1] is Map &&
          error[1]['c'] != null) {
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

String getOrigin(String url) {
  final uri = Uri.parse(url);
  return '${uri.scheme}://${uri.host}';
}

CustomNode? findNodeByNetworkId(
  List<CustomNode> defaultNetworkList,
  List<CustomNode> customNodeList,
  String? networkId,
) {
  // First search in defaultNetworkList
  try {
    if (networkId == null) {
      return null; //store.settings!.currentNode;
    }
    final defaultNode = defaultNetworkList.firstWhere(
      (node) => node.networkID == networkId,
    );
    return defaultNode;
  } catch (e) {
    // If not found in default list, search in customNodeList
    try {
      final customNode = customNodeList.firstWhere(
        (node) => node.networkID == networkId,
      );
      return customNode;
    } catch (e) {
      // Return null if not found in either list
      return null;
    }
  }
}

/// Function to get the browser title from a URL
String getBrowserTitle(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.host;
  } catch (e) {
    return url;
  }
}

String getTokenSymbol(TokenNetInfo? tokenNetInfo) {
  return (tokenNetInfo != null && tokenNetInfo.tokenSymbol.isNotEmpty)
      ? tokenNetInfo.tokenSymbol
      : "UNKNOWN";
}
