import 'package:auro_wallet/service/api/apiSetting.dart';
import 'package:auro_wallet/store/settings/types/minaExchangesConfig.dart';
import 'package:auro_wallet/utils/localStorage.dart';
import 'package:flutter/foundation.dart';

export 'package:auro_wallet/store/settings/types/minaExchangesConfig.dart';

/// Restore the last valid config while independently refreshing it from the API.
class MinaExchanges extends ValueNotifier<MinaExchangesConfig?> {
  MinaExchanges(this.storage, {
    Future<MinaExchangesConfig?> Function()? fetchConfig,
  })
    : fetchConfig = fetchConfig ?? ApiSetting.fetchMinaExchanges,
      super(null);

  static const cacheKey = 'mina_exchanges_v1';
  final LocalStorage storage;
  final Future<MinaExchangesConfig?> Function() fetchConfig;
  bool _disposed = false;
  bool _refreshed = false;
  Future<void>? _initialization;

  /// Load once per app session, including when the first refresh fails.
  Future<void> initialize() {
    return _initialization ??= Future.wait([
      _loadCache(),
      _refresh(),
    ]).then((_) {});
  }

  Future<void> _loadCache() async {
    try {
      final cache = await storage.getObject(cacheKey);
      if (!_disposed && !_refreshed && cache is Map) {
        value = MinaExchangesConfig.parse(cache['config']);
      }
    } catch (_) {
      // A damaged cache must not prevent the remote refresh.
    }
  }

  Future<void> _refresh() async {
    try {
      final config = await fetchConfig();
      if (_disposed || config == null) return;
      _refreshed = true;
      value = config;
      await storage.setObject(cacheKey, {'config': config});
    } catch (_) {
      // Keep the last valid configuration on network or parsing failures.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
