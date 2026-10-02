import 'dart:typed_data';

import 'package:auro_wallet/common/consts/network.dart';
import 'package:auro_wallet/ledgerMina/ledger_error.dart';
import 'package:auro_wallet/ledgerMina/ledger_status_code.dart';
import 'package:auro_wallet/ledgerMina/ledger_zkapp.dart';
import 'package:auro_wallet/ledgerMina/mina_transformer.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_public_key_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_sign_field_element_operation.dart';
import 'package:auro_wallet/ledgerMina/operations/mina_version_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_flutter/ledger_flutter.dart';

const _ledgerAddress = 'B62qledger';
const _otherAddress = 'B62qother';

Map<String, dynamic> _command({
  String feePayer = _ledgerAddress,
  List<int> stateLengths = const [32],
  bool signedByLedger = true,
}) {
  return {
    'feePayer': {
      'body': {
        'publicKey': feePayer,
        'fee': '100000000',
        'nonce': '7',
        'validUntil': 42,
      },
      'authorization': '',
    },
    'accountUpdates': [
      for (var index = 0; index < stateLengths.length; index++)
        {
          'body': {
            'publicKey': signedByLedger ? _ledgerAddress : _otherAddress,
            'useFullCommitment': index.isOdd,
            'authorizationKind': {'isSigned': true},
            'update': {'appState': List.filled(stateLengths[index], '0')},
            'preconditions': {
              'account': {'state': List.filled(stateLengths[index], '0')},
            },
          },
          'authorization': {'signature': null},
        },
    ],
    'memo': encodeLedgerMemo('original memo'),
  };
}

void main() {
  group('Ledger zkApp network resolution', () {
    test('uses the current Mainnet when the request omits networkId', () {
      final networkId = resolveEffectiveNetworkID(null, networkIDMap.mainnet);

      expect(resolveSignerNetwork(networkId), 'mainnet');
      expect(isMainnetLikeNetworkID(networkId), isTrue);
    });

    test('an explicit request network overrides the current network', () {
      final networkId = resolveEffectiveNetworkID(
        networkIDMap.testnet,
        networkIDMap.mainnet,
      );

      expect(resolveSignerNetwork(networkId), 'testnet');
      expect(isMainnetLikeNetworkID(networkId), isFalse);
    });
  });

  group('Ledger zkApp preparation', () {
    test('TC-LZK-001: preserves validUntil and deduplicates commitments', () {
      final command = _command(stateLengths: const [32, 32]);
      final draft = createLedgerZkAppDraft(
        transaction: command,
        fromAddress: _ledgerAddress,
        fee: '200000000',
        nonce: '9',
        memo: 'replacement memo',
        onlySign: false,
      );

      expect(draft.feePayer.validUntil, '42');
      expect(draft.feePayer.fee, '200000000');
      expect(draft.feePayer.nonce, '9');

      final prepared = completeLedgerZkAppDraft(
        draft,
        commitment: '11',
        fullCommitment: '22',
      );
      expect(prepared.signingRequests, hasLength(2));
      final full = prepared.signingRequests.singleWhere(
        (request) => request.fieldElement == '22',
      );
      expect(full.feePayer, isTrue);
      expect(full.accountUpdateIndexes, [1]);
      expect(prepared.zkappCommand['feePayer']['body']['validUntil'], '42');
      expect(
        decodeLedgerMemo(prepared.zkappCommand['memo']),
        'replacement memo',
      );

      applyLedgerZkAppSignature(prepared, full, 'full-signature');
      expect(
        prepared.zkappCommand['feePayer']['authorization'],
        'full-signature',
      );
      expect(prepared.zkappCommand['accountUpdates'][1]['authorization'], {
        'signature': 'full-signature',
      });
    });

    test('TC-LZK-002: supports account-update-only signing for onlySign', () {
      final draft = createLedgerZkAppDraft(
        transaction: _command(feePayer: _otherAddress),
        fromAddress: _ledgerAddress,
        fee: '1',
        nonce: '1',
        memo: 'ignored',
        onlySign: true,
      );

      expect(draft.feePayer.feePayer, _otherAddress);
      expect(draft.feePayer.memo, 'original memo');
      expect(draft.feePayerTarget, isFalse);
      expect(draft.accountUpdateTargets, {0: false});
    });

    test('TC-LZK-003: requires Ledger to be fee payer for broadcast', () {
      expect(
        () => createLedgerZkAppDraft(
          transaction: _command(feePayer: _otherAddress),
          fromAddress: _ledgerAddress,
          fee: '1',
          nonce: '1',
          memo: '',
          onlySign: false,
        ),
        throwsA(
          isA<LedgerZkAppException>().having(
            (error) => error.failure,
            'failure',
            LedgerZkAppFailure.feePayerRequired,
          ),
        ),
      );
    });

    test('TC-LZK-004: rejects mixed Berkeley and Mesa state layouts', () {
      expect(
        () => createLedgerZkAppDraft(
          transaction: _command(stateLengths: const [8, 32]),
          fromAddress: _ledgerAddress,
          fee: '1',
          nonce: '1',
          memo: '',
          onlySign: false,
        ),
        throwsA(
          isA<LedgerZkAppException>().having(
            (error) => error.failure,
            'failure',
            LedgerZkAppFailure.unsupportedStateLayout,
          ),
        ),
      );
    });

    test('TC-LZK-005: rejects commands that do not need this account', () {
      expect(
        () => createLedgerZkAppDraft(
          transaction: _command(feePayer: _otherAddress, signedByLedger: false),
          fromAddress: _ledgerAddress,
          fee: '1',
          nonce: '1',
          memo: '',
          onlySign: true,
        ),
        throwsA(
          isA<LedgerZkAppException>().having(
            (error) => error.failure,
            'failure',
            LedgerZkAppFailure.accountNotSigner,
          ),
        ),
      );
    });
  });

  group('Ledger zkApp wire format', () {
    test('TC-LZK-006: serializes a field element as 32-byte little-endian', () {
      final bytes = fieldElementToLedgerBytes('258');
      expect(bytes, hasLength(32));
      expect(bytes.take(4), [2, 1, 0, 0]);
    });

    test('TC-LZK-007: converts Ledger field/scalar response to Mina Base58', () {
      final raw = Uint8List(64)
        ..[31] = 1
        ..[63] = 2;
      expect(
        ledgerFieldElementSignatureToBase58(raw),
        '7mWxjLYgbJUkZNcGouvhVj5tJ8yu9hoexb9ntvPK8t5LHqznHsdGUiLYH8yWfoWvvhiptdCdFZxseHU8aHeV6GvUWN9aSeXD',
      );
    });

    test(
      'TC-LZK-007A: requires every Ledger signing request to be applied',
      () {
        final draft = createLedgerZkAppDraft(
          transaction: _command(stateLengths: const [32]),
          fromAddress: _ledgerAddress,
          fee: '1',
          nonce: '1',
          memo: '',
          onlySign: false,
        );
        final prepared = completeLedgerZkAppDraft(
          draft,
          commitment: '11',
          fullCommitment: '22',
        );

        expect(hasCompleteLedgerZkAppSignatures(prepared), isFalse);
        for (final request in prepared.signingRequests) {
          applyLedgerZkAppSignature(prepared, request, 'signature');
        }
        expect(hasCompleteLedgerZkAppSignatures(prepared), isTrue);
      },
    );

    test('TC-LZK-008: builds the Mina SIGN_FIELD_ELEMENT APDU', () async {
      final operation = MinaSignFieldElementOperation(
        accountIndex: 0x01020304,
        networkId: 1,
        fieldElement: Uint8List.fromList(List.generate(32, (index) => index)),
      );
      final packets = await operation.write(ByteDataWriter());

      expect(packets, hasLength(1));
      expect(packets.single.take(10), [
        0xe0,
        0x06,
        0x00,
        0x00,
        37,
        1,
        2,
        3,
        4,
        1,
      ]);
      expect(packets.single.length, 42);
    });

    test('TC-LZK-008A: accepts Mina signature response tail', () async {
      final operation = MinaSignFieldElementOperation(
        accountIndex: 0,
        networkId: 1,
        fieldElement: Uint8List(32),
      );
      final reader = ByteDataReader();
      reader.add(Uint8List(97));

      final signature = await operation.read(reader);

      expect(signature, hasLength(64));
      expect(reader.remainingLength, 33);
    });

    test('TC-LZK-009: Mina memo uses UTF-8 byte length and round-trips', () {
      const memo = 'Mina test';
      expect(decodeLedgerMemo(encodeLedgerMemo(memo)), memo);
      expect(
        () => encodeLedgerMemo(List.filled(11, '测').join()),
        throwsArgumentError,
      );
    });
  });

  test('TC-LZK-010: classifies stable Ledger status codes', () {
    expect(classifyLedgerErrorCode(27013), LedgerFailureType.rejected);
    expect(classifyLedgerErrorCode(36865), LedgerFailureType.busy);
    // The upstream BLE reader can surface high-bit APDU status words as a
    // signed int16. Keep the UI classification independent of that transport
    // representation.
    expect(classifyLedgerErrorCode(-28671), LedgerFailureType.busy);
    expect(classifyLedgerErrorCode(21781), LedgerFailureType.locked);
    expect(classifyLedgerErrorCode(27014), LedgerFailureType.rejected);
    expect(classifyLedgerErrorCode(21761), LedgerFailureType.rejected);
    expect(classifyLedgerErrorCode(25873), LedgerFailureType.appNotOpen);
    expect(classifyLedgerErrorCode(28161), LedgerFailureType.appNotOpen);
    expect(classifyLedgerErrorCode(27904), LedgerFailureType.unsupported);
    expect(classifyLedgerErrorCode(28160), LedgerFailureType.unsupported);
  });

  test('TC-LZK-010A: APDU status takes priority over pairing text', () {
    expect(
      classifyLedgerError(LedgerException(
        errorCode: LedgerStatusCode.mobileMinaAppNotOpen,
        message: 'CBError Code 14 peer removed pairing information',
      )),
      LedgerFailureType.appNotOpen,
    );
    expect(classifyLedgerError(StateError('CBError Code=14')),
        LedgerFailureType.pairing);
    expect(classifyLedgerError(StateError('CBError Code=140')),
        LedgerFailureType.other);
    expect(
      isLedgerPairingMismatch(
        LedgerFailureType.other,
        'connection timed out while waiting for pairing',
      ),
      isFalse,
    );
    expect(
      isLedgerPairingMismatch(LedgerFailureType.other, 'CBError Code 140'),
      isFalse,
    );
    expect(
      isLedgerPairingMismatch(
        LedgerFailureType.appNotOpen,
        'pairing code=14 reported by a stale transport callback',
      ),
      isFalse,
    );
    expect(
      isLedgerPairingMismatch(
        LedgerFailureType.other,
        'CBError Code 14 pairing failed',
      ),
      isTrue,
    );
  });

  test(
    'Mina GET_VERSION uses the APDU form with an explicit zero Lc',
    () async {
      final writer = ByteDataWriter();
      final packets = await MinaVersionOperation().write(writer);

      expect(packets.single, [0xe0, 0x01, 0x00, 0x00, 0x00]);
    },
  );

  test('APDU errors keep their status even when they include a payload', () async {
    for (final status in [0x6511, 0x6e01, 0x5515, 0x9001, 0x6985, 0x6d00]) {
      for (final payload in [<int>[], [1, 2, 3]]) {
        await expectLater(
          const MinaTransformer().onTransform([
            Uint8List.fromList([...payload, status >> 8, status & 0xff]),
          ]),
          throwsA(isA<LedgerException>().having((e) => e.errorCode, 'status', status)),
        );
      }
    }
  });

  test('APDU success strips status and rejects incomplete responses', () async {
    expect(await const MinaTransformer().onTransform([
      Uint8List.fromList([0x90, 0]),
      Uint8List.fromList([1, 2, 3, 0x90, 0]),
    ]), [1, 2, 3]);
    for (final response in [<int>[], [0x90]]) {
      await expectLater(
        const MinaTransformer().onTransform([Uint8List.fromList(response)]),
        throwsFormatException,
      );
    }
    await expectLater(
      const MinaTransformer().onTransform([
        Uint8List.fromList([1, 0x55, 0x15]),
        Uint8List.fromList([2, 0x90, 0]),
      ]),
      throwsA(isA<LedgerException>().having((e) => e.errorCode, 'status', 0x5515)),
    );
  });

  test('address responses support an optional NUL without truncating the address', () async {
    const address = 'B62qkzCugh8u2Ez1vEs7i3UjW7iypA8ovwC88rBwLqZmdWFqh96M8rM';
    for (final suffix in [<int>[], [0]]) {
      final reader = ByteDataReader()..add([...address.codeUnits, ...suffix]);
      expect(await MinaPublicKeyOperation().read(reader), [address]);
    }
    for (final response in [
      <int>[],
      address.codeUnits.sublist(1),
      [...address.codeUnits, 65],
      [255, ...address.codeUnits.sublist(1)],
    ]) {
      await expectLater(
        MinaPublicKeyOperation().read(ByteDataReader()..add(response)),
        throwsFormatException,
      );
    }
  });

  test(
    'Mina public-key lookup distinguishes silent and on-device address modes',
    () async {
      final silentPackets = await MinaPublicKeyOperation(
        accountIndex: 0x01020304,
        showAddressInDevice: false,
      ).write(ByteDataWriter());
      final displayPackets = await MinaPublicKeyOperation(
        accountIndex: 0x01020304,
        showAddressInDevice: true,
      ).write(ByteDataWriter());

      expect(silentPackets.single.take(5), [0xe0, 0x02, 0x01, 0x00, 0x04]);
      expect(displayPackets.single.take(5), [0xe0, 0x02, 0x00, 0x00, 0x04]);
    },
  );
}
