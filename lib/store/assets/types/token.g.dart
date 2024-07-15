// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      tokenAssestInfo: json['tokenAssestInfo'] == null
          ? null
          : TokenAssetInfo.fromJson(
              json['tokenAssestInfo'] as Map<String, dynamic>),
      tokenNetInfo: json['tokenNetInfo'] == null
          ? null
          : TokenNetInfo.fromJson(json['tokenNetInfo'] as Map<String, dynamic>),
      localConfig: json['localConfig'] == null
          ? null
          : TokenLocalConfig.fromJson(
              json['localConfig'] as Map<String, dynamic>),
      tokenBaseInfo: json['tokenBaseInfo'] == null
          ? null
          : TokenBaseInfo.fromJson(
              json['tokenBaseInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'tokenAssestInfo': instance.tokenAssestInfo,
      'tokenNetInfo': instance.tokenNetInfo,
      'localConfig': instance.localConfig,
      'tokenBaseInfo': instance.tokenBaseInfo,
    };

TokenLocalConfig _$TokenLocalConfigFromJson(Map<String, dynamic> json) =>
    TokenLocalConfig(
      hideToken: json['hideToken'] as bool?,
    );

Map<String, dynamic> _$TokenLocalConfigToJson(TokenLocalConfig instance) =>
    <String, dynamic>{
      'hideToken': instance.hideToken,
    };
