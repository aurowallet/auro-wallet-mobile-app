import 'package:json_annotation/json_annotation.dart';

part 'tokenBaseInfo.g.dart';

@JsonSerializable()
class TokenBaseInfo {
  bool? isScam;
  bool? isMainToken;
  bool? isDelegation;
  String? decimals;
  double? showBalance;
  double? showAmount;

  TokenBaseInfo({
    this.isScam,
    this.isMainToken,
    this.isDelegation,
    this.decimals,
    this.showBalance,
    this.showAmount,
  });

  factory TokenBaseInfo.fromJson(Map<String, dynamic> json) => _$TokenBaseInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBaseInfoToJson(this);
}