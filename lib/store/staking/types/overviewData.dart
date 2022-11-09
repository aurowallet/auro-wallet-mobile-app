import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'overviewData.g.dart';

@JsonSerializable()
class OverviewData extends _OverviewData {
  static OverviewData fromJson(Map<String, dynamic> json) =>
      _$OverviewDataFromJson(json);
  static Map<String, dynamic> toJson(OverviewData data) =>
      _$OverviewDataToJson(data);
}

abstract class _OverviewData {
   int? blockchainLength = 0;
   String stateHash = "";
   int epochDuration = 0;
   int slotDuration = 0;
   int slotsPerEpoch = 0;
   int epoch = 0;
   int slot = 0;
}
