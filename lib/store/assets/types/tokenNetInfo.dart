import 'package:json_annotation/json_annotation.dart';

part 'tokenNetInfo.g.dart';

@JsonSerializable()
class TokenNetInfo {
  final String publicKey;
  final String tokenSymbol;
  final List<String> zkappState;

  TokenNetInfo({
    required this.publicKey,
    required this.tokenSymbol,
    required this.zkappState,
  });

  factory TokenNetInfo.fromJson(Map<String, dynamic> json) => _$TokenNetInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenNetInfoToJson(this);
}