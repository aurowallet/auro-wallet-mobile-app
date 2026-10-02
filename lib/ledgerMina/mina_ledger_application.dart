import 'dart:convert';
import 'dart:typed_data';

import 'package:auro_wallet/ledgerMina/operations/mina_name_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_sign_transfer_operation.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

import 'ledger_error.dart';
import 'ledger_status_code.dart';
import 'mina_transformer.dart';
import 'mina_version.dart';
import 'operations/mina_public_key_operation.dart';
import 'operations/mina_sign_field_element_operation.dart';
import 'operations/mina_sign_msgpack_operation.dart';
import 'operations/mina_version_operation.dart';

/// A [LedgerApp] used to perform BLE operations on a ledger [Algorand]
/// application.
///
/// https://github.com/LedgerHQ/app-algorand/blob/develop/docs/APDUSPEC.md
class MinaLedgerApp extends LedgerApp {
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
  Future<void> ensureMinaAppReady(LedgerDevice device) async {
    final app = await getAppName(device);
    if (app.name.toLowerCase() != 'mina') {
      throw LedgerException(
        errorCode: LedgerStatusCode.mobileMinaAppNotOpen,
        message: 'Open the Mina app on Ledger.',
      );
    }
    await getVersion(device);
  }

  Future<void> ensureMinaAppReadyWithRetry(LedgerDevice device,
      {required bool Function() isCurrent}) async {
    for (var attempt = 0; attempt < 3 && isCurrent(); attempt++) {
      try {
        await ensureMinaAppReady(device);
        return;
      } catch (error, stackTrace) {
        if (error is! LedgerException ||
            !classifyLedgerError(error).canRetryReadiness || attempt == 2) {
          ledgerErrorLog('Ledger connection readiness attempt=${attempt + 1}',
              error, stackTrace: stackTrace);
          rethrow;
        }
      }
      if (!isCurrent()) return;
      await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
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
  Future<List<String>> getAccounts(LedgerDevice device,
      {bool showAddressInDevice = true}) async {
    return ledger.sendOperation<List<String>>(
      device,
      MinaPublicKeyOperation(
          accountIndex: accountIndex, showAddressInDevice: showAddressInDevice),
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

  Future<String> signTransfer(LedgerDevice device,
      {required int txType,
      required int senderAccount,
      required String senderAddress,
      required String receiverAddress,
      required int amount,
      required int fee,
      required int nonce,
      validUntil = 4294967295,
      memo = "",
      required int networkId}) async {
    final transaction = createTXApdu(
        txType: txType,
        senderAccount: senderAccount,
        senderAddress: senderAddress,
        receiverAddress: receiverAddress,
        amount: amount,
        memo: memo,
        fee: fee,
        nonce: nonce,
        networkId: networkId);
    return ledger.sendOperation<String>(
      device,
      MinaSignTransferOperation(
        transaction: transaction,
      ),
      transformer: transformer,
    );
  }

  /// Signs a zkApp transaction commitment or fullCommitment, including token transfers.
  /// The method name matches Ledger's SIGN_FIELD_ELEMENT instruction.
  Future<Uint8List> signFieldElement(
    LedgerDevice device, {
    required int senderAccount,
    required int networkId,
    required Uint8List fieldElement,
  }) {
    return ledger.sendOperation<Uint8List>(
      device,
      MinaSignFieldElementOperation(
        accountIndex: senderAccount,
        networkId: networkId,
        fieldElement: fieldElement,
      ),
      transformer: transformer,
    );
  }

  Uint8List createTXApdu(
      {required int txType,
      required int senderAccount,
      required String senderAddress,
      required String receiverAddress,
      required int amount,
      required int fee,
      required int nonce,
      validUntil = 4294967295,
      memo = "",
      required int networkId}) {
    ByteDataWriter writer = new ByteDataWriter();
    writer.writeUint32(senderAccount);
    writer.write(utf8.encode(senderAddress));
    writer.write(utf8.encode(receiverAddress));
    writer.writeUint64(amount);
    writer.writeUint64(fee);
    writer.writeUint32(nonce);
    writer.writeUint32(validUntil);
    writer.write(convertMemo(memo));
    writer.writeUint8(txType);
    writer.writeUint8(networkId);
    return writer.toBytes();
  }

  List<int> convertMemo(String memo) {
    const length = 32;
    var charToAdd = length - utf8.encode(memo).length;
    var stringToReturn = memo;
    while (charToAdd > 0) {
      stringToReturn += "\x00";
      charToAdd--;
    }
    return utf8.encode(stringToReturn);
  }
}

enum TxType { PAYMENT, DELEGATION }

extension TxTypeExtension on TxType {
  int get value {
    switch (this) {
      case TxType.PAYMENT:
        return 0x00;
      case TxType.DELEGATION:
        return 0x04;
    }
  }
}

enum Networks { MAINNET, DEVNET }

extension NetworksExtension on Networks {
  int get value {
    switch (this) {
      case Networks.MAINNET:
        return 0x01;
      case Networks.DEVNET:
        return 0x00;
    }
  }
}
