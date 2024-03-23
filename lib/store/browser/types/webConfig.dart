import 'package:json_annotation/json_annotation.dart';

part 'webConfig.g.dart';

@JsonSerializable()
class WebConfig {
  String url;
  String title;
  String time;
  String? icon;

  WebConfig(
      {required this.url, required this.title, required this.time, this.icon});

  factory WebConfig.fromJson(Map<String, dynamic> json) =>
      _$WebConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WebConfigToJson(this);
}
