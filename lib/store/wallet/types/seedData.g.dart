// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seedData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeedData _$SeedDataFromJson(Map<String, dynamic> json) => SeedData(
      encrypted: json['encrypted'] as String,
      iv: json['iv'] as String,
      salt: json['salt'] as String,
      encryptedSecret: json['encryptedSecret'] as String,
      version: json['version'] as int?,
    );

Map<String, dynamic> _$SeedDataToJson(SeedData instance) => <String, dynamic>{
      'encrypted': instance.encrypted,
      'encryptedSecret': instance.encryptedSecret,
      'iv': instance.iv,
      'salt': instance.salt,
      'version': instance.version,
    };
