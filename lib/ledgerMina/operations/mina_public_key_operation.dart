import 'dart:typed_data';

import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// APDU Protocol
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaPublicKeyOperation extends LedgerOperation<List<String>> {
  final int accountIndex;

  MinaPublicKeyOperation({
    this.accountIndex = 0,
  });

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.writeUint8(0xe0); // MINA_CLA
    writer.writeUint8(0x02); // PUBLIC_KEY_INS
    writer.writeUint8(0x00); // P1_FIRST
    writer.writeUint8(0x00); // P2_LAST
    writer.writeUint8(0x04); // P2_LAST
    writer.writeUint32(accountIndex); // Account index as bytearray
    return [writer.toBytes()];
  }

  @override
  Future<List<String>> read(ByteDataReader reader) async {
    final bytes = reader.read(reader.remainingLength - 1);
    print(hex.encode(bytes));
    return [
      String.fromCharCodes(bytes),
    ];
  }
}
