// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accountData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountData _$AccountDataFromJson(Map<String, dynamic> json) {
  return AccountData()
    ..name = json['name'] as String
    ..pubKey = json['pubKey'] as String
    ..accountIndex = json['accountIndex'] as int
    ..createTime = json['createTime'] as int
    ..walletId = json['walletId'] as String;
}

Map<String, dynamic> _$AccountDataToJson(AccountData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pubKey': instance.pubKey,
      'accountIndex': instance.accountIndex,
      'createTime': instance.createTime,
      'walletId': instance.walletId,
    };
