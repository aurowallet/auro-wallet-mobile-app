import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenAwakeKeys {
  static const String ledgerGetAddress = 'ledger_get_address';
  static const String webviewBridgeTestPage = 'webview_bridge_test_page';

  static String scoped(String prefix, Object owner) {
    return '${prefix}_${identityHashCode(owner)}';
  }
}

class ScreenAwake {
  static final Set<String> _holders = <String>{};

  static Future<void> _toggle(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled).timeout(const Duration(seconds: 5));
    } catch (error) {
      debugPrint('ScreenAwake update failed: $error');
    }
  }

  static Future<void> acquire(String key) async {
    _holders.add(key);
    await _toggle(true);
  }

  static Future<void> release(String key) async {
    _holders.remove(key);
    if (_holders.isEmpty) {
      await _toggle(false);
    }
  }
}

class ScreenAwakeHandle {
  ScreenAwakeHandle(this.key);

  final String key;
  bool _active = false;

  Future<void> activate() async {
    if (_active) {
      return;
    }
    _active = true;
    await ScreenAwake.acquire(key);
  }

  Future<void> deactivate() async {
    if (!_active) {
      return;
    }
    _active = false;
    await ScreenAwake.release(key);
  }

  Future<void> setActive(bool active) async {
    if (active) {
      await activate();
    } else {
      await deactivate();
    }
  }
}
