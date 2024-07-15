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
  bool? tokenShowed;

  TokenBaseInfo({
    this.isScam,
    this.isMainToken,
    this.isDelegation,
    this.decimals,
    this.showBalance,
    this.showAmount,
    this.tokenShowed,
  });

  factory TokenBaseInfo.fromJson(Map<String, dynamic> json) => _$TokenBaseInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBaseInfoToJson(this);
}