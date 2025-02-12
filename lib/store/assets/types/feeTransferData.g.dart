// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeTransferData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeTransferData _$FeeTransferDataFromJson(Map<String, dynamic> json) =>
    FeeTransferData(
      json['recipient'] as String,
      json['dateTime'] as String,
      (json['fee'] as num).toInt(),
      json['type'] as String,
    );

Map<String, dynamic> _$FeeTransferDataToJson(FeeTransferData instance) =>
    <String, dynamic>{
      'recipient': instance.recipient,
      'dateTime': instance.dateTime,
      'fee': instance.fee,
      'type': instance.type,
    };
