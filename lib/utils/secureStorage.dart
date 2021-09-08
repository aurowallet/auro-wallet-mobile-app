import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  final storage = new FlutterSecureStorage();
  final seedKey = 'wallet_seed';
  Future<void> clearSeeds() async {
    return storage.deleteAll();
  }
  Future<void> setSeeds(String seedType, Map value) async {
    return storage.write(key: '${seedKey}_$seedType', value: jsonEncode(value));
  }

  Future<Map> getSeeds(String seedType) async {
    String? value = await storage.read(key: '${seedKey}_$seedType');
    if (value != null) {
      return jsonDecode(value);
    }
    return {};
  }
}