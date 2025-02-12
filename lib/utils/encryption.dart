import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:auro_wallet/store/wallet/types/seedData.dart';
import 'package:encrypt/encrypt.dart' as encryptLibs;
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:webcrypto/webcrypto.dart' as webcrypto;

class Encryption {
  static late final SodiumSumo sodium;
  static bool _inited = false;

  static Future<void> initializeSodium() async {
    if (!_inited) {
      sodium = await SodiumSumoInit.init();
      _inited = true;
    }
  }

  static encryptLibs.Key generateSecret() {
    return encryptLibs.Key.fromSecureRandom(32);
  }

  static encryptLibs.IV generateIV() {
    return encryptLibs.IV.fromSecureRandom(16);
  }

  Future<Map<String, dynamic>> encrypt(
      {required String password, required String content}) async {
    var encryptedMap =
        await _encrypt({"password": password, "content": content});
    return encryptedMap;
  }

  static Future<Uint8List> password2Hash(String pwd, Uint8List salt) async {
    await initializeSodium();
    SecureKey secureKey = sodium.crypto.pwhash(
      outLen: 32,
      password: Int8List.fromList(pwd.codeUnits),
      salt: salt,
      opsLimit: 3,
      memLimit: sodium.crypto.pwhash.memLimitInteractive,
      alg: CryptoPwhashAlgorithm.argon2id13,
    );
    final keyBytes = secureKey.extractBytes();
    secureKey.dispose();
    return keyBytes;
  }

  static Future<Map<String, dynamic>> _encrypt(Map<String, String> msg) async {
    String password = msg["password"]!;
    String content = msg["content"]!;
    encryptLibs.IV iv = generateIV();
    encryptLibs.Key secret = generateSecret();
    encryptLibs.Key salt = encryptLibs.Key.fromSecureRandom(16);
    Uint8List rawKey = await password2Hash(password, salt.bytes);
    final aesGcmPwdKey = await webcrypto.AesGcmSecretKey.importRawKey(rawKey);// 这里看一下能否替换掉，使用 sodium_libs
    final encryptedSecretBytes =
        await aesGcmPwdKey.encryptBytes(secret.bytes, iv.bytes, tagLength: 128);

    final aesGcmSecretKey =
        await webcrypto.AesGcmSecretKey.importRawKey(secret.bytes);
    Uint8List data = Uint8List.fromList(content.codeUnits);
    final encryptedBytes =
        await aesGcmSecretKey.encryptBytes(data, iv.bytes, tagLength: 128);

    return SeedData(
            encrypted: convert.base64.encode(encryptedBytes),
            iv: iv.base64,
            salt: salt.base64,
            encryptedSecret: convert.base64.encode(encryptedSecretBytes),
            version: 3)
        .toJson();
  }

  static aesEncrypt(String key, String message, Uint8List iv) async {
    final aesGcmSecretKey = await webcrypto.AesGcmSecretKey.importRawKey(
        Uint8List.fromList(key.codeUnits));
    Uint8List data = Uint8List.fromList(message.codeUnits);
    final encryptedBytes = await aesGcmSecretKey.encryptBytes(data, iv);
    return convert.base64.encode(encryptedBytes);
  }

  Future<String?> decrypt({
    required Map<String, dynamic> data,
    required String password,
  }) async {
    String? encryptedStr = await _decrypt({"data": data, "password": password});
    return encryptedStr;
  }

  Future<String?> _decrypt(msg) async {
    Map<String, dynamic> data = msg["data"]!;
    String password = msg["password"]!;
    var seedData = SeedData.fromJson(data);
    encryptLibs.IV iv = encryptLibs.IV.fromBase64(seedData.iv);
    encryptLibs.Key salt = encryptLibs.Key.fromBase64(seedData.salt);
    encryptLibs.Key? pwdKey;
    try {
      if (seedData.version == 3) {
        Uint8List rawKey = await password2Hash(password, salt.bytes);
        final aesGcmPwdKey =
            await webcrypto.AesGcmSecretKey.importRawKey(rawKey);
        final decryptedSecretBytes = await aesGcmPwdKey.decryptBytes(
            convert.base64.decode(seedData.encryptedSecret), iv.bytes,
            tagLength: 128);
        final aesGcmSecretKey =
            await webcrypto.AesGcmSecretKey.importRawKey(decryptedSecretBytes);
        final decryptedContentBytes = await aesGcmSecretKey.decryptBytes(
            convert.base64.decode(seedData.encrypted), iv.bytes,
            tagLength: 128);
        String decryptedString = String.fromCharCodes(decryptedContentBytes);
        return decryptedString;
      } else {
        if (seedData.version == 2) {
          Uint8List keyV2 = await password2Hash(password, salt.bytes);
          pwdKey = encryptLibs.Key(keyV2);
        } else {
          pwdKey =
              encryptLibs.Key.fromUtf8(password).stretch(32, salt: salt.bytes);
        }
        final secretEncrypter = encryptLibs.Encrypter(encryptLibs.AES(pwdKey));
        final String secretBase64 =
            secretEncrypter.decrypt64(seedData.encryptedSecret, iv: iv);

        encryptLibs.Key secret = encryptLibs.Key.fromBase64(secretBase64);
        final contentEncrypter = encryptLibs.Encrypter(encryptLibs.AES(secret));
        final String decryptedContent =
            contentEncrypter.decrypt64(seedData.encrypted, iv: iv);
        return decryptedContent;
      }
    } catch (e) {
      return null;
    }
  }

}