import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecureStorage {
  final storage = new FlutterSecureStorage();
  final seedKey = 'wallet_seed';
  final migrateKey = 'storage_migrated';

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

  Future<String?> getKV(String key) async {
    return storage.read(key: key);
  }

  Future<void> setKV(String key, String value) async {
    return storage.write(key: key, value: value);
  }

  Future<bool> isStorageMigrated() async {
    final isMigrated = await storage.read(key: migrateKey);
    if (isMigrated != null && isMigrated == '1') {
      return true;
    }
    return false;
  }

  Future<bool> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();
    try {
      for (var key in keys) {
        if (key != seedKey) {
          await storage.write(key: key, value: prefs.getString(key));
        }
      }
      await storage.write(key: migrateKey, value: '1');
      return true;
    } catch (ex) {
      for (var key in keys) {
        if (key != seedKey) {
          await storage.delete(key: key);
        }
      }
      return false;
    }
  }
}