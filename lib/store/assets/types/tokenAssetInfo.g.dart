// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenAssetInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
