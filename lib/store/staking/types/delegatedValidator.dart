import 'package:json_annotation/json_annotation.dart';

part 'delegatedValidator.g.dart';

@JsonSerializable()
class DelegatedValidator {
  final String publicKey;
  final double? countDelegates;
  final double? totalDelegated;

  DelegatedValidator(
      this.publicKey,
      this.countDelegates,
      this.totalDelegated);

  factory DelegatedValidator.fromJson(Map<String, dynamic> json) => _$DelegatedValidatorFromJson(json);

  Map<String, dynamic> toJson() => _$DelegatedValidatorToJson(this);
}