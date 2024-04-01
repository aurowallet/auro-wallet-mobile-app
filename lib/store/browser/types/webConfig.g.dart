// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webConfig.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebConfig _$WebConfigFromJson(Map<String, dynamic> json) => WebConfig(
      url: json['url'] as String,
      title: json['title'] as String,
      time: json['time'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$WebConfigToJson(WebConfig instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'time': instance.time,
      'icon': instance.icon,
    };
