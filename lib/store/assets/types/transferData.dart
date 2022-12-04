import 'package:auro_wallet/store/assets/types/feeTransferData.dart';
import 'package:json_annotation/json_annotation.dart';

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
  static TransferData fromFeeTransfer(FeeTransferData data) {
    Map<String, dynamic> feeTx = {
      "success": true,
      "from": "",
      "hash": "",
      "time": data.dateTime,
      "receiver": data.recipient,
      "type": data.type,
      "amount": data.fee.toString(),
      "status": "applied"
    };
    return fromJson(feeTx);
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
  bool get isPending {
    return status == 'pending';
  }
}
