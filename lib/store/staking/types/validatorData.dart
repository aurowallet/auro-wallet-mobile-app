

class ValidatorData extends _ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.name = json['identity_name']?.toString();
    data.address = json['public_key']?.toString() ?? '';
    data.fee = (json['fee'] ?? 0.0).toDouble();
    data.logo = json['validator_logo']?.toString() ?? '';
    data.delegations = (json['delegations'] ?? 0) is int ? json['delegations'] : int.tryParse(json['delegations'].toString()) ?? 0;
    // Handle stake as either String or int
    var stakeValue = json['stake'];
    if (stakeValue is String) {
      data.totalStake = BigInt.tryParse(stakeValue) ?? BigInt.zero;
    } else if (stakeValue is int) {
      data.totalStake = BigInt.from(stakeValue);
    } else {
      data.totalStake = BigInt.zero;
    }
    // Handle blocks_created as either int or other types
    var blocksValue = json['blocks_created'];
    if (blocksValue is int) {
      data.blocksCreated = BigInt.from(blocksValue);
    } else if (blocksValue is String) {
      data.blocksCreated = BigInt.tryParse(blocksValue) ?? BigInt.zero;
    } else {
      data.blocksCreated = BigInt.zero;
    }
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
