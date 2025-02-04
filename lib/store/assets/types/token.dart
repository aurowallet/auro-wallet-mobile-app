import 'package:json_annotation/json_annotation.dart';
part 'token.g.dart';

@JsonSerializable()
class Token {
  TokenAssetInfo? tokenAssestInfo;
  TokenNetInfo? tokenNetInfo;
  TokenLocalConfig? localConfig;
  TokenBaseInfo? tokenBaseInfo;

  Token({
    this.tokenAssestInfo,
    this.tokenNetInfo,
    this.localConfig,
    this.tokenBaseInfo,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);

  @override
  String toString() {
    return 'Token(tokenAssestInfo: $tokenAssestInfo, tokenNetInfo: $tokenNetInfo, localConfig: $localConfig, tokenBaseInfo: $tokenBaseInfo)';
  }
}

@JsonSerializable()
class TokenLocalConfig {
  bool? hideToken;
  bool? tokenShowed;

  TokenLocalConfig({
    this.hideToken,
    this.tokenShowed,
  });

  factory TokenLocalConfig.fromJson(Map<String, dynamic> json) =>
      _$TokenLocalConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TokenLocalConfigToJson(this);

  @override
  String toString() {
    return 'TokenLocalConfig(hideToken: $hideToken, tokenShowed: $tokenShowed)';
  }
}

/// ===  TokenAssetInfo
@JsonSerializable()
class TokenAssetInfo {
  final Balance balance;
  String? inferredNonce;
  final DelegateAccount? delegateAccount;
  final String tokenId;
  final String publicKey;
  final String? zkappUri;

  TokenAssetInfo({
    required this.balance,
    this.inferredNonce,
    this.delegateAccount,
    required this.tokenId,
    required this.publicKey,
    this.zkappUri,
  });

  factory TokenAssetInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenAssetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenAssetInfoToJson(this);

  @override
  String toString() {
    return 'TokenAssetInfo(balance: $balance, inferredNonce: $inferredNonce, delegateAccount: $delegateAccount, tokenId: $tokenId, publicKey: $publicKey, zkappUri: $zkappUri)';
  }
}

@JsonSerializable()
class Balance {
  final String total;
  final String liquid;

  Balance({
    required this.total,
    required this.liquid,
  });

  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceToJson(this);

  @override
  String toString() {
    return 'Balance(total: $total, liquid: $liquid)';
  }
}

@JsonSerializable()
class DelegateAccount {
  final String publicKey;

  DelegateAccount({
    required this.publicKey,
  });

  factory DelegateAccount.fromJson(Map<String, dynamic> json) =>
      _$DelegateAccountFromJson(json);

  Map<String, dynamic> toJson() => _$DelegateAccountToJson(this);

  @override
  String toString() {
    return 'DelegateAccount(publicKey: $publicKey)';
  }
}

/// ===  TokenBaseInfo
@JsonSerializable()
class TokenBaseInfo {
  bool? isScam;
  bool? isMainToken;
  bool? isDelegation;
  String? decimals;
  double? showBalance;
  double? showAmount;
  String? iconUrl;

  TokenBaseInfo(
      {this.isScam,
      this.isMainToken,
      this.isDelegation,
      this.decimals,
      this.showBalance,
      this.showAmount,
      this.iconUrl});

  factory TokenBaseInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenBaseInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBaseInfoToJson(this);

  @override
  String toString() {
    return 'TokenBaseInfo(isScam: $isScam, isMainToken: $isMainToken, isDelegation: $isDelegation, decimals: $decimals, showBalance: $showBalance, showAmount: $showAmount, iconUrl: $iconUrl)';
  }
}

/// ===  TokenNetInfo
@JsonSerializable()
class TokenNetInfo {
  final String publicKey;
  final String tokenSymbol;
  final List<String> zkappState;

  TokenNetInfo({
    required this.publicKey,
    required this.tokenSymbol,
    required this.zkappState,
  });

  factory TokenNetInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenNetInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenNetInfoToJson(this);

  @override
  String toString() {
    return 'TokenNetInfo(publicKey: $publicKey, tokenSymbol: $tokenSymbol, zkappState: $zkappState)';
  }
}