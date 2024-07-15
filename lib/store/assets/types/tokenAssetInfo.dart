import 'package:json_annotation/json_annotation.dart';

part 'tokenAssetInfo.g.dart';

@JsonSerializable()
class TokenAssetInfo {
  final Balance balance;
  final String inferredNonce;
  final DelegateAccount? delegateAccount;
  final String tokenId;
  final String publicKey;
  final String? zkappUri;

  TokenAssetInfo({
    required this.balance,
    required this.inferredNonce,
    this.delegateAccount,
    required this.tokenId,
    required this.publicKey,
    this.zkappUri,
  });

  factory TokenAssetInfo.fromJson(Map<String, dynamic> json) => _$TokenAssetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenAssetInfoToJson(this);
}

@JsonSerializable()
class Balance {
  final String total;
  final String liquid;

  Balance({
    required this.total,
    required this.liquid,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => _$BalanceFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceToJson(this);
}

@JsonSerializable()
class DelegateAccount {
  final String publicKey;

  DelegateAccount({
    required this.publicKey,
  });

  factory DelegateAccount.fromJson(Map<String, dynamic> json) => _$DelegateAccountFromJson(json);

  Map<String, dynamic> toJson() => _$DelegateAccountToJson(this);
}