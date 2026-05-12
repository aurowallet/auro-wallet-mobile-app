class Fees extends _Fees {
  static const int defaultVersion = 1;
  static const double defaultSlowFee = 0.0011;
  static const double defaultMediumFee = 0.0101;
  static const double defaultFastFee = 0.2001;
  static const double defaultFeeCap = 10;
  static const double defaultSpeedUpBuffer = 0.5;
  static const double defaultZkAppAccountUpdateFee = 0.002;

  static Fees fromJson(Map<String, dynamic> json) {
    return tryParse(json) ?? Fees.fromDefault();
  }

  static Fees? tryParse(dynamic value) {
    if (value is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(value);
    final rawTransactionFee = json['transactionFee'];
    final transactionFee = rawTransactionFee is Map
        ? Map<String, dynamic>.from(rawTransactionFee)
        : null;

    final data = Fees.fromDefault();
    data.version = _parseInt(json['version']) ?? data.version;
    data.slow =
        _parseDouble(transactionFee?['slow'] ?? json['slow']) ?? data.slow;
    data.medium =
        _parseDouble(transactionFee?['medium'] ?? json['medium']) ??
            data.medium;
    data.fast =
        _parseDouble(transactionFee?['fast'] ?? json['fast']) ?? data.fast;
    data.feeCap = _parseDouble(json['feeCap']) ?? data.feeCap;
    data.speedUpBuffer =
        _parseDouble(json['speedUpBuffer']) ?? data.speedUpBuffer;
    data.zkAppAccountUpdateFee =
        _parseDouble(json['zkAppAccountUpdateFee']) ??
            data.zkAppAccountUpdateFee;
    return data;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Fees.fromDefault() : super._init();

  bool isFeeExceedsCap(String feeText) {
    if (feeText.isEmpty) return false;
    final parsed = double.tryParse(feeText);
    if (parsed == null) return false;
    return parsed >= feeCap;
  }

  bool isFeeExceedsCapValue(double fee) {
    return fee >= feeCap;
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'transactionFee': {
        'slow': slow,
        'medium': medium,
        'fast': fast,
      },
      'feeCap': feeCap,
      'speedUpBuffer': speedUpBuffer,
      'zkAppAccountUpdateFee': zkAppAccountUpdateFee,
    };
  }
}

class _Fees {
  late int version;

  late double slow;

  late double medium;

  late double fast;

  late double feeCap;

  late double speedUpBuffer;

  late double zkAppAccountUpdateFee;

  _Fees._init() {
    version = Fees.defaultVersion;
    slow = Fees.defaultSlowFee;
    medium = Fees.defaultMediumFee;
    fast = Fees.defaultFastFee;
    feeCap = Fees.defaultFeeCap;
    speedUpBuffer = Fees.defaultSpeedUpBuffer;
    zkAppAccountUpdateFee = Fees.defaultZkAppAccountUpdateFee;
  }
}
