import 'package:json_annotation/json_annotation.dart';
import 'package:auro_wallet/common/consts/enums.dart';

part 'customNode.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomNode {
  String url; 
  String name;
  String networkID; 
  bool isDefaultNode;
  String? explorerUrl;
  String? txUrl;

  CustomNode({
    required this.url,
    required this.name,
    required this.networkID,
    this.isDefaultNode=false,
    this.explorerUrl,
    this.txUrl,
  });
  factory CustomNode.fromJson(Map<String, dynamic> json) =>
      _$CustomNodeFromJson(json);

  Map<String, dynamic> toJson() => _$CustomNodeToJson(this);
}
