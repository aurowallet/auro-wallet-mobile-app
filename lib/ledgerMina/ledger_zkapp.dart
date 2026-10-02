import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:auro_wallet/common/consts/index.dart';

enum LedgerZkAppFailure {
  invalidCommand,
  unsupportedStateLayout,
  accountNotSigner,
  feePayerRequired,
}

class LedgerZkAppException implements Exception {
  const LedgerZkAppException(this.failure);

  final LedgerZkAppFailure failure;
}

class LedgerZkAppFeePayer {
  const LedgerZkAppFeePayer({
    required this.feePayer,
    required this.fee,
    required this.nonce,
    required this.memo,
    required this.validUntil,
  });

  final String feePayer;
  final String fee;
  final String nonce;
  final String memo;
  final String? validUntil;

  Map<String, dynamic> toJson() => {
    'feePayer': feePayer,
    'fee': fee,
    'nonce': nonce,
    'memo': memo,
    'validUntil': validUntil,
  };
}

class LedgerZkAppSigningRequest {
  LedgerZkAppSigningRequest({
    required this.fieldElement,
    this.feePayer = false,
    List<int>? accountUpdateIndexes,
  }) : accountUpdateIndexes = accountUpdateIndexes ?? <int>[];

  final String fieldElement;
  bool feePayer;
  final List<int> accountUpdateIndexes;
}

class LedgerZkAppDraft {
  const LedgerZkAppDraft({
    required this.zkappCommand,
    required this.feePayer,
    required this.fromAddress,
    required this.feePayerTarget,
    required this.accountUpdateTargets,
  });

  final Map<String, dynamic> zkappCommand;
  final LedgerZkAppFeePayer feePayer;
  final String fromAddress;
  final bool feePayerTarget;
  final Map<int, bool> accountUpdateTargets;

  Map<String, dynamic> commitmentInput(String network) => {
    'network': network,
    'zkappCommand': zkappCommand,
    'feePayer': feePayer.toJson(),
  };
}

class PreparedLedgerZkApp {
  const PreparedLedgerZkApp({
    required this.zkappCommand,
    required this.feePayer,
    required this.signingRequests,
  });

  final Map<String, dynamic> zkappCommand;
  final LedgerZkAppFeePayer feePayer;
  final List<LedgerZkAppSigningRequest> signingRequests;

  Map<String, dynamic> get signedData => {
    'zkappCommand': zkappCommand,
    'feePayer': feePayer.toJson(),
  };
}

List<int> getZkAppStateLengths(Map<String, dynamic> zkappCommand) {
  final updates = zkappCommand['accountUpdates'];
  if (updates is! List) return const [];

  final lengths = <int>[];
  for (final update in updates) {
    if (update is! Map) continue;
    final body = update['body'];
    if (body is! Map) continue;

    final updateBody = body['update'];
    if (updateBody is Map && updateBody['appState'] is List) {
      lengths.add((updateBody['appState'] as List).length);
    }

    final preconditions = body['preconditions'];
    final account = preconditions is Map ? preconditions['account'] : null;
    if (account is Map && account['state'] is List) {
      lengths.add((account['state'] as List).length);
    }
  }
  return lengths;
}

bool hasUnsupportedZkAppStateLayout(Map<String, dynamic> zkappCommand) {
  final lengths = getZkAppStateLengths(zkappCommand);
  final hasBerkeley = lengths.contains(8);
  final hasMesa = lengths.contains(32);
  final hasUnknown = lengths.any((length) => length != 8 && length != 32);
  return hasUnknown || (hasBerkeley && hasMesa);
}

LedgerZkAppDraft createLedgerZkAppDraft({
  required dynamic transaction,
  required String fromAddress,
  required String fee,
  required String nonce,
  required String memo,
  required bool onlySign,
}) {
  final command = _parseCommand(transaction);
  if (hasUnsupportedZkAppStateLayout(command)) {
    throw const LedgerZkAppException(LedgerZkAppFailure.unsupportedStateLayout);
  }

  final feePayer = command['feePayer'];
  final feePayerBody = feePayer is Map ? feePayer['body'] : null;
  final accountUpdates = command['accountUpdates'];
  if (feePayerBody is! Map || accountUpdates is! List) {
    throw const LedgerZkAppException(LedgerZkAppFailure.invalidCommand);
  }

  final commandFeePayer = feePayerBody['publicKey']?.toString() ?? '';
  final useCommandFeePayer =
      commandFeePayer.isNotEmpty &&
      commandFeePayer != zkAppEmptyPublicKey &&
      commandFeePayer != fromAddress;
  final validUntilValue = feePayerBody['validUntil'];
  final validUntil = validUntilValue == null
      ? null
      : validUntilValue.toString();
  final nextFeePayer = LedgerZkAppFeePayer(
    feePayer: useCommandFeePayer ? commandFeePayer : fromAddress,
    fee: useCommandFeePayer ? feePayerBody['fee'].toString() : fee,
    nonce: useCommandFeePayer ? feePayerBody['nonce'].toString() : nonce,
    memo: useCommandFeePayer ? decodeLedgerMemo(command['memo']) : memo,
    validUntil: validUntil,
  );

  if (!onlySign && nextFeePayer.feePayer != fromAddress) {
    throw const LedgerZkAppException(LedgerZkAppFailure.feePayerRequired);
  }

  final updateTargets = <int, bool>{};
  for (var index = 0; index < accountUpdates.length; index++) {
    final update = accountUpdates[index];
    if (update is! Map) continue;
    final body = update['body'];
    if (body is! Map) continue;
    final authorizationKind = body['authorizationKind'];
    if (body['publicKey'] == fromAddress &&
        authorizationKind is Map &&
        authorizationKind['isSigned'] == true) {
      updateTargets[index] = body['useFullCommitment'] == true;
    }
  }

  final feePayerTarget = nextFeePayer.feePayer == fromAddress;
  if (!feePayerTarget && updateTargets.isEmpty) {
    throw const LedgerZkAppException(LedgerZkAppFailure.accountNotSigner);
  }

  return LedgerZkAppDraft(
    zkappCommand: command,
    feePayer: nextFeePayer,
    fromAddress: fromAddress,
    feePayerTarget: feePayerTarget,
    accountUpdateTargets: updateTargets,
  );
}

PreparedLedgerZkApp completeLedgerZkAppDraft(
  LedgerZkAppDraft draft, {
  required String commitment,
  required String fullCommitment,
}) {
  final command = draft.zkappCommand;
  command['feePayer'] = {
    'body': {
      'publicKey': draft.feePayer.feePayer,
      'fee': draft.feePayer.fee,
      'nonce': draft.feePayer.nonce,
      'validUntil': draft.feePayer.validUntil,
    },
    'authorization': '',
  };
  command['memo'] = encodeLedgerMemo(draft.feePayer.memo);

  final requests = <String, LedgerZkAppSigningRequest>{};
  void addTarget(String fieldElement, {bool feePayer = false, int? index}) {
    final request = requests.putIfAbsent(
      fieldElement,
      () => LedgerZkAppSigningRequest(fieldElement: fieldElement),
    );
    if (feePayer) request.feePayer = true;
    if (index != null) request.accountUpdateIndexes.add(index);
  }

  if (draft.feePayerTarget) {
    addTarget(fullCommitment, feePayer: true);
  }
  for (final target in draft.accountUpdateTargets.entries) {
    addTarget(target.value ? fullCommitment : commitment, index: target.key);
  }

  return PreparedLedgerZkApp(
    zkappCommand: command,
    feePayer: draft.feePayer,
    signingRequests: requests.values.toList(growable: false),
  );
}

void applyLedgerZkAppSignature(
  PreparedLedgerZkApp prepared,
  LedgerZkAppSigningRequest request,
  String signature,
) {
  if (request.feePayer) {
    (prepared.zkappCommand['feePayer'] as Map)['authorization'] = signature;
  }

  final updates = prepared.zkappCommand['accountUpdates'] as List;
  for (final index in request.accountUpdateIndexes) {
    if (index < 0 || index >= updates.length || updates[index] is! Map) {
      throw const LedgerZkAppException(LedgerZkAppFailure.invalidCommand);
    }
    (updates[index] as Map)['authorization'] = {'signature': signature};
  }
}

bool _hasLedgerSignature(
  Map<String, dynamic> command,
  LedgerZkAppSigningRequest request,
) {
  if (request.feePayer) {
    final authorization = command['feePayer'] is Map
        ? (command['feePayer'] as Map)['authorization']
        : null;
    if (authorization is! String || authorization.isEmpty) return false;
  }
  final updates = command['accountUpdates'];
  if (updates is! List) return false;
  for (final index in request.accountUpdateIndexes) {
    if (index < 0 || index >= updates.length || updates[index] is! Map) {
      return false;
    }
    final authorization = (updates[index] as Map)['authorization'];
    final signature = authorization is Map ? authorization['signature'] : null;
    if (signature is! String || signature.isEmpty) return false;
  }
  return true;
}

bool hasCompleteLedgerZkAppSignatures(PreparedLedgerZkApp prepared) {
  return prepared.signingRequests.every(
    (request) => _hasLedgerSignature(prepared.zkappCommand, request),
  );
}

Uint8List fieldElementToLedgerBytes(String fieldElement) {
  final value = BigInt.parse(fieldElement);
  if (value.isNegative || value >= (BigInt.one << 256)) {
    throw ArgumentError.value(fieldElement, 'fieldElement');
  }

  var remaining = value;
  final bytes = Uint8List(32);
  for (var index = 0; index < bytes.length; index++) {
    bytes[index] = (remaining & BigInt.from(0xff)).toInt();
    remaining >>= 8;
  }
  return bytes;
}

String ledgerFieldElementSignatureToBase58(Uint8List rawSignature) {
  if (rawSignature.length != 64) {
    throw ArgumentError.value(rawSignature.length, 'rawSignature');
  }

  final bytes = Uint8List(66)
    ..[0] = 154
    ..[1] = 1;
  for (var index = 0; index < 32; index++) {
    bytes[2 + index] = rawSignature[31 - index];
    bytes[34 + index] = rawSignature[63 - index];
  }
  return bs58check.encode(bytes);
}

String encodeLedgerMemo(String memo) {
  final memoBytes = utf8.encode(memo);
  if (memoBytes.length > 32) {
    throw ArgumentError.value(memo, 'memo', 'Memo exceeds 32 UTF-8 bytes');
  }
  final bytes = Uint8List(35)
    ..[0] = 20
    ..[1] = 1
    ..[2] = memoBytes.length;
  bytes.setRange(3, 3 + memoBytes.length, memoBytes);
  return bs58check.encode(bytes);
}

String decodeLedgerMemo(dynamic rawMemo) {
  if (rawMemo == null || rawMemo.toString().isEmpty) return '';
  try {
    final decoded = bs58check.decode(rawMemo.toString());
    if (decoded.length < 3) return rawMemo.toString();
    final length = decoded[2];
    if (decoded.length < 3 + length) return rawMemo.toString();
    return utf8.decode(decoded.sublist(3, 3 + length));
  } catch (_) {
    return rawMemo.toString();
  }
}

Map<String, dynamic> _parseCommand(dynamic transaction) {
  try {
    final decoded = transaction is String
        ? jsonDecode(transaction)
        : transaction;
    if (decoded is! Map) {
      throw const LedgerZkAppException(LedgerZkAppFailure.invalidCommand);
    }
    final copy = jsonDecode(jsonEncode(decoded));
    if (copy is! Map<String, dynamic>) {
      throw const LedgerZkAppException(LedgerZkAppFailure.invalidCommand);
    }
    return copy;
  } on LedgerZkAppException {
    rethrow;
  } catch (_) {
    throw const LedgerZkAppException(LedgerZkAppFailure.invalidCommand);
  }
}
