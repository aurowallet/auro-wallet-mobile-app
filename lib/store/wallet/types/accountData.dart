import 'package:json_annotation/json_annotation.dart';

part 'accountData.g.dart';

@JsonSerializable()
class AccountData extends _AccountData {
  AccountData();
  factory AccountData.fromJson(Map<String, dynamic> json) =>
      _$AccountDataFromJson(json);
  Map<String, dynamic> toJson() =>
      _$AccountDataToJson(this);
}

abstract class _AccountData {
  String name = '';
  String pubKey = '';
  int accountIndex = 0;
  int createTime = 0;
  String walletId = '';
  String get address {
    return pubKey;
  }
}