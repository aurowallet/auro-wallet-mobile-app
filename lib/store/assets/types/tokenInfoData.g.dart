// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenInfoData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenInfoData _$TokenInfoDataFromJson(Map<String, dynamic> json) =>
    TokenInfoData(
      tokenId: json['tokenId'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimal: json['decimal'] as String,
      sourceUrl: json['sourceUrl'] as String,
      iconUrl: json['iconUrl'] as String,
    );

Map<String, dynamic> _$TokenInfoDataToJson(TokenInfoData instance) =>
    <String, dynamic>{
      'tokenId': instance.tokenId,
      'name': instance.name,
      'symbol': instance.symbol,
      'decimal': instance.decimal,
      'sourceUrl': instance.sourceUrl,
      'iconUrl': instance.iconUrl,
    };
