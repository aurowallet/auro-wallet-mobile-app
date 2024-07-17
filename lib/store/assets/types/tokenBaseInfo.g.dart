// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenBaseInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenBaseInfo _$TokenBaseInfoFromJson(Map<String, dynamic> json) =>
    TokenBaseInfo(
      isScam: json['isScam'] as bool?,
      isMainToken: json['isMainToken'] as bool?,
      isDelegation: json['isDelegation'] as bool?,
      decimals: json['decimals'] as String?,
      showBalance: (json['showBalance'] as num?)?.toDouble(),
      showAmount: (json['showAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TokenBaseInfoToJson(TokenBaseInfo instance) =>
    <String, dynamic>{
      'isScam': instance.isScam,
      'isMainToken': instance.isMainToken,
      'isDelegation': instance.isDelegation,
      'decimals': instance.decimals,
      'showBalance': instance.showBalance,
      'showAmount': instance.showAmount,
    };
