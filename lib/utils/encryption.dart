import 'package:auro_wallet/store/wallet/types/seedData.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encryptLibs;
import 'dart:io' show Platform;
import 'package:flutter_sodium/flutter_sodium.dart';
import 'dart:typed_data';
bool _inited = false;

class Encryption {
  static encryptLibs.Key generateSecret() {
    return encryptLibs.Key.fromSecureRandom(32);
  }

  static encryptLibs.IV generateIV() {
    return encryptLibs.IV.fromSecureRandom(16);
  }

  Future<Map<String, dynamic>> encrypt({required String password,required String content}) async {
    var encryptedMap = await compute(_encrypt, {"password": password, "content": content});
    return encryptedMap;
  }

  static Uint8List password2Hash(String pwd, Uint8List salt) {
    if (!_inited) {
      Sodium.init();
      _inited = true;
    }
    Uint8List key = Sodium.cryptoPwhash(32,
        Uint8List.fromList(pwd.codeUnits),
        salt,
        3,
        Sodium.cryptoPwhashMemlimitInteractive,
        Sodium.cryptoPwhashAlgArgon2id13);
    return key;
  }

  static Map<String, dynamic> _encrypt(Map<String, String> msg) {
    String password = msg["password"]!;
    String content = msg["content"]!;
    encryptLibs.IV iv = generateIV();
    encryptLibs.Key secret = generateSecret();
    encryptLibs.Key salt = encryptLibs.Key.fromSecureRandom(16);

    final encryptLibs.Key pwdKey = encryptLibs.Key(password2Hash(password, salt.bytes));
    final secretEncrypter = encryptLibs.Encrypter(encryptLibs.AES(pwdKey));
    final encryptLibs.Encrypted encryptedSecret = secretEncrypter.encrypt(secret.base64, iv: iv);

    final contentEncrypter = encryptLibs.Encrypter(encryptLibs.AES(secret));
    final encryptLibs.Encrypted encryptedContent = contentEncrypter.encrypt(content, iv: iv);

    return SeedData(
        encrypted: encryptedContent.base64,
        iv: iv.base64,
        salt: salt.base64,
        encryptedSecret: encryptedSecret.base64,
        version: 2
    ).toJson();
  }

  Future<String?> decrypt({required Map<String, dynamic> data,required String password}) async {
    String? encryptedStr = await compute(_decrypt, {"data": data, "password": password});
    return encryptedStr;
  }

  static String? _decrypt(msg) {
    Map<String, dynamic> data = msg["data"]!;
    String password = msg["password"]!;
    var seedData = SeedData.fromJson(data);
    encryptLibs.IV iv = encryptLibs.IV.fromBase64(seedData.iv);
    encryptLibs.Key salt = encryptLibs.Key.fromBase64(seedData.salt);
    encryptLibs.Key? pwdKey;
    try {
      if (seedData.version == 2) {
        pwdKey = encryptLibs.Key(password2Hash(password, salt.bytes));
      } else {
        pwdKey = encryptLibs.Key.fromUtf8(password).stretch(32, salt: salt.bytes);
      }
      final secretEncrypter = encryptLibs.Encrypter(encryptLibs.AES(pwdKey));
      final String secretBase64 = secretEncrypter.decrypt64(seedData.encryptedSecret, iv: iv);

      encryptLibs.Key secret = encryptLibs.Key.fromBase64(secretBase64);
      final contentEncrypter = encryptLibs.Encrypter(encryptLibs.AES(secret));
      final String decryptedContent = contentEncrypter.decrypt64(seedData.encrypted, iv: iv);
      return decryptedContent;
    } catch (e) {
      return null;
    }
  }

}