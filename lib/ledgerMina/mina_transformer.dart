import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

import 'ledger_status_code.dart';

class MinaTransformer extends LedgerTransformer {
  const MinaTransformer();

  @override
  Future<Uint8List> onTransform(List<Uint8List> transform) async {
    if (transform.isEmpty) {
      throw LedgerException(message: 'No response data from Ledger.');
    }

    final output = <Uint8List>[];

    for (var data in transform) {
      if (data.length < 2) {
        throw FormatException('Missing Ledger response status.');
      }
      final payloadLength = data.length - 2;
      final status = ByteData.sublistView(data).getUint16(payloadLength);
      if (status != LedgerStatusCode.success) {
        throw LedgerException(errorCode: status);
      }
      output.add(data.sublist(0, payloadLength));
    }

    return Uint8List.fromList(output.expand((e) => e).toList());
  }
}
