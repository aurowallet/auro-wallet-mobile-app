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
  static Map<String, dynamic> toJson(TransferData data) =>
      _$TransferDataToJson(data);
  static TransferData fromPendingJson(Map<String, dynamic> json) {
    var data = fromJson(json);
    data.type = json['kind'] as String;
    data.sender = json['from'] as String;
    data.receiver = json['to'] as String;
    data.paymentId = json['id'] as String;
    data.status = "pending";
    data.success = false;
    return data;
  }
}

abstract class _TransferData {
  bool? success = true;
  int? nonce = 0;
  String? paymentId = "";
  String hash = "";
  String type = "";
  String time = "";
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
