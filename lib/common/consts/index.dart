import 'package:auro_wallet/store/assets/types/fees.dart';

Map<String, double> defaultTxFeesMap = {
  "slow": 0.0011,
  "medium": 0.0101,
  "fast": 0.2001,
  "cap": 10,
  'speedup': 0.5,
  "accountupdate": 0.002
};

Fees defaultTxFees = Fees.fromJson(defaultTxFeesMap);