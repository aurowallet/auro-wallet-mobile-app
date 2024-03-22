import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/common/consts/enums.dart';

part 'customNodeV2.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomNodeV2 {
  NetworkTypes? netType;
  String url;
  String? explorerUrl;
  String? txUrl;
  String name;
  String? id;
  String? chainId;
  bool? isDefaultNode;

  CustomNodeV2({
    required this.name,
    required this.url,
    this.explorerUrl,
    this.txUrl,
    this.netType,
    this.id,
    this.chainId,
    this.isDefaultNode
  });
  factory CustomNodeV2.fromJson(Map<String, dynamic> json) =>
      _$CustomNodeV2FromJson(json);

  Map<String, dynamic> toJson() => _$CustomNodeV2ToJson(this);
}
