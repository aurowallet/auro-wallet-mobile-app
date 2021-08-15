import 'package:json_annotation/json_annotation.dart';

part 'seedData.g.dart';

@JsonSerializable(explicitToJson: true)
class SeedData {
  SeedData({required this.encrypted,required this.iv, required this.salt, required this.encryptedSecret, this.version});
  factory SeedData.fromJson(Map<String, dynamic> json) =>
      _$SeedDataFromJson(json);
  Map<String, dynamic> toJson() =>
      _$SeedDataToJson(this);

  String encrypted;
  String encryptedSecret;
  String iv;
  String salt;
  int? version = 1;
}