import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/app.dart';

class Fmt {
  static String address(String? addr, {int pad = 4, bool padSame = false}) {
    if (addr == null || addr.length == 0) {
      return '';
    }
    return addr.substring(0, pad) + '...' + addr.substring(addr.length - pad);
  }

  static String dateTime(DateTime? time) {
    if (time == null) {
      return 'date-time';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(time);
  }

  static String dateTimeFromUTC(String? utcTime) {
    if (utcTime == null || utcTime.isEmpty) {
      return "";
    }
    var dateValue =
        new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(utcTime).toLocal();
    return dateTime(dateValue);
  }

  static DateTime toDatetime(String dateTimeStr) {
    return new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(dateTimeStr);
  }

  static String dateTimeWithTimeZone(String? utcTime) {
    if (utcTime == null || utcTime.isEmpty) {
      return "";
    }
    var dateValue =
        new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(utcTime).toLocal();
    var str = dateTime(dateValue);
    var timeZone = dateValue.timeZoneOffset.toString().split(':');
    return str +
        ' GMT' +
        (dateValue.timeZoneOffset.isNegative ? '-' : '+') +
        timeZone[0].padLeft(2, '0') +
        timeZone[1].padLeft(2, '0');
  }
  static String dateTimeWithTimeZoneFromTimestamp(int? timestamp) {
    if (timestamp == null) {
      return "";
    }
    var dateValue = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal();
    var str = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateValue);
    var timeZone = dateValue.timeZoneOffset.toString().split(':');
    var timeZoneOffset = '${dateValue.timeZoneOffset.isNegative ? '-' : '+'}'
        '${timeZone[0].padLeft(2, '0')}${timeZone[1].padLeft(2, '0')}';
    return '$str GMT$timeZoneOffset';
  }

  /// number transform 1:
  /// from raw <String> of Api data to <BigInt>
  static BigInt balanceInt(String? raw) {
    if (raw == null || raw.length == 0) {
      return BigInt.zero;
    }
    if (raw.contains(',') || raw.contains('.')) {
      return BigInt.from(NumberFormat(",##0.000").parse(raw));
    } else {
      return BigInt.parse(raw);
    }
  }

  /// number transform 2:
  /// from <BigInt> to <double>
  static double bigIntToDouble(BigInt? value, int decimals) {
    if (value == null) {
      return 0;
    }
    return value / BigInt.from(pow(10, decimals));
  }

  /// number transform 3:
  /// from <double> to <String> in token format of ",##0.000"
  static String doubleFormat(
    double? value, {
    int length = 3,
    int round = 0,
  }) {
    if (value == null) {
      return '~';
    }
    value.toStringAsFixed(3);
    NumberFormat f =
        NumberFormat(",##0${length > 0 ? '.' : ''}${'0' * length}", "en_US");
    return f.format(value);
  }

  static String balance(String? raw, int decimals,
      {minLength = 2, maxLength = 4}) {
    if (raw == null || raw.length == 0) {
      return '~';
    }
    var balanceBigInt = bigIntToDouble(balanceInt(raw), decimals);
    NumberFormat f = NumberFormat(
        ",##0.${'0' * minLength}${'#' * (maxLength - minLength)}", "en_US");
    return f.format(balanceBigInt);
  }

  static String balanceToInteger(String? raw, int decimals) {
    if (raw == null || raw.length == 0) {
      return '~';
    }
    var balanceBigInt = bigIntToDouble(balanceInt(raw), decimals);
    NumberFormat f = NumberFormat(",##0", "en_US");
    return f.format(balanceBigInt);
  }

  /// combined number transform 1-2:
  /// from raw <String> to <double>
  static double balanceDouble(String raw, int decimals) {
    return bigIntToDouble(balanceInt(raw), decimals);
  }

  /// number transform 5:
  /// from <BigInt> to <String> in price format of ",##0.00"
  /// ceil number of last decimal
  static String priceCeil(
    double? value, {
    int lengthFixed = 2,
    int? lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    final int x = pow(10, lengthMax ?? lengthFixed) as int;
    final double price = (value * x).ceilToDouble() / x;
    final String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    return NumberFormat(
            ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
            "en_US")
        .format(price);
  }

  /// number transform 6:
  /// from <BigInt> to <String> in price format of ",##0.00"
  /// floor number of last decimal
  static String priceFloor(
    double? value, {
    int lengthFixed = 2,
    int? lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    final int x = pow(10, lengthMax ?? lengthFixed) as int;
    final double price = (value * x).floorToDouble() / x;
    final String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    return NumberFormat(
            ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
            "en_US")
        .format(price);
  }

  /// number transform 7:
  /// from number to <String> in price format of ",##0.###%"
  static String ratio(dynamic number, {bool needSymbol = true}) {
    NumberFormat f = NumberFormat(",##0.###${needSymbol ? '%' : ''}");
    return f.format(number ?? 0);
  }

  static String priceCeilBigInt(
    BigInt? value,
    int decimals, {
    int lengthFixed = 2,
    int? lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    return priceCeil(Fmt.bigIntToDouble(value, decimals),
        lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static String priceFloorBigInt(
    BigInt? value,
    int decimals, {
    int lengthFixed = 2,
    int? lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    return priceFloor(Fmt.bigIntToDouble(value, decimals),
        lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static bool isAddress(String txt) {
    var reg = RegExp(r'^B62[A-z\d]{52}$');
    return reg.hasMatch(txt);
  }

  static bool isHexString(String hex) {
    var reg = RegExp(r'^[a-f0-9]+$');
    return reg.hasMatch(hex);
  }

  static bool checkPassword(String pass) {
    var reg = RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[\S]{6,20}$');
    return reg.hasMatch(pass);
  }

  static String accountName(AccountData acc) {
    return '${acc.name.isNotEmpty ? acc.name : 'Account ${acc.accountIndex + 1}'}';
  }

  static String validatorName(BuildContext ctx, String? name) {
    return '${name != null && name.isNotEmpty ? name : 'Block Producer'}';
  }

  static String? breakWord(String? word) {
    if (word == null || word.isEmpty) {
      return word;
    }
    String breakWord = '';
    word.runes.forEach((element) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    });
    return breakWord;
  }

  static String parseNumber(String number) {
    return number.trim().replaceAll(',', '.');
  }

  static String stringSlice(String str, int len,
      {withEllipsis = false, ellipsisCounted = false}) {
    var counter = 0;
    for (int i = 0; i < str.length; i++) {
      if (str.codeUnitAt(i) > 122) {
        counter += 2;
      } else {
        counter += 1;
      }
      if (counter >= len) {
        if (withEllipsis && i < str.length - 1) {
          return str.substring(0, i + 1 - (ellipsisCounted ? 3 : 0)) + '...';
        }
        return str.substring(0, i + 1);
      }
    }
    return str.substring(0, str.length);
  }

  static String hexToAscii(String hexString) => List.generate(
        hexString.length ~/ 2,
        (i) => String.fromCharCode(
            int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
      ).join();

  static bool isNumber(dynamic value) {
    try {
      if (value == null) {
        return false;
      }
      if (value is int || value is double) {
        return true; // It's a numeric type (int or double)
      }
      // Check if it's a String that can be parsed to a number
      if (value is String) {
        return double.tryParse(value) != null;
      }
      return false; // It's neither int, double, nor a string that can be parsed to a number
    } catch (e) {
      return false;
    }
  }

  static String amountDecimals(String amount, {int decimal = 0}) {
    // 解决精度问题
    // If decimal is bigger than 100, use 0
    int nextDecimals = decimal;
    if (BigInt.parse(nextDecimals.toString()) > BigInt.from(100)) {
      nextDecimals = 0;
    }
    Decimal amout1 = Decimal.parse(amount);
    Decimal amout2 = Decimal.fromBigInt(BigInt.from(10).pow(nextDecimals));
    double realBalance = (amout1 / amout2).toDouble();
    return realBalance.toString();
  }

  static String parseShowBalance(double balance, {int showLength = 4}) {
    String formatted = balance.toStringAsFixed(showLength);
    formatted = formatted.contains('.')
        ? formatted
            .replaceFirst(RegExp(r'0*$'), '')
            .replaceFirst(RegExp(r'\.$'), '')
        : formatted;
    return formatted;
  }
}

String prettyPrintJson(jsonString) {
  var jsonObject = jsonDecode(jsonString);
  String prettyString = _printJson(jsonObject);

  return prettyString;
}

String _printJson(jsonObject, {int indent = 0}) {
  String prettyString = "";
  if (jsonObject is Map) {
    prettyString += "{\n";
    int index = 0;
    jsonObject.forEach((key, value) {
      if (value is String) {
        prettyString += "${" " * (indent + 2)}\"$key\": \"$value\"";
      } else {
        prettyString +=
            "${" " * (indent + 2)}\"$key\": ${_printJson(value, indent: indent + 2)}";
      }
      if (index < jsonObject.length - 1) {
        prettyString += ",\n";
      } else {
        prettyString += "\n";
      }
      index++;
    });
    prettyString += "${" " * indent}}";
  } else if (jsonObject is List) {
    prettyString += "[\n";
    for (var i = 0; i < jsonObject.length; i++) {
      prettyString +=
          "${" " * (indent + 2)}${_printJson(jsonObject[i], indent: indent + 2)}";
      if (i < jsonObject.length - 1) {
        prettyString += ",\n";
      } else {
        prettyString += "\n";
      }
    }
    prettyString += "${" " * indent}]";
  } else {
    prettyString += jsonObject.toString();
  }
  return prettyString;
}
