

class ValidatorData extends _ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.name = json['identity_name'] as String?;
    data.address = json['public_key'];
    data.fee = (json['fee'] ?? 0.0).toDouble();
    data.logo = (json['validator_logo'] ?? '') as String;
    data.delegations = (json['delegations'] ?? 0) as int;
    data.totalStake = BigInt.parse((json['stake'] as String?) ?? '0');
    data.blocksCreated = BigInt.from(json['blocks_created'] as int);
    return data;
  }
  static Map<String, dynamic> toJson(ValidatorData data) =>({
    'identity_name': data.name,
    'public_key': data.address,
    'validator_logo': data.logo,
    'fee': data.fee,
    'delegations': data.delegations,
    'stake': data.totalStake.toString(),
    'blocks_created': data.blocksCreated.toInt(),
  });
}

abstract class _ValidatorData {
  String? name = '';
  String address = '';
  String logo = '';
  double fee = 0;
  int delegations = 0;
  BigInt totalStake = BigInt.zero;
  BigInt blocksCreated = BigInt.zero;
}
