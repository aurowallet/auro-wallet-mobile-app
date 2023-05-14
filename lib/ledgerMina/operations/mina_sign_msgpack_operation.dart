import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

/// APDU Protocol
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaSignMsgPackOperation extends LedgerOperation<Uint8List> {
  static const headerSize = 5;
  static const chunkSize = 0xFF;

  static const p1FirstWithAccount = 0x01;
  static const p1More = 0x80;
  static const p2More = 0x80;
  static const p2Last = 0x00;

  final int accountIndex;
  final Uint8List transaction;

  MinaSignMsgPackOperation({
    required this.transaction,
    this.accountIndex = 0,
  });

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    final output = <Uint8List>[];
    var bytesRemaining = transaction.length + 0x04;
    var offset = 0;
    var p1 = p1FirstWithAccount;
    var p2 = p2More;

    while (bytesRemaining > 0) {
      final writer = ByteDataWriter();
      final bytesRemainingWithHeader = bytesRemaining + headerSize;
      final packetSize = bytesRemainingWithHeader <= chunkSize
          ? bytesRemainingWithHeader
          : chunkSize;

      final remainingSpace = packetSize - headerSize;
      var bytesToCopyLength =
          (remainingSpace < bytesRemaining) ? remainingSpace : bytesRemaining;
      bytesRemaining -= bytesToCopyLength;
      if (bytesRemaining == 0) {
        p2 = p2Last;
      }

      writer.writeUint8(0x80);
      writer.writeUint8(0x08);

      // If one single APDU may contain a whole transaction, P1 and P2 are both 0x00.
      writer.writeUint8(p1);
      writer.writeUint8(p2);
      writer.writeUint8(bytesToCopyLength);
      if (p1 == p1FirstWithAccount) {
        writer.writeUint32(accountIndex);
        bytesToCopyLength -= 4;
      }

      writer.write(
          transaction.getRange(offset, offset + bytesToCopyLength).toList());
      offset += bytesToCopyLength;

      p1 = p1More;
      output.add(writer.toBytes());
    }

    return output;
  }

  @override
  Future<Uint8List> read(ByteDataReader reader) async {
    // Read the signature
    return reader.read(reader.remainingLength);
  }
}
