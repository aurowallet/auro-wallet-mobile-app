// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'networkType.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkType _$NetworkTypeFromJson(Map<String, dynamic> json) {
  return NetworkType(
    name: json['name'] as String,
    type: json['type'] as String,
    chainId: json['chain_id'] as String,
  );
}

Map<String, dynamic> _$NetworkTypeToJson(NetworkType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'chain_id': instance.chainId,
    };
