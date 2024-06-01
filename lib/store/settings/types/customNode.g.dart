// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customNode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomNode _$CustomNodeFromJson(Map<String, dynamic> json) => CustomNode(
      url: json['url'] as String,
      name: json['name'] as String,
      networkID: json['networkID'] as String,
      isDefaultNode: json['isDefaultNode'] as bool? ?? false,
      explorerUrl: json['explorerUrl'] as String?,
      txUrl: json['txUrl'] as String?,
    );

Map<String, dynamic> _$CustomNodeToJson(CustomNode instance) =>
    <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'networkID': instance.networkID,
      'isDefaultNode': instance.isDefaultNode,
      'explorerUrl': instance.explorerUrl,
      'txUrl': instance.txUrl,
    };
