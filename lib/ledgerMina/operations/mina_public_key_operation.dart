import 'dart:convert';
import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

/// APDU Protocol
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaPublicKeyOperation extends LedgerOperation<List<String>> {
  final int accountIndex;
  final bool showAddressInDevice;

  MinaPublicKeyOperation({
    this.accountIndex = 0,
    this.showAddressInDevice = true,
  });

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.writeUint8(0xe0); // MINA_CLA
    writer.writeUint8(0x02); // PUBLIC_KEY_INS
    // Mina uses P1=0 to show the address on the Ledger and P1=1 for a
    // silent public-key lookup. Signing only needs the latter; the explicit
    // address-import flow keeps the former as its default.
    writer.writeUint8(showAddressInDevice ? 0x00 : 0x01);
    writer.writeUint8(0x00); // P2_LAST
    writer.writeUint8(0x04); // Lc
    writer.writeUint32(accountIndex); // Account index as bytearray
    return [writer.toBytes()];
  }

  @override
  Future<List<String>> read(ByteDataReader reader) async {
    final response = reader.read(reader.remainingLength);
    // Mina addresses are 55 ASCII bytes; firmware may append a NUL terminator.
    final bytes = response.isNotEmpty && response.last == 0
        ? response.sublist(0, response.length - 1) : response;
    if (bytes.length != 55) {
      throw FormatException('Invalid Ledger address response length.');
    }
    return [
      ascii.decode(bytes),
    ];
  }
}
