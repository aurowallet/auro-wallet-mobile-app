import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX
import 'dart:math';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/foundation.dart';
import "package:hex/hex.dart";
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:auro_wallet/walletSdk/types.dart';
import 'package:auro_wallet/common/consts/settings.dart';

import 'package:auro_wallet/walletSdk/rust_api_generated.dart';
const base = 'rust-signer';
final path = 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : DynamicLibrary.open(path);
late final api = RustSignerImpl(dylib);

String generateRandMnemonic() {
  String randomMnemonic = bip39.generateMnemonic();
  return randomMnemonic;
}

Future<Map<String, dynamic>> createWallet(String seed, String seedType) async {
  switch (seedType) {
    case 'priKey':
      return await createAccountByPrivateKey(seed);
    case 'mnemonic':
    default:
      return await createWalletByMnemonic(seed, 0, false);
  }
}

Future<Map<String, dynamic>> createAccountByPrivateKey(String privateKey) async {
  final String privateHex = getRawPrivateKey(privateKey);
  final addressStr = await compute(getAddressFromPrivateKey, privateHex);
  final res =  {
    "pubKey": addressStr,
    "priKey": privateKey
  };
  return res;
}

Future<Map<String, dynamic>> createWalletByMnemonic(String mnemonic, int accountIndex, bool needPrivateKey) async {
  Uint8List seed = await compute(bip39.mnemonicToSeed, mnemonic);
  bip32.BIP32 masterNode = bip32.BIP32.fromSeed(seed);
  String hdPath = "m/44'/12586'/$accountIndex'/0/0";
  bip32.BIP32 child0 = masterNode.derivePath(hdPath);

  Uint8List rawPrivateKey = child0.privateKey!;
  rawPrivateKey[0] &= 0x3f;
  final privateKeyHex = HEX.encode(rawPrivateKey);


  final addressStr = await compute(getAddressFromPrivateKey, privateKeyHex);

  final prefixedPri = HEX.decode('5a01${HEX.encode(reverse(child0.privateKey!))}');
  String decodedPrivateKey = bs58check.encode(Uint8List.fromList(prefixedPri));

  final res =  {
    "pubKey": addressStr,
    "hdIndex": accountIndex,
    "mnemonic": mnemonic,
  };
  if (needPrivateKey) {
    res["priKey"] = decodedPrivateKey;
  }
  return res;
}

bool ifAddressValid(String address) {
  try {
    if(!address.toLowerCase().startsWith('b62')) {
      return false;
    }
    final decodedAddress = HEX.encode(bs58check.decode(address));
    return decodedAddress.length == 72;
  } catch (ex) {
    return false;
  }
}

bool ifPrivateKeyValid(String private) {
  try {
    if(!private.toLowerCase().startsWith('ek')) {
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


Future<Map> signPayment(
    {
      required String privateKey,
      required String from,
      required String to,
      required double amount,
      required double fee,
      required int nonce,
      required String memo,
      int networkId = 1
    }) async {
  final  privateHex = getRawPrivateKey(privateKey);
  final feeLarge = BigInt.from(pow(10, COIN.decimals) * fee).toInt();
  final amountLarge = BigInt.from(pow(10, COIN.decimals) * amount).toInt();
  final sigData = await api.signPayment(
      secretHex: privateHex,
      to: to,
      amount: amountLarge,
      fee: feeLarge,
      nonce: nonce,
      validUntil: 4294967295,
      memo: memo,
      networkId: networkId
  );
  return prepareBroadcastBody(
      field: sigData.field,
      scalar: sigData.scalar,
      from: from,
      to: to,
      fee: feeLarge,
      amount: amountLarge,
      nonce: nonce,
      memo: memo,
      validUntil: 4294967295
  );
}

Future<Map> signDelegation(
    {
      required String privateKey,
      required String from,
      required String to,
      required double fee,
      required int nonce,
      required String memo,
      int networkId = 1
    }) async {
  final  privateHex = getRawPrivateKey(privateKey);
  final feeLarge = BigInt.from(pow(10, COIN.decimals)* fee).toInt();

  final sigData = await api.signDelegation(
      secretHex: privateHex,
      to: to,
      fee: feeLarge,
      nonce: nonce,
      validUntil: 4294967295,
      memo: memo,
      networkId: networkId
  );

  return prepareBroadcastBody(
      field: sigData.field,
      scalar: sigData.scalar,
      from: from,
      to: to,
      fee: feeLarge,
      amount: 0,
      nonce: nonce,
      memo: memo,
      validUntil: 4294967295
  );
}

Map prepareBroadcastBody ({
  required String field,
  required String scalar,
  required int fee,
  required String from,
  required String to,
  required int nonce,
  required int amount,
  required String memo,
  required int validUntil,
}) {
  return {
    "payload": {
      "fee": fee,
      "from": from,
      "to": to,
      "nonce": nonce,
      "amount": amount,
      "memo": memo,
      "validUntil": validUntil,
    },
    "signature": {
      "field": field,
      "scalar": scalar,
    }
  };
}

Uint8List reverse(Uint8List bytes) {
  Uint8List reversed = Uint8List(bytes.length);
  for (int i = bytes.length; i > 0; i--) {
    reversed[bytes.length - i] = bytes[i - 1];
  }
  return reversed;
}


Future<String> getAddressFromPrivateKey(String privateKeyHex) async{
  return api.getAddressFromSecretHex(secretHex: privateKeyHex);
}
