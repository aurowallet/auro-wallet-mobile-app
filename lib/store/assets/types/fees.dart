import 'package:auro_wallet/common/consts/index.dart';

class Fees extends _Fees {
  static Fees fromJson(Map<String, dynamic> json) {
    Fees data = Fees();
    data.slow = json['slow'] as double;
    data.medium = json['medium'] as double;
    data.fast = json['fast'] as double;
    data.cap = (json['cap'] ?? 0).toDouble();
    data.speedup = (json['speedup'] ?? 0).toDouble();
    data.accountupdate = (json['accountupdate'] ?? 0).toDouble();
    return data;
  }

  Fees();
  Fees.fromDefault() {
    slow = defaultTxFees.slow;
    medium = defaultTxFees.medium;
    fast = defaultTxFees.fast;
    cap = defaultTxFees.cap;
    speedup = defaultTxFees.speedup;
    accountupdate = defaultTxFees.accountupdate;
  }

  Map<String, dynamic> toJson() {
    return {
      'slow': this.slow,
      'medium': this.medium,
      'fast': this.fast,
      'cap': this.cap,
      'speedup': this.speedup,
      'accountupdate': this.accountupdate,
    };
  }
}

class _Fees {
  late double slow;

  late double medium;

  late double fast;

  late double cap;

  late double speedup;

  late double accountupdate;
}
