import 'package:json_annotation/json_annotation.dart';

part 'tokenInfoData.g.dart';

@JsonSerializable()
class TokenInfoData {
  final String tokenId;
  final String name;
  final String symbol;
  final String decimal;
  final String sourceUrl;
  final String iconUrl;

  TokenInfoData({
    required this.tokenId,
    required this.name,
    required this.symbol,
    required this.decimal,
    required this.sourceUrl,
    required this.iconUrl,
  });

  factory TokenInfoData.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenInfoDataToJson(this);
}