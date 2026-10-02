import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/utils/stakingMath.dart';

part 'overviewData.g.dart';

@JsonSerializable()
class OverviewData extends _OverviewData {
  static OverviewData fromJson(Map<String, dynamic> json) =>
      _$OverviewDataFromJson({
        ...json,
        'stateHash': json['stateHash']?.toString() ?? '',
        for (final key in ['epochDuration', 'slotDuration', 'slotsPerEpoch',
          'epoch', 'slot', 'blockchainLength'])
          key: int.tryParse(json[key]?.toString() ?? '') ??
              (key == 'epoch' || key == 'slot' ? -1 : 0),
      });
  static Map<String, dynamic> toJson(OverviewData data) =>
      _$OverviewDataToJson(data);
}

abstract class _OverviewData {
   double get epochDays => StakingMath.epochDays(
       slotsPerEpoch: slotsPerEpoch, slotDurationMs: slotDuration,
       epochDurationMs: epochDuration);
   String get epochDaysText {
     final days = epochDays;
     return days.toStringAsFixed(days == days.truncateToDouble() ? 0 : 1);
   }
   bool get hasEpochInfo => slotsPerEpoch > 0 && slotDuration > 0 && epoch >= 0 && slot >= 0;
   int get boundedSlot => slot.clamp(0, slotsPerEpoch > 0 ? slotsPerEpoch : 0);

   double get epochProgress => hasEpochInfo
       ? StakingMath.epochProgress(slot, slotsPerEpoch) : 0;
   ({BigInt days, int hours, int minutes})? get epochTimeRemaining => hasEpochInfo
       ? StakingMath.epochTimeRemaining(slot: slot, slotsPerEpoch: slotsPerEpoch,
           slotDurationMs: slotDuration) : null;

   int? blockchainLength = 0;
   String stateHash = "";
   int epochDuration = 0;
   int slotDuration = 0;
   int slotsPerEpoch = 0;
   int epoch = 0;
   int slot = 0;
}
