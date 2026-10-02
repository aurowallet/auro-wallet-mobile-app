import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

class MinaSignFieldElementOperation extends LedgerOperation<Uint8List> {
  MinaSignFieldElementOperation({
    required this.accountIndex,
    required this.networkId,
    required this.fieldElement,
  });

  final int accountIndex;
  final int networkId;
  final Uint8List fieldElement;

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    if (fieldElement.length != 32) {
      throw ArgumentError.value(
        fieldElement.length,
        'fieldElement',
        'Ledger field elements must be exactly 32 bytes',
      );
    }

    writer.writeUint8(0xe0); // Mina CLA
    writer.writeUint8(0x06); // SIGN_FIELD_ELEMENT
    writer.writeUint8(0x00);
    writer.writeUint8(0x00);
    writer.writeUint8(37);
    writer.writeUint32(accountIndex);
    writer.writeUint8(networkId);
    writer.write(fieldElement);
    return [writer.toBytes()];
  }

  @override
  Future<Uint8List> read(ByteDataReader reader) async {
    // Mina app responses may contain extra bytes after the 64-byte
    // field/scalar signature. The extension SDK consumes the first 64 bytes
    // and ignores that tail, so mobile must do the same. The tail's semantic
    // meaning is app-version-specific and is intentionally not interpreted.
    if (reader.remainingLength < 64) {
      throw LedgerException(
        message:
            'Invalid Ledger field-element signature length: ${reader.remainingLength}',
      );
    }
    return reader.read(64);
  }
}
