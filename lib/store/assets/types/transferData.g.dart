// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transferData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferData _$TransferDataFromJson(Map<String, dynamic> json) => TransferData()
  ..success = json['success'] as bool?
  ..nonce = (json['nonce'] as num?)?.toInt()
  ..paymentId = json['paymentId'] as String?
  ..hash = json['hash'] as String
  ..type = json['type'] as String
  ..time = json['time'] as String?
  ..sender = json['sender'] as String?
  ..receiver = json['receiver'] as String?
  ..amount = json['amount'] as String
  ..fee = json['fee'] as String?
  ..memo = json['memo'] as String?
  ..status = json['status'] as String
  ..isFromAddressScam = json['isFromAddressScam'] as bool?
  ..showSpeedUp = json['showSpeedUp'] as bool?
  ..transaction = json['transaction'] as String?
  ..failureReason = json['failureReason'] as String?;

Map<String, dynamic> _$TransferDataToJson(TransferData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'nonce': instance.nonce,
      'paymentId': instance.paymentId,
      'hash': instance.hash,
      'type': instance.type,
      'time': instance.time,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'amount': instance.amount,
      'fee': instance.fee,
      'memo': instance.memo,
      'status': instance.status,
      'isFromAddressScam': instance.isFromAddressScam,
      'showSpeedUp': instance.showSpeedUp,
      'transaction': instance.transaction,
      'failureReason': instance.failureReason,
    };
