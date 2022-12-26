import 'package:json_annotation/json_annotation.dart';

part 'feeTransferData.g.dart';

@JsonSerializable()
class FeeTransferData {
  final String recipient;
  final String dateTime;
  final int fee;
  final String type;
  FeeTransferData(
      this.recipient,
      this.dateTime,
      this.fee,
      this.type
      );
  factory FeeTransferData.fromJson(Map<String, dynamic> json) => _$FeeTransferDataFromJson(json);

  Map<String, dynamic> toJson() => _$FeeTransferDataToJson(this);
}

