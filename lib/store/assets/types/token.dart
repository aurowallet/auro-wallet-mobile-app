import 'package:json_annotation/json_annotation.dart';
import 'tokenBaseInfo.dart';
import 'tokenNetInfo.dart';
import 'tokenAssetInfo.dart';
part 'token.g.dart';

@JsonSerializable()
class Token {
  TokenAssetInfo? tokenAssestInfo;
  TokenNetInfo? tokenNetInfo;
  TokenLocalConfig? localConfig;
  TokenBaseInfo? tokenBaseInfo;

  Token({
    this.tokenAssestInfo,
    this.tokenNetInfo,
    this.localConfig,
    this.tokenBaseInfo,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class TokenLocalConfig {
  bool? hideToken;
  bool? tokenShowed;

  TokenLocalConfig({
    this.hideToken,
    this.tokenShowed,
  });

  factory TokenLocalConfig.fromJson(Map<String, dynamic> json) =>
      _$TokenLocalConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TokenLocalConfigToJson(this);
}
