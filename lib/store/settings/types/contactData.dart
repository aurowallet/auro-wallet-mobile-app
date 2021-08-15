import 'package:json_annotation/json_annotation.dart';

part 'contactData.g.dart';

@JsonSerializable(explicitToJson: true)
class ContactData {
  ContactData({required this.name, required this.address});
  factory ContactData.fromJson(Map<String, dynamic> json) =>
      _$ContactDataFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ContactDataToJson(this);

  String name;
  String address;
}