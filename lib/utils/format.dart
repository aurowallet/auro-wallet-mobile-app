import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auro_wallet/common/consts/settings.dart';
import 'package:auro_wallet/store/staking/types/validatorData.dart';
import 'package:auro_wallet/store/wallet/types/accountData.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/utils/i18n/index.dart';

class Fmt {
  static String address(String? addr, {int pad = 4}) {
    if (addr == null || addr.length == 0) {
      return '';
    }
    return addr.substring(0, pad + 2) + '...' + addr.substring(addr.length - pad);
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
    var dateValue = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(utcTime).toLocal();
    return dateTime(dateValue);
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

  /// combined number transform 1-3:
  /// from raw <String> to <String> in token format of ",##0.000"
  static String balance(
      String? raw,
      int decimals, {
        minLength = 2,
        maxLength = 4
      })
  {
    if (raw == null || raw.length == 0) {
      return '~';
    }
    var balanceBigInt = bigIntToDouble(balanceInt(raw), decimals);
    NumberFormat f = NumberFormat(",##0.${'0' * minLength}${'#'* (maxLength - minLength)}", "en_US");
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
    return '${acc.name.isNotEmpty ? acc.name :  'Account ${acc.accountIndex + 1}'}';
  }

  static String validatorName(BuildContext ctx, String? name) {
    return '${name != null && name.isNotEmpty ? name : 'Block Producer'}';
  }

  static String? breakWord(String? word){
    if(word == null || word.isEmpty){
      return word;
    }
    String breakWord = '';
    word.runes.forEach((element){
      breakWord += String.fromCharCode(element);
      breakWord +='\u200B';
    });
    return breakWord;
  }
  
  static String parseNumber(String number) {
    return number.trim().replaceAll(',', '.');
  }

}
