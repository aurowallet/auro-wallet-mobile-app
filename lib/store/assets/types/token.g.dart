// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      tokenAssestInfo: json['tokenAssestInfo'] == null
          ? null
          : TokenAssetInfo.fromJson(
              json['tokenAssestInfo'] as Map<String, dynamic>),
      tokenNetInfo: json['tokenNetInfo'] == null
          ? null
          : TokenNetInfo.fromJson(json['tokenNetInfo'] as Map<String, dynamic>),
      localConfig: json['localConfig'] == null
          ? null
          : TokenLocalConfig.fromJson(
              json['localConfig'] as Map<String, dynamic>),
      tokenBaseInfo: json['tokenBaseInfo'] == null
          ? null
          : TokenBaseInfo.fromJson(
              json['tokenBaseInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'tokenAssestInfo': instance.tokenAssestInfo,
      'tokenNetInfo': instance.tokenNetInfo,
      'localConfig': instance.localConfig,
      'tokenBaseInfo': instance.tokenBaseInfo,
    };

TokenLocalConfig _$TokenLocalConfigFromJson(Map<String, dynamic> json) =>
    TokenLocalConfig(
      hideToken: json['hideToken'] as bool?,
      tokenShowed: json['tokenShowed'] as bool?,
    );

Map<String, dynamic> _$TokenLocalConfigToJson(TokenLocalConfig instance) =>
    <String, dynamic>{
      'hideToken': instance.hideToken,
      'tokenShowed': instance.tokenShowed,
    };

TokenAssetInfo _$TokenAssetInfoFromJson(Map<String, dynamic> json) =>
    TokenAssetInfo(
      balance: Balance.fromJson(json['balance'] as Map<String, dynamic>),
      inferredNonce: json['inferredNonce'] as String?,
      delegateAccount: json['delegateAccount'] == null
          ? null
          : DelegateAccount.fromJson(
              json['delegateAccount'] as Map<String, dynamic>),
      tokenId: json['tokenId'] as String,
      publicKey: json['publicKey'] as String,
      zkappUri: json['zkappUri'] as String?,
    );

Map<String, dynamic> _$TokenAssetInfoToJson(TokenAssetInfo instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'inferredNonce': instance.inferredNonce,
      'delegateAccount': instance.delegateAccount,
      'tokenId': instance.tokenId,
      'publicKey': instance.publicKey,
      'zkappUri': instance.zkappUri,
    };

Balance _$BalanceFromJson(Map<String, dynamic> json) => Balance(
      total: json['total'] as String,
      liquid: json['liquid'] as String,
    );

Map<String, dynamic> _$BalanceToJson(Balance instance) => <String, dynamic>{
      'total': instance.total,
      'liquid': instance.liquid,
    };

DelegateAccount _$DelegateAccountFromJson(Map<String, dynamic> json) =>
    DelegateAccount(
      publicKey: json['publicKey'] as String,
    );

Map<String, dynamic> _$DelegateAccountToJson(DelegateAccount instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
    };

TokenBaseInfo _$TokenBaseInfoFromJson(Map<String, dynamic> json) =>
    TokenBaseInfo(
      isScam: json['isScam'] as bool?,
      isMainToken: json['isMainToken'] as bool?,
      isDelegation: json['isDelegation'] as bool?,
      decimals: json['decimals'] as String?,
      showBalance: (json['showBalance'] as num?)?.toDouble(),
      showAmount: (json['showAmount'] as num?)?.toDouble(),
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$TokenBaseInfoToJson(TokenBaseInfo instance) =>
    <String, dynamic>{
      'isScam': instance.isScam,
      'isMainToken': instance.isMainToken,
      'isDelegation': instance.isDelegation,
      'decimals': instance.decimals,
      'showBalance': instance.showBalance,
      'showAmount': instance.showAmount,
      'iconUrl': instance.iconUrl,
    };

TokenNetInfo _$TokenNetInfoFromJson(Map<String, dynamic> json) => TokenNetInfo(
      publicKey: json['publicKey'] as String,
      tokenSymbol: json['tokenSymbol'] as String,
      zkappState: (json['zkappState'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TokenNetInfoToJson(TokenNetInfo instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'tokenSymbol': instance.tokenSymbol,
      'zkappState': instance.zkappState,
    };
