// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delegatedValidator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelegatedValidator _$DelegatedValidatorFromJson(Map<String, dynamic> json) =>
    DelegatedValidator(
      json['publicKey'] as String,
      (json['countDelegates'] as num).toDouble(),
      (json['totalDelegated'] as num).toDouble(),
    );

Map<String, dynamic> _$DelegatedValidatorToJson(DelegatedValidator instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'countDelegates': instance.countDelegates,
      'totalDelegated': instance.totalDelegated,
    };
