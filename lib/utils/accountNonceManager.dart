import 'dart:async';

import 'package:auro_wallet/service/api/api.dart';
import 'package:auro_wallet/store/app.dart';

class AccountNonceManager {
  AccountNonceManager({
    required this.store,
    required this.publicKey,
    this.refreshInterval = const Duration(seconds: 30),
    this.onChanged,
  })  : _nonce = cachedMainAccountNonce(store),
        _hasNonce = true;

  final AppStore store;
  final String publicKey;
  final Duration refreshInterval;
  final void Function()? onChanged;

  Timer? _timer;
  bool _refreshing = false;
  int _nonce;
  bool _hasNonce;

  int get nonce => _hasNonce ? _nonce : cachedMainAccountNonce(store);

  static int cachedMainAccountNonce(AppStore store) {
    return int.tryParse(
            store.assets!.mainTokenNetInfo.tokenAssestInfo?.inferredNonce ??
                '0') ??
        0;
  }

  void resetFromCachedNonce() {
    _nonce = cachedMainAccountNonce(store);
    _hasNonce = true;
    onChanged?.call();
  }

  void start() {
    refresh();
    _timer?.cancel();
    _timer = Timer.periodic(refreshInterval, (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final int freshNonce = await webApi.assets.fetchAccountNonceWithRetry(
        publicKey,
      );
      if (freshNonce < 0) return;
      _nonce = freshNonce;
      _hasNonce = true;
      onChanged?.call();
    } catch (e) {
      print('refresh nonce failed: $e');
    } finally {
      _refreshing = false;
    }
  }

  Future<void> fetchPendingTokenListOnce() async {
    try {
      await webApi.assets.fetchPendingTokenList(publicKey, nonce.toString());
    } catch (e) {
      print('fetch pending token list failed: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
