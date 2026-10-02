import 'dart:convert';
import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

/// Ledger's common GET_APP_AND_VERSION command. It does not derive keys.
class MinaNameOperation extends LedgerOperation<LedgerAppName> {
  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    return [
      Uint8List.fromList([0xb0, 0x01, 0x00, 0x00, 0x00])
    ];
  }

  @override
  Future<LedgerAppName> read(ByteDataReader reader) async {
    int readByte() {
      if (reader.remainingLength < 1) {
        throw FormatException('Truncated Ledger app information.');
      }
      return reader.readUint8();
    }

    String readString() {
      final length = readByte();
      if (length == 0 || reader.remainingLength < length) {
        throw FormatException('Invalid Ledger app information length.');
      }
      return ascii.decode(reader.read(length));
    }

    final format = readByte();
    if (format != 1) {
      throw FormatException('Unsupported Ledger app information format.');
    }
    final name = readString();
    final version = readString();
    // Dashboard (BOLOS) responses can omit flags entirely.
    if (reader.remainingLength > 0) {
      final flagsLength = readByte();
      if (reader.remainingLength != flagsLength) {
        throw FormatException('Invalid Ledger app information flags.');
      }
      reader.read(flagsLength);
    }
    return LedgerAppName(name, version);
  }
}

class LedgerAppName {
  LedgerAppName(this.name, this.version);

  final String name;
  final String version;
}
