import 'dart:convert';

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/browser/types/zkApp.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';

const String zkEmptyPublicKey =
    "B62qiTKpEPjGTSHZrtM8uXiKgn8So916pLmNJKDhKeyBQL9TDb3nvBG";
const String zkDefaultTokenId =
    "wSHV2S4qX9jFsLjQo8r1BsMLH2ZRKsZx6EJd1sbozGPieEC4Jf";

TransactionDetail getFormatFeePayerV2(
    Map<dynamic, dynamic> zkappCommand, String currentAddress) {
  var feePayer = zkappCommand['feePayer'];
  String feePayerKey = feePayer['body']['publicKey'].toString();
  if (feePayerKey.toLowerCase() == zkEmptyPublicKey.toLowerCase()) {
    feePayerKey = currentAddress;
  }
  var fee = feePayer['body']['fee'].toString();
  fee = Fmt.balance(fee.toString(), COIN.decimals, maxLength: COIN.decimals);

  return TransactionDetail(
    label: "feePayer",
    children: [
      Detail(label: "publicKey", value: Fmt.address(feePayerKey, pad: 10)),
      Detail(label: "fee", value: "$fee ${COIN.coinSymbol}"),
    ],
  );
}

List<dynamic> getZkInfo(String zkappCommand, String currentAddress) {
  try {
    Map<String, dynamic> nextZkCommand = jsonDecode(zkappCommand);
    var feePayerBody = getFormatFeePayerV2(nextZkCommand, currentAddress);
    var accountUpdateBody = getUpdateBody(nextZkCommand);
    return [feePayerBody.toJson(), accountUpdateBody.toJson()];
  } catch (error) {
    return [
      {"label": "Error", "value": error.toString()}
    ];
  }
}

String zkCommandFormat(dynamic zkAppCommand) {
  return jsonEncode(zkAppCommand);
}

String getZkFee(String zkappCommand) {
  try {
    Map<dynamic, dynamic> nextZkCommand = jsonDecode(zkappCommand);
    var feePayer = nextZkCommand['feePayer'];
    var fee = feePayer['body']['fee'].toString();
    return Fmt.balance(fee.toString(), COIN.decimals, maxLength: COIN.decimals);
  } catch (error) {
    return "";
  }
}
String getZkMemo(String zkappCommand) {
  try {
    Map<dynamic, dynamic> nextZkCommand = jsonDecode(zkappCommand);
    var memo = nextZkCommand['memo'];
    if(memo!= null){
      memo = bs58Decode(memo);
    }
    return memo;
  } catch (error) {
    return "";
  }
}


AccountUpdateInfo getUpdateBody(Map<String, dynamic> zkappCommand) {
  List<dynamic> accountUpdates = zkappCommand['accountUpdates'];
  List<AccountDetail> children = [];

  for (int index = 0; index < accountUpdates.length; index++) {
    var accountItemBody = accountUpdates[index]['body'];
    var publicKey = accountItemBody['publicKey'];
    var tokenId = accountItemBody['tokenId'] ??
        zkDefaultTokenId;
    var balanceChangeBody = accountItemBody['balanceChange'];
    var balanceChangeOperator =
        balanceChangeBody['sgn'].toLowerCase() == "negative" ? "-" : "+";

    var balanceChange = balanceChangeOperator +
        Fmt.balance(balanceChangeBody['magnitude'].toString(), COIN.decimals,
            maxLength: COIN.decimals);
    var tokenSymbol = tokenId == zkDefaultTokenId
        ? COIN.coinSymbol
        : "UNKNOWN";

    if (tokenId != zkDefaultTokenId &&
        accountItemBody.containsKey('update') &&
        accountItemBody['update']['tokenSymbol'] != null) {
      tokenSymbol = accountItemBody['update']['tokenSymbol'];
    }

    children.add(AccountDetail(
      label: "Account #${index + 1}",
      children: [
        Detail(label: "publicKey", value: Fmt.address(publicKey, pad: 10)),
        Detail(label: "tokenId", value: Fmt.address(tokenId, pad: 10)),
        Detail(label: "balanceChange", value: "$balanceChange $tokenSymbol"),
      ],
    ));
  }

  return AccountUpdateInfo(label: "accountUpdates", children: children);
}

String getContractAddress(String tx) {
  try {
    if (tx.isEmpty) return "";

    final Map<String, dynamic> realTx = jsonDecode(tx);
    final List<dynamic> accountUpdates = realTx['accountUpdates'] ?? [];

    for (final update in accountUpdates) {
      if (update['authorization'] != null &&
          update['authorization']['proof'] != null) {
        return update['body']['publicKey'] ?? "";
      }
    }
  } catch (error) {
    print("Error parsing transaction: $error");
  }
  return "";
}
