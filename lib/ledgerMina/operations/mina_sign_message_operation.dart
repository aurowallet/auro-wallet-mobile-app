import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// Mina SIGN_MSG, matching @zondax/ledger-mina-js signMessage.
class MinaSignMessageOperation extends LedgerOperation<Map<String, dynamic>> {
  MinaSignMessageOperation({
    required this.accountIndex,
    required this.networkId,
    required this.message,
  });

  final int accountIndex;
  final int networkId;
  final String message;

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    if (accountIndex < 0 ||
        accountIndex > 0xffffffff ||
        (networkId != 0 && networkId != 1)) {
      throw const FormatException(
        'Invalid Ledger message signing account or network.',
      );
    }
    final bytes = utf8.encode(message);
    // Lc is one byte and includes account (4) and network (1).
    // Leave message content restrictions to the device; never wrap/truncate Lc.
    if (5 + bytes.length > 0xff) {
      throw const FormatException(
        'Ledger message exceeds the APDU payload size.',
      );
    }
    writer.writeUint8(0xe0); // Mina CLA
    writer.writeUint8(0x05); // SIGN_MSG
    writer.writeUint8(0x00);
    writer.writeUint8(0x00);
    writer.writeUint8(5 + bytes.length);
    writer.writeUint32(accountIndex);
    writer.writeUint8(networkId);
    writer.write(bytes);
    return [writer.toBytes()];
  }

  @override
  Future<Map<String, dynamic>> read(ByteDataReader reader) async {
    if (reader.remainingLength < 65) {
      throw const FormatException('Invalid Ledger message signature length.');
    }
    // Message signatures contain big-endian field/scalar values.
    final field = BigInt.parse(hex.encode(reader.read(32)), radix: 16);
    final scalar = BigInt.parse(hex.encode(reader.read(32)), radix: 16);
    final length = reader.readUint8();
    if (reader.remainingLength != length) {
      throw const FormatException('Invalid Ledger signed message length.');
    }
    final signedMessage = utf8.decode(reader.read(length));
    // Firmware signs and returns this prefix; dApps must receive that exact data.
    if (signedMessage != 'Message : $message') {
      throw const FormatException(
        'Ledger signed message does not match the request.',
      );
    }
    return {
      'data': signedMessage,
      'signature': {'field': field.toString(), 'scalar': scalar.toString()},
    };
  }
}
