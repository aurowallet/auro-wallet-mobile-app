import 'dart:typed_data';

import 'package:ledger_flutter/ledger_flutter.dart';

import '../mina_version.dart';

/// GET VERSION APDU PROTOCOL:
///
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md#get_version
class MinaVersionOperation extends LedgerOperation<MinaVersion> {
  MinaVersionOperation();

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.writeUint8(0xe0); // MINA_CLA
    writer.writeUint8(0x01); // INS
    writer.writeUint8(0x00); // P1_FIRST
    writer.writeUint8(0x00); // P2_LAST
    writer.writeUint8(0x04); //
    writer.writeUint32(0x00); //
    return [writer.toBytes()];
  }

  @override
  Future<MinaVersion> read(ByteDataReader reader) async {
    print('mina version back');
    // print(reader.toString());
    // print(hex.encode(reader.read(reader.remainingLength)));
    final versionMajor = reader.readUint8();
    final versionMinor = reader.readUint8();
    final versionPatch = reader.readUint8();

    return MinaVersion(
      // testMode: testMode != 0,
      versionMajor: versionMajor,
      versionMinor: versionMinor,
      versionPatch: versionPatch,
      // locked: locked != 0,
    );
  }
}
