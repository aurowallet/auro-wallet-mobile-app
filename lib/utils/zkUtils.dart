import 'dart:convert';

import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/common/consts/token.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:auro_wallet/store/browser/types/zkApp.dart';
import 'package:auro_wallet/utils/format.dart';
import 'package:auro_wallet/walletSdk/minaSDK.dart';
import 'package:decimal/decimal.dart';

const String zkEmptyPublicKey =
    "B62qiTKpEPjGTSHZrtM8uXiKgn8So916pLmNJKDhKeyBQL9TDb3nvBG";

TransactionDetail getFormatFeePayerV2(
    dynamic zkappCommand, String currentAddress) {
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
    dynamic nextZkCommand = jsonDecode(zkappCommand);
    nextZkCommand = jsonDecode(nextZkCommand);
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
    dynamic nextZkCommand = jsonDecode(zkappCommand);
    nextZkCommand = jsonDecode(nextZkCommand);
    var feePayer = nextZkCommand['feePayer'];
    var fee = feePayer['body']['fee'].toString();
    Decimal nextFee = Decimal.parse(fee);
    if (nextFee <= Decimal.zero) {
      return "";
    }
    return Fmt.balance(fee, COIN.decimals, maxLength: COIN.decimals);
  } catch (error) {
    return "";
  }
}

String getZkMemo(String zkappCommand) {
  try {
    Map<dynamic, dynamic> nextZkCommand = jsonDecode(zkappCommand);
    var memo = nextZkCommand['memo'];
    if (memo != null) {
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
    var tokenId = accountItemBody['tokenId'] ?? ZK_DEFAULT_TOKEN_ID;
    var balanceChangeBody = accountItemBody['balanceChange'];
    var balanceChangeOperator =
        balanceChangeBody['sgn'].toLowerCase() == "negative" ? "-" : "+";

    var balanceChange = balanceChangeOperator +
        Fmt.balance(balanceChangeBody['magnitude'].toString(), COIN.decimals,
            maxLength: COIN.decimals);
    var tokenSymbol =
        tokenId == ZK_DEFAULT_TOKEN_ID ? COIN.coinSymbol : "UNKNOWN";

    if (tokenId != ZK_DEFAULT_TOKEN_ID &&
        accountItemBody.containsKey('update') &&
        accountItemBody['update']['tokenSymbol'] != null) {
      tokenSymbol = accountItemBody['update']['tokenSymbol'];
    }
    List<Detail> tempDetail = [];
    tempDetail.add(
        Detail(label: "publicKey", value: Fmt.address(publicKey, pad: 10)));
    if (tokenId != ZK_DEFAULT_TOKEN_ID) {
      tempDetail
          .add(Detail(label: "tokenId", value: Fmt.address(tokenId, pad: 10)));
    }
    tempDetail.add(
        Detail(label: "balanceChange", value: "$balanceChange $tokenSymbol"));
    children.add(
        AccountDetail(label: "Account #${index + 1}", children: tempDetail));
  }

  return AccountUpdateInfo(label: "accountUpdates", children: children);
}

String getContractAddress(String tx, String currentAccount) {
  try {
    if (tx.isEmpty) return "";
    final dynamic realTx = jsonDecode(tx);
    final dynamic realTxTemp = jsonDecode(realTx);
    final List<dynamic> accountUpdates = realTxTemp['accountUpdates'] ?? [];
    final firstZKapp = accountUpdates.firstWhere(
      (update) =>
          update['authorization'] != null &&
          update['authorization']['proof'] != null,
      orElse: () => null,
    );
    if (firstZKapp != null &&
        firstZKapp['body'] != null &&
        firstZKapp['body']['publicKey'] is String) {
      return firstZKapp['body']['publicKey'];
    }
    if (firstZKapp == null) {
      final firstDifferentPublicKey = accountUpdates.firstWhere(
        (update) =>
            update['body'] != null &&
            update['body']['publicKey'] != currentAccount,
        orElse: () => null,
      );
      if (firstDifferentPublicKey != null &&
          firstDifferentPublicKey['body'] != null &&
          firstDifferentPublicKey['body']['publicKey'] is String) {
        return firstDifferentPublicKey['body']['publicKey'];
      }
    }
  } catch (error) {
    print("Error parsing transaction: $error");
  }
  return "";
}

List<TransferData> tokenHistoryFilter(List<TransferData> list, String tokenId) {
  if (tokenId.isEmpty) {
    return list;
  }
  List<TransferData> newList = [];
  for (var txItem in list) {
    if (txItem.transaction != null) {
      Map nextTransaction = jsonDecode(txItem.transaction!);

      if (nextTransaction['accountUpdates'] != null) {
        var accountUpdates = nextTransaction['accountUpdates'];
        var targetIndex = accountUpdates.indexWhere(
            (updateItem) => updateItem['body']['tokenId'] == tokenId);
        if (targetIndex != -1) {
          newList.add(txItem);
        }
      }
    }
  }
  return newList;
}

/// get accoutUpdate count to calc zk tx fee
int getAccountUpdateCount(String zkappCommand) {
  dynamic nextZkCommand = jsonDecode(zkappCommand);
  nextZkCommand = jsonDecode(nextZkCommand);
  List<dynamic> accountUpdates = nextZkCommand['accountUpdates'];
  return accountUpdates.length;
}

Map<String, dynamic> getZkAppUpdateInfo(
  List<dynamic> accountUpdates,
  String publicKey,
  String feePayer,
  String tokenId,
) {
  try {
    if (accountUpdates.isEmpty) {
      return {
        'totalBalanceChange': '0',
        'symbol': '',
        'updateCount': '-',
        'from': '-',
        'to': '-',
        "isZkReceive": true
      };
    }
    String totalBalanceChange = '0';
    List<Map<String, String>> updateList = [];
    List<Map<String, String>> otherList = [];

    for (var update in accountUpdates) {
      var body = update['body'];
      String magnitude =
          Decimal.parse(body['balanceChange']['magnitude']).abs().toString();
      if (body['tokenId'] == tokenId) {
        if (body['publicKey'] == publicKey) {
          if (body['balanceChange']['sgn'] == 'Negative') {
            totalBalanceChange =
                (Decimal.parse(totalBalanceChange) - Decimal.parse(magnitude))
                    .toString();
          } else if (body['balanceChange']['sgn'] == 'Positive') {
            totalBalanceChange =
                (Decimal.parse(totalBalanceChange) + Decimal.parse(magnitude))
                    .toString();
          }
        } else {
          if (double.parse(magnitude) != 0) {
            updateList.add({
              'address': body['publicKey'],
              'amount': magnitude,
            });
          }
        }
      }

      if (body['tokenId'] != tokenId) {
        otherList.add({
          'address': body['publicKey'],
          'amount': magnitude,
        });
      }
    }

    if (updateList.isNotEmpty) {
      updateList.sort((a, b) =>
          Decimal.parse(b['amount']!).compareTo(Decimal.parse(a['amount']!)));
    }
    if (otherList.isNotEmpty) {
      otherList.sort((a, b) =>
          Decimal.parse(b['amount']!).compareTo(Decimal.parse(a['amount']!)));
    }

    String symbol = '';
    String from = '';
    String to = '';
    bool isZkReceive = false;
    if (Decimal.parse(totalBalanceChange) > Decimal.zero) {
      symbol = '+';
      from = updateList.isNotEmpty
          ? updateList[0]['address']!
          : otherList[0]['address']!;
      to = publicKey;
      isZkReceive = true;
    } else if (Decimal.parse(totalBalanceChange) < Decimal.zero) {
      symbol = '-';
      totalBalanceChange = Decimal.parse(totalBalanceChange).abs().toString();
      from = publicKey;
      to = updateList.isNotEmpty
          ? updateList[0]['address']!
          : otherList[0]['address']!;
      isZkReceive = false;
    } else {
      if (updateList.isNotEmpty) {
        Map<String, String> result = updateList.firstWhere(
          (item) => item['address'] != feePayer,
          orElse: () => {'address': '', 'amount': ''},
        );
        if (result['address'] != '') {
          to = result['address']!;
        } else {
          to = publicKey;
        }
      } else {
        Map<String, String> result = otherList.firstWhere(
          (item) => item['address'] != feePayer,
          orElse: () => {'address': '', 'amount': ''},
        );
        if (result['address'] != '') {
          to = result['address']!;
        } else {
          to = publicKey;
        }
      }
      from = feePayer;
    }

    return {
      'totalBalanceChange': totalBalanceChange,
      'symbol': symbol,
      'updateCount': accountUpdates.length.toString(),
      'from': from,
      'to': to,
      "isZkReceive": isZkReceive
    };
  } catch (e) {
    return {
      'totalBalanceChange': '0',
      'symbol': '',
      'updateCount': '-',
      'from': '-',
      'to': '-',
      "isZkReceive": true
    };
  }
}
