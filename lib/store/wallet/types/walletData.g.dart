// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walletData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletData _$WalletDataFromJson(Map<String, dynamic> json) => WalletData()
  ..createTime = (json['createTime'] as num).toInt()
  ..currentAccountIndex = (json['currentAccountIndex'] as num).toInt()
  ..walletTypeIndex = (json['walletTypeIndex'] as num).toInt()
  ..walletType = json['walletType'] as String
  ..id = json['id'] as String
  ..source = json['source'] as String
  ..meta = json['meta'] as Map<String, dynamic>
  ..accounts = (json['accounts'] as List<dynamic>)
      .map((e) => AccountData.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$WalletDataToJson(WalletData instance) =>
    <String, dynamic>{
      'createTime': instance.createTime,
      'currentAccountIndex': instance.currentAccountIndex,
      'walletTypeIndex': instance.walletTypeIndex,
      'walletType': instance.walletType,
      'id': instance.id,
      'source': instance.source,
      'meta': instance.meta,
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
    };
