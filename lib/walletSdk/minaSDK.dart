import 'dart:convert';
import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/foundation.dart';
import "package:hex/hex.dart";
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:auro_wallet/walletSdk/types.dart';
import 'package:auro_wallet/common/consts/settings.dart';

final DynamicLibrary libMinaSigner = Platform.isAndroid
    ? DynamicLibrary.open("libmina_sdk.so")
    : DynamicLibrary.process();

typedef PrivhexToAddressDart = void Function(Pointer<Utf8> address, Pointer<Utf8> priv_hex);
typedef PrivhexToAddress = Void Function(Pointer<Utf8> address, Pointer<Utf8> priv_hex);
final PrivhexToAddressDart privhexToAddress = libMinaSigner
    .lookup<NativeFunction<PrivhexToAddress>>('privhex_to_address')
    .asFunction();

typedef SignTransactionDart = int Function(
    Pointer<Utf8> field,
    Pointer<Utf8> scalar,
    Pointer<Utf8> sender_priv_hex,
    Pointer<Utf8> receiver_address,
    int amount,
    int fee,
    int nonce,
    int valid_until,
    Pointer<Utf8> memo,
    int delegation,
    int network_id
    );

typedef SignTransaction = Uint8 Function(
    Pointer<Utf8> field,
    Pointer<Utf8> scalar,
    Pointer<Utf8> sender_priv_hex,
    Pointer<Utf8> receiver_address,
    Uint64 amount,
    Uint64 fee,
    Uint32 nonce,
    Uint32 valid_until,
    Pointer<Utf8> memo,
    Uint8 delegation,
    Uint8 network_id
    );

final SignTransactionDart signTransaction = libMinaSigner
    .lookup<NativeFunction<SignTransaction>>('sign_transaction')
    .asFunction();

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

Future<String> getAddressFromPrivateKey(String privateKeyHex) async{
  final Pointer<Utf8> privateKeyHexNative = privateKeyHex.toNativeUtf8();
  final address = calloc<Uint8>(56);
  final Pointer<Utf8> addressNative = address.cast();

  privhexToAddress(addressNative, privateKeyHexNative);
  final addressStr = addressNative.toDartString();

  calloc.free(addressNative);
  calloc.free(privateKeyHexNative);
  return addressStr;
}

Future<Map> signPayment(
    {
      required String privateKey,
      required String from,
      required String to,
      required double amount,
      required double fee,
      required int nonce,
      required String memo
    }) async {
  final Pointer<Utf8> privateHexNative = getRawPrivateKey(privateKey).toNativeUtf8();
  final field = calloc<Uint8>(78);
  final scalar = calloc<Uint8>(78);
  final Pointer<Utf8> fieldNative = field.cast();
  final Pointer<Utf8> scalarNative = scalar.cast();
  final Pointer<Utf8> toNative = to.toNativeUtf8();
  final Pointer<Utf8> memoNative = memo.toNativeUtf8();
  final feeLarge = BigInt.from(pow(10, COIN.decimals) * fee).toInt();
  final amountLarge = BigInt.from(pow(10, COIN.decimals) * amount).toInt();
  signTransaction(
      fieldNative,
      scalarNative,
      privateHexNative,
      toNative,
      amountLarge,
      feeLarge,
      nonce,
      4294967295,
      memoNative,
      0,
      1
  );
  final fieldStr = fieldNative.toDartString();
  final scalarStr = scalarNative.toDartString();
  calloc.free(fieldNative);
  calloc.free(scalarNative);
  calloc.free(privateHexNative);
  calloc.free(toNative);
  calloc.free(memoNative);
  return prepareBroadcastBody(
      field: fieldStr,
      scalar: scalarStr,
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
      required String memo
    }) async {
  final Pointer<Utf8> privateHexNative = getRawPrivateKey(privateKey).toNativeUtf8();
  final field = calloc<Uint8>(78);
  final scalar = calloc<Uint8>(78);
  final Pointer<Utf8> fieldNative = field.cast();
  final Pointer<Utf8> scalarNative = scalar.cast();
  final Pointer<Utf8> toNative = to.toNativeUtf8();
  final Pointer<Utf8> memoNative = memo.toNativeUtf8();
  final feeLarge = BigInt.from(pow(10, COIN.decimals)* fee).toInt();
  int success = signTransaction(
      fieldNative,
      scalarNative,
      privateHexNative,
      toNative,
      0,
      feeLarge,
      nonce,
      4294967295,
      memoNative,
      1,
      1
  );
  final fieldStr = fieldNative.toDartString();
  final scalarStr = scalarNative.toDartString();
  calloc.free(fieldNative);
  calloc.free(scalarNative);
  calloc.free(privateHexNative);
  calloc.free(toNative);
  calloc.free(memoNative);
  return prepareBroadcastBody(
      field: fieldStr,
      scalar: scalarStr,
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