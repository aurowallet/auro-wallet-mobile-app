import 'package:auro_wallet/common/consts/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'networkType.g.dart';

@JsonSerializable(explicitToJson: true)
class NetworkType {
  NetworkType({required this.name, required this.type, required this.chainId});
  factory NetworkType.fromJson(Map<String, dynamic> json) =>
      _$NetworkTypeFromJson(json);
  Map<String, dynamic> toJson() =>
      _$NetworkTypeToJson(this);

  String name;
  String type;

  @JsonKey(name: 'chain_id')
  String chainId;
}