import 'package:json_annotation/json_annotation.dart';

part 'scamInfo.g.dart';

@JsonSerializable()
class ScamItem {
  String address;
  String info;

  ScamItem({
    required this.address,
    required this.info,
  });

  factory ScamItem.fromJson(Map<String, dynamic> json) =>
      _$ScamItemFromJson(json);

  Map<String, dynamic> toJson() => _$ScamItemToJson(this);
}