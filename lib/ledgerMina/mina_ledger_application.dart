import 'dart:typed_data';

import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

import 'mina_transformer.dart';
import 'mina_version.dart';
import 'operations/mina_public_key_operation.dart';
import 'operations/mina_sign_msgpack_operation.dart';
import 'operations/mina_version_operation.dart';

/// A [LedgerApp] used to perform BLE operations on a ledger [Algorand]
/// application.
///
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaLedgerApp extends LedgerApp {
  static const errorExecution = 0x6400;
  static const errorEmptyBuffer = 0x6982;
  static const errorOutputBufferTooSmall = 0x6983;
  static const errorCommandNotAllowed = 0x6986;
  static const errorInsNotSupported = 0x6D00;
  static const errorClaNotSupported = 0x6E00;
  static const errorUnknown = 0x6F00;
  static const success = 0x8000;

  int accountIndex;
  LedgerTransformer? transformer;

  MinaLedgerApp(
    super.ledger, {
    this.accountIndex = 0,
    this.transformer = const MinaTransformer(),
  });

  Future<LedgerAppName> getAppName(LedgerDevice device) {
    return ledger.sendOperation<LedgerAppName>(
      device,
      MinaNameOperation(),
      transformer: transformer,
    );
  }

  @override
  Future<MinaVersion> getVersion(LedgerDevice device) {
    return ledger.sendOperation<MinaVersion>(
      device,
      MinaVersionOperation(),
      transformer: transformer,
    );
  }

  @override
  Future<List<String>> getAccounts(LedgerDevice device) async {
    return ledger.sendOperation<List<String>>(
      device,
      MinaPublicKeyOperation(accountIndex: accountIndex),
      transformer: transformer,
    );
  }

  @override
  Future<Uint8List> signTransaction(
    LedgerDevice device,
    Uint8List transaction,
  ) {
    return ledger.sendOperation<Uint8List>(
      device,
      MinaSignMsgPackOperation(
        accountIndex: accountIndex,
        transaction: transaction,
      ),
      transformer: transformer,
    );
  }

  @override
  Future<List<Uint8List>> signTransactions(
    LedgerDevice device,
    List<Uint8List> transactions,
  ) async {
    final signatures = <Uint8List>[];
    for (var tx in transactions) {
      final signature = await signTransaction(device, tx);
      signatures.add(signature);
    }

    return signatures;
  }
}
