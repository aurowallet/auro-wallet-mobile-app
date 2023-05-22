import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// APDU Protocol
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaSignTransferOperation extends LedgerOperation<String> {
  static const headerSize = 5;
  static const chunkSize = 0xFF;

  static const p1FirstWithAccount = 0x01;
  static const p1More = 0x80;
  static const p2More = 0x80;
  static const p2Last = 0x00;

  final Uint8List transaction;

  MinaSignTransferOperation({
    required this.transaction,
  });

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.writeUint8(0xe0); // MINA_CLA
    writer.writeUint8(0x03); // INS_SIGN_TX
    writer.writeUint8(0x00); // P1_FIRST
    writer.writeUint8(0x00); // P2_LAST
    writer.writeUint8(transaction.length); // P2_LAST
    writer.write(transaction); // Account index as bytearray
    return [writer.toBytes()];
  }

  @override
  Future<String> read(ByteDataReader reader) async {
    // Read the signature
    print('sign transfer back');
    final fieldBytes = reader.read(32);
    final scalarBytes = reader.read(32);
    // final bytes = reader.read(reader.remainingLength);
    print('backdata');
    print(hex.encode(fieldBytes));
    print(hex.encode(scalarBytes));
    final res = hex.encode(fieldBytes.reversed.toList()) +
        hex.encode(scalarBytes.reversed.toList());
    print(res);
    return res;
    // return reader.read(reader.remainingLength);
  }
}
