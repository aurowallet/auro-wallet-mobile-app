// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overviewData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverviewData _$OverviewDataFromJson(Map<String, dynamic> json) => OverviewData()
  ..blockchainLength = json['blockchainLength'] as int
  ..stateHash = json['stateHash'] as String
  ..epochDuration = json['epochDuration'] as int
  ..slotDuration = json['slotDuration'] as int
  ..slotsPerEpoch = json['slotsPerEpoch'] as int
  ..epoch = json['epoch'] as int
  ..slot = json['slot'] as int;

Map<String, dynamic> _$OverviewDataToJson(OverviewData instance) =>
    <String, dynamic>{
      'blockchainLength': instance.blockchainLength,
      'stateHash': instance.stateHash,
      'epochDuration': instance.epochDuration,
      'slotDuration': instance.slotDuration,
      'slotsPerEpoch': instance.slotsPerEpoch,
      'epoch': instance.epoch,
      'slot': instance.slot,
    };
