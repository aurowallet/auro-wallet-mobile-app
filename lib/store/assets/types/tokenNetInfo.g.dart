// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenNetInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
