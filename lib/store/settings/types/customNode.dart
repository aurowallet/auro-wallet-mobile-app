import 'package:auro_wallet/common/consts/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customNode.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomNode {
  CustomNode({required this.name, required this.url});
  factory CustomNode.fromJson(Map<String, dynamic> json) =>
      _$CustomNodeFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CustomNodeToJson(this);

  String name;
  String url;
  String? networksType;
  String? chainId;
}