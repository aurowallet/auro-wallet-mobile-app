// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overviewData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverviewData _$OverviewDataFromJson(Map<String, dynamic> json) => OverviewData()
  ..blockchainLength = (json['blockchainLength'] as num?)?.toInt()
  ..stateHash = json['stateHash'] as String
  ..epochDuration = (json['epochDuration'] as num).toInt()
  ..slotDuration = (json['slotDuration'] as num).toInt()
  ..slotsPerEpoch = (json['slotsPerEpoch'] as num).toInt()
  ..epoch = (json['epoch'] as num).toInt()
  ..slot = (json['slot'] as num).toInt();

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
