// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accountData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountData _$AccountDataFromJson(Map<String, dynamic> json) => AccountData()
  ..name = json['name'] as String
  ..pubKey = json['pubKey'] as String
  ..accountIndex = (json['accountIndex'] as num).toInt()
  ..createTime = (json['createTime'] as num).toInt()
  ..walletId = json['walletId'] as String;

Map<String, dynamic> _$AccountDataToJson(AccountData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pubKey': instance.pubKey,
      'accountIndex': instance.accountIndex,
      'createTime': instance.createTime,
      'walletId': instance.walletId,
    };
