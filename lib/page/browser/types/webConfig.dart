import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class WebConfig {
  String url;
  String title;
  String time;
  String? icon;

  WebConfig(
      {required this.url, required this.title, required this.time, this.icon});

  // Factory constructor to create a WebConfig instance from a map
  factory WebConfig.fromMap(Map<String, dynamic> map) {
    return WebConfig(
      url: map['url'] as String,
      title: map['title'] as String,
      time: map['time'] as String,
      icon: map['icon']
          as String?, // Since icon is nullable, it's safe to cast it as String?
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'url': this.url,
      'title': this.title,
      'time': this.time,
      'icon': this
          .icon, // This is nullable. If it's null, the key 'icon' will still be present with a null value
    };
  }
}
