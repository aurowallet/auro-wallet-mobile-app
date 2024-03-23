import 'package:auro_wallet/common/consts/browser.dart';

String getMessageFromCode(int code,
    [String fallbackMessage = FALLBACK_MESSAGE]) {
  final Map<String, String>? messageMap = errorMessages[code];

  final String? message = messageMap?["message"];

  return message ?? fallbackMessage;
}
