import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX
import 'dart:math';
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/foundation.dart';
import "package:hex/hex.dart";
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:auro_wallet/walletSdk/types.dart';
import 'package:auro_wallet/common/consts/settings.dart';

// import 'package:auro_wallet/walletSdk/rust_api_generated.dart';

final path = 'librust_signer.so'; 
late final dylib =
    Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(path);
// late final api = RustSignerImpl(dylib);

String generateRandMnemonic() {
  String randomMnemonic = bip39.generateMnemonic();
  return randomMnemonic;
}


bool ifAddressValid(String address) {
  try {
    if (!address.toLowerCase().startsWith('b62')) {
      return false;
    }
    final decodedAddress = HEX.encode(bs58check.decode(address));
    return decodedAddress.length == 72;
  } catch (ex) {
    return false;
  }
}

String bs58Decode(String str) {
  Uint8List bytes = bs58check.decode(str);
  if (bytes[2] == 0) {
    return '';
  }
  return utf8.decode(bytes.sublist(3, 3 + bytes[2]));
}

bool ifPrivateKeyValid(String private) {
  try {
    if (!private.toLowerCase().startsWith('ek')) {
      return false;
    }
    final decodedPrivateKey = getRawPrivateKey(private);
    return decodedPrivateKey.length == 64;
  } catch (ex) {
    return false;
  }
}

String getRawPrivateKey(String privateKey) {
  final privateKeyBytes = bs58check.decode(privateKey).sublist(2);
  final reversedPrivateKeyBytes = reverse(privateKeyBytes);
  final rawPrivateHex = HEX.encode(reversedPrivateKeyBytes);
  return rawPrivateHex;
}

Map prepareBroadcastBody(
    {String? field,
    String? scalar,
    String? rawSignature,
    required int fee,
    required String from,
    required String to,
    required int nonce,
    required int amount,
    required String memo,
    required String validUntil}) {
  Map res = {
    "payload": {
      "fee": fee,
      "from": from,
      "to": to,
      "nonce": nonce,
      "amount": amount,
      "memo": memo,
      "validUntil": validUntil,
    }
  };
  if (rawSignature != null) {
    res['signature'] = {"rawSignature": rawSignature};
  } else {
    res['signature'] = {
      "field": field,
      "scalar": scalar,
    };
  }
  return res;
}

Uint8List reverse(Uint8List bytes) {
  Uint8List reversed = Uint8List(bytes.length);
  for (int i = bytes.length; i > 0; i--) {
    reversed[bytes.length - i] = bytes[i - 1];
  }
  return reversed;
}