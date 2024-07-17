import 'package:auro_wallet/store/assets/types/feeTransferData.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'transferData.g.dart';

@JsonSerializable()
class TransferData extends _TransferData {
  static TransferData fromJson(Map<String, dynamic> json) {
    final td =  _$TransferDataFromJson(json);
    if (td.success == null) {
      td.success = td.status != 'failed';
    }
    return td;
  }
  static Map<String, dynamic> toJson(TransferData data) =>
      _$TransferDataToJson(data);
  static TransferData fromPendingJson(Map<String, dynamic> json) {
    json['type'] = json['kind'];
    json['sender'] = json['from'];
    json['receiver'] = json['to'];
    json['paymentId'] = json['id'];
    json['status'] = "pending";
    json['success'] = false;
    var data = fromJson(json);
    return data;
  }

  static TransferData fromGraphQLJson(Map<String, dynamic> json) {
    switch(json['kind']) {
      case "STAKE_DELEGATION":
        json['type'] = "delegation";
        break;
      case "PAYMENT":
        json['type'] = "payment";
        break;
      default:
        json['type'] = json['kind'];
        break;
    }
    json['time'] = json['dateTime'];
    json['sender'] = json['from'];
    json['amount'] = (json['amount'] as int).toString();
    json['fee'] = (json['fee'] as int).toString();
    json['receiver'] = json['to'];
    json['paymentId'] = json['id'];
    json['status'] = json['failureReason'] == null ? 'applied' : 'failed';
    json['success'] = json['failureReason'] == null;
    var data = fromJson(json);
    return data;
  }

  static TransferData fromZkGraphQLJson(Map<String, dynamic> json) {
    var accountUpdates = json['zkappCommand']['accountUpdates'] as List<dynamic>?;
    var firstUpdate = accountUpdates?.isNotEmpty == true ? accountUpdates!.first as Map<String, dynamic> : null;
    var receiver = firstUpdate != null ? firstUpdate['body']['publicKey'] : null;
    
    var feePayerBody = json['zkappCommand']['feePayer']['body'] as Map<String, dynamic>;
    var fee = feePayerBody['fee'].toString();

    json['type'] = "zkApp";
    json['time'] = json['dateTime'];
    json['sender'] = feePayerBody['publicKey'];
    json['amount'] = "0";
    json['fee'] = fee;
    json['receiver'] = receiver;
    json['nonce'] = feePayerBody['nonce'];
    json['transaction'] = jsonEncode(json['zkappCommand']);
    bool isFailed = json['failureReason'] != null && (json['failureReason'] as List<dynamic>).isNotEmpty;
    json['status'] = isFailed ? 'failed' : 'applied';
    json['success'] = !isFailed;
    var data = fromJson(json);
    return data;
  }

  static TransferData fromZkPendingJson(Map<String, dynamic> json) {
    var accountUpdates = json['zkappCommand']['accountUpdates'] as List<dynamic>?;
    var firstUpdate = accountUpdates?.isNotEmpty == true ? accountUpdates!.first as Map<String, dynamic> : null;
    var receiver = firstUpdate != null ? firstUpdate['body']['publicKey'] : null;
    
    var feePayerBody = json['zkappCommand']['feePayer']['body'] as Map<String, dynamic>;
    var fee = feePayerBody['fee'].toString();


    json['type'] = "zkApp";
    json['sender'] = feePayerBody['publicKey'];
    json['nonce'] = int.parse(feePayerBody['nonce']); 
    json['receiver'] = receiver;
    json['fee'] = fee;
    json['status'] = "pending";
    json['success'] = false;
    json['transaction'] = jsonEncode(json['zkappCommand']);
    json['amount'] = "0";
    var data = fromJson(json);
    return data;
  }

}

abstract class _TransferData {
  bool? success = true;
  int? nonce = 0;
  String? paymentId = "";
  String hash = "";
  String type = "";
  String? time = "";
  String? sender = "";
  String? receiver = "";
  String amount = "";
  String? fee = "";
  String? memo = "";
  String status = "";
  bool? isFromAddressScam = false;
  bool? showSpeedUp = false;
  String? transaction = "";
  bool get isPending {
    return status == 'pending';
  }
}
