import 'dart:typed_data';

import 'package:auro_wallet/utils/format.dart';
import 'package:convert/convert.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

/// GET VERSION APDU PROTOCOL:
///
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md#get_version
class MinaNameOperation extends LedgerOperation<LedgerAppName> {
  MinaNameOperation();

  @override
  Future<List<Uint8List>> write(ByteDataWriter writer) async {
    writer.writeUint8(0xb0); // LEDGER_CLA
    writer.writeUint8(0x01); // INS
    writer.writeUint8(0x00); // P1_FIRST
    writer.writeUint8(0x00); // P2_LAST
    return [writer.toBytes()];
  }

  @override
  Future<LedgerAppName> read(ByteDataReader reader) async {
    print('version back');
    final response = hex.encode(reader.read(reader.remainingLength));
    final info = response.substring(4);

    final returnCode = response.substring(0, 2).toString();
    final separatorPosition = info.lastIndexOf('05');
    final name = Fmt.hexToAscii(info.substring(0, separatorPosition));
    final version = String.fromCharCodes(
        hex.decode(info.substring(separatorPosition + 2, info.length)));

    return LedgerAppName(name, version, returnCode);
  }
}

class LedgerAppName {
  LedgerAppName(this.name, this.version, this.returnCode);

  final String name;
  final String version;
  final String returnCode;
}
