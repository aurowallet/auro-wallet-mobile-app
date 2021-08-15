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
  late int blockchainLength;
  late String stateHash;
  late int epochDuration;
  late int slotDuration;
  late int slotsPerEpoch;
  late int epoch;
  late int slot;
}
