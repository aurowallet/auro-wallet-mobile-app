// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenPendingTx.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPendingTx _$TokenPendingTxFromJson(Map<String, dynamic> json) =>
    TokenPendingTx(
      sender: json['sender'] as String,
      network: json['network'] as String,
      nonce: (json['nonce'] as num).toInt(),
      timestamp: json['timestamp'] as String,
      amount: json['amount'] as String,
      tokenaddress: json['tokenaddress'] as String,
      receiver: json['receiver'] as String,
    );

Map<String, dynamic> _$TokenPendingTxToJson(TokenPendingTx instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'network': instance.network,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp,
      'amount': instance.amount,
      'tokenaddress': instance.tokenaddress,
      'receiver': instance.receiver,
    };
