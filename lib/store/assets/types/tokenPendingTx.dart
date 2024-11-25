import 'package:json_annotation/json_annotation.dart';

part 'tokenPendingTx.g.dart';

@JsonSerializable()
class TokenPendingTx {
  final String sender;
  final String network;
  final int nonce;
  final String timestamp;
  final String amount;
  final String tokenaddress;
  final String receiver;

  TokenPendingTx({
    required this.sender,
    required this.network,
    required this.nonce,
    required this.timestamp,
    required this.amount,
    required this.tokenaddress,
    required this.receiver,
  });

  factory TokenPendingTx.fromJson(Map<String, dynamic> json) => _$TokenPendingTxFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPendingTxToJson(this);
}