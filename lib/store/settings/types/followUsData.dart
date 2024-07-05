import 'package:auro_wallet/common/consts/enums.dart';
import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/settings/types/contactData.dart';
import 'package:auro_wallet/store/settings/types/customNode.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

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
