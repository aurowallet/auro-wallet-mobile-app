class Fees extends _Fees {
  static Fees fromJson(Map<String, dynamic> json) {
    Fees data = Fees();
    data.slow = json['slow'] as double;
    data.medium = json['medium'] as double;
    data.fast = json['fast'] as double;
    data.cap = (json['cap'] ?? 0).toDouble();
    return data;
  }
  Fees();
  Fees.fromDefault () {
    slow = 0.001;
    medium = 0.01;
    fast = 0.1;
    cap = 10;
  }

  Map<String, dynamic> toJson() {
    return {
      'slow': this.slow,
      'medium': this.medium,
      'fast': this.fast,
      'cap': this.cap,
    };
  }
}

class _Fees {
  late double slow;

  late double medium;

  late double fast;

  late double cap;
}