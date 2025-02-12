import 'package:json_annotation/json_annotation.dart';

part 'followUsData.g.dart';

@JsonSerializable(explicitToJson: true)
class FollowUsData {
  String website = '';
  String name = '';

  FollowUsData({required this.website, required this.name});

  factory FollowUsData.fromJson(Map<String, dynamic> json) =>
      _$FollowUsDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUsDataToJson(this);
}
