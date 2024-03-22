// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customNodeV2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomNodeV2 _$CustomNodeV2FromJson(Map<String, dynamic> json) => CustomNodeV2(
      name: json['name'] as String,
      url: json['url'] as String,
      explorerUrl: json['explorerUrl'] as String?,
      txUrl: json['txUrl'] as String?,
      netType: $enumDecodeNullable(_$NetworkTypesEnumMap, json['netType']),
      id: json['id'] as String?,
      chainId: json['chainId'] as String?,
      isDefaultNode: json['isDefaultNode'] as bool?,
    );

Map<String, dynamic> _$CustomNodeV2ToJson(CustomNodeV2 instance) =>
    <String, dynamic>{
      'netType': _$NetworkTypesEnumMap[instance.netType],
      'url': instance.url,
      'explorerUrl': instance.explorerUrl,
      'txUrl': instance.txUrl,
      'name': instance.name,
      'id': instance.id,
      'chainId': instance.chainId,
      'isDefaultNode': instance.isDefaultNode,
    };

const _$NetworkTypesEnumMap = {
  NetworkTypes.mainnet: 'mainnet',
  NetworkTypes.devnet: 'devnet',
  NetworkTypes.berkeley: 'berkeley',
  NetworkTypes.unknown: 'unknown',
};
