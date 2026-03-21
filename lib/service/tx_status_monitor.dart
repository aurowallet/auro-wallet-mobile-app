import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:auro_wallet/service/notification_service.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/l10n/app_localizations.dart';
import 'package:auro_wallet/l10n/app_localizations_en.dart';
import 'package:auro_wallet/l10n/app_localizations_zh.dart';
import 'package:auro_wallet/l10n/app_localizations_ru.dart';
import 'package:auro_wallet/l10n/app_localizations_tr.dart';
import 'package:auro_wallet/l10n/app_localizations_uk.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auro_wallet/service/graphql.dart';

enum MonitorTxType { payment, delegation, zkApp }

class PendingTxInfo {
  final String hash;
  final String? paymentId;
  final String? amount;
  final String? tokenSymbol;
  final MonitorTxType txType;
  final String gqlUrl;
  final DateTime createdAt;
  Timer? timer;

  final int? nonce;

  final bool isZeko;
  final String? txUrl;
  final String? senderAddress;
  int retryCount;

  PendingTxInfo({
    required this.hash,
    this.paymentId,
    this.amount,
    this.tokenSymbol,
    required this.txType,
    required this.gqlUrl,
    required this.createdAt,
    this.timer,
    this.nonce,
    this.isZeko = false,
    this.txUrl,
    this.senderAddress,
    this.retryCount = 0,
  });
}

typedef TxConfirmedCallback = void Function(String gqlUrl);

class TxStatusMonitor with WidgetsBindingObserver {
  static final TxStatusMonitor _instance = TxStatusMonitor._internal();
  factory TxStatusMonitor() => _instance;
  TxStatusMonitor._internal();

  bool _lifecycleRegistered = false;
  bool _isPaused = false;

  void ensureLifecycleObserving() {
    if (!_lifecycleRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _lifecycleRegistered = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseAllPolling();
    } else if (state == AppLifecycleState.resumed) {
      _resumeAllPolling();
    }
  }

  void _pauseAllPolling() {
    if (_isPaused) return;
    _isPaused = true;
    for (final txInfo in _pendingTxs.values) {
      txInfo.timer?.cancel();
      txInfo.timer = null;
    }
  }

  void _resumeAllPolling() {
    if (!_isPaused) return;
    _isPaused = false;
    for (final txInfo in List.of(_pendingTxs.values)) {
      if (txInfo.isZeko) {
        if (txInfo.txUrl != null && txInfo.senderAddress != null) {
          _pollZekoArchiveForTx(txInfo, txInfo.txUrl!, txInfo.senderAddress!, txInfo.retryCount);
        }
      } else {
        _checkTxStatus(txInfo, txInfo.retryCount);
      }
    }
  }

  final Map<String, PendingTxInfo> _pendingTxs = {};
  final Map<String, bool> _nodeSupportsTransactionStatus = {};
  final Map<String, GraphQLClient> _zekoArchiveClients = {};
  
  final List<TxConfirmedCallback> _onTxConfirmedListeners = [];

  void addOnTxConfirmedListener(TxConfirmedCallback listener) {
    if (!_onTxConfirmedListeners.contains(listener)) {
      _onTxConfirmedListeners.add(listener);
    }
  }

  void removeOnTxConfirmedListener(TxConfirmedCallback listener) {
    _onTxConfirmedListeners.remove(listener);
  }

  void _notifyTxConfirmedListeners(String gqlUrl) {
    for (final listener in List.of(_onTxConfirmedListeners)) {
      listener(gqlUrl);
    }
  }
  
  final Set<String> _pendingRefreshUrls = {};
  Timer? _refreshDebounceTimer;

  static const int _pollIntervalSeconds = 5;
  static const int _maxPollRetries = 720;

  static const String TX_STATUS_INCLUDED = 'INCLUDED';
  static const String TX_STATUS_UNKNOWN = 'UNKNOWN';

  static const int _zekoArchivePollIntervalSeconds = 10;
  static const int _zekoArchiveMaxRetries = 180;

  Future<void> addPendingTx({
    required String hash,
    String? paymentId,
    String? amount,
    String? tokenSymbol,
    required MonitorTxType txType,
    required String gqlUrl,
    int? nonce,
    bool isZekoNet = false,
    String? txUrl,
    String? senderAddress,
  }) async {
    try {
      if (hash.isEmpty || paymentId == null || paymentId.isEmpty) {
        return;
      }

      if (_pendingTxs.containsKey(hash)) {
        return;
      }

      if (isZekoNet) {
        final txInfo = PendingTxInfo(
          hash: hash,
          paymentId: paymentId,
          amount: amount,
          tokenSymbol: tokenSymbol,
          txType: txType,
          gqlUrl: gqlUrl,
          createdAt: DateTime.now(),
          nonce: nonce,
          isZeko: true,
          txUrl: txUrl,
          senderAddress: senderAddress,
        );
        if (txUrl != null && txUrl.isNotEmpty && senderAddress != null && senderAddress.isNotEmpty) {
          _pendingTxs[hash] = txInfo;
          _pollZekoArchiveForTx(txInfo, txUrl, senderAddress);
        }
        return;
      }

      final isSupported = await _checkNodeSupportsTransactionStatus(gqlUrl);
      
      if (!isSupported) {
        return;
      }
      
      final txInfo = PendingTxInfo(
        hash: hash,
        paymentId: paymentId,
        amount: amount,
        tokenSymbol: tokenSymbol,
        txType: txType,
        gqlUrl: gqlUrl,
        createdAt: DateTime.now(),
        nonce: nonce,
      );
      
      _pendingTxs[hash] = txInfo;
      _startPollingForTx(txInfo);
    } catch (e) {}
  }

  Future<bool> _checkNodeSupportsTransactionStatus(String gqlUrl) async {
    if (_nodeSupportsTransactionStatus.containsKey(gqlUrl)) {
      return _nodeSupportsTransactionStatus[gqlUrl]!;
    }

    const String testQuery = r'''
      query transactionStatus($paymentId: ID!) {
        transactionStatus(payment: $paymentId)
      }
    ''';

    try {
      final client = clientFor(uri: gqlUrl, subscriptionUri: null).value;
      final options = QueryOptions(
        document: gql(testQuery),
        variables: {'paymentId': 'test_check_support'},
        fetchPolicy: FetchPolicy.noCache,
      );

      final result = await client.query(options);
      
      if (result.data != null && result.data!.containsKey('transactionStatus')) {
        _nodeSupportsTransactionStatus[gqlUrl] = true;
        return true;
      }
      
      if (result.hasException && result.exception?.graphqlErrors.isNotEmpty == true) {
        final errors = result.exception!.graphqlErrors;
        for (final error in errors) {
          final message = error.message.toLowerCase();
          if (message.contains('invalid') || message.contains('malformed')) {
            _nodeSupportsTransactionStatus[gqlUrl] = true;
            return true;
          }
          if (message.contains('cannot query field') || message.contains('unknown field')) {
            _nodeSupportsTransactionStatus[gqlUrl] = false;
            return false;
          }
        }
        _nodeSupportsTransactionStatus[gqlUrl] = false;
        return false;
      }
      
      _nodeSupportsTransactionStatus[gqlUrl] = false;
      return false;
    } catch (e) {
      return false;
    }
  }

  void _startPollingForTx(PendingTxInfo txInfo) {
    _checkTxStatus(txInfo);
  }

  Future<void> _checkTxStatus(PendingTxInfo txInfo, [int retryCount = 0]) async {
    if (_isPaused) return;
    txInfo.retryCount = retryCount;
    if (retryCount >= _maxPollRetries) {
      _removeTx(txInfo.hash);
      return;
    }
    try {
      final status = txInfo.txType == MonitorTxType.zkApp
          ? await _fetchZkTxStatus(txInfo.paymentId!, txInfo.gqlUrl)
          : await _fetchTxStatus(txInfo.paymentId!, txInfo.gqlUrl);

      if (!_pendingTxs.containsKey(txInfo.hash) || _isPaused) return;

      if (status == TX_STATUS_INCLUDED) {
        _onTxConfirmed(txInfo);
        _removeTx(txInfo.hash);
      } else if (status == TX_STATUS_UNKNOWN || status == null) {
        _removeTx(txInfo.hash);
      } else {
        txInfo.timer = Timer(
          Duration(seconds: _pollIntervalSeconds),
          () => _checkTxStatus(txInfo, retryCount + 1),
        );
      }
    } catch (e) {
      if (!_pendingTxs.containsKey(txInfo.hash) || _isPaused) return;
      txInfo.timer = Timer(
        Duration(seconds: _pollIntervalSeconds),
        () => _checkTxStatus(txInfo, retryCount + 1),
      );
    }
  }

  Future<String?> _fetchTxStatus(String paymentId, String gqlUrl) async {
    const String query = r'''
      query transactionStatus($paymentId: ID!) {
        transactionStatus(payment: $paymentId)
      }
    ''';

    final client = clientFor(uri: gqlUrl, subscriptionUri: null).value;
    final options = QueryOptions(
      document: gql(query),
      variables: {'paymentId': paymentId},
      fetchPolicy: FetchPolicy.noCache,
    );

    final result = await client.query(options);
    
    if (result.hasException) {
      return null;
    }

    return result.data?['transactionStatus'] as String?;
  }

  Future<String?> _fetchZkTxStatus(String zkappTransaction, String gqlUrl) async {
    const String query = r'''
      query transactionStatus($zkappTransaction: ID!) {
        transactionStatus(zkappTransaction: $zkappTransaction)
      }
    ''';

    final client = clientFor(uri: gqlUrl, subscriptionUri: null).value;
    final options = QueryOptions(
      document: gql(query),
      variables: {'zkappTransaction': zkappTransaction},
      fetchPolicy: FetchPolicy.noCache,
    );

    final result = await client.query(options);
    
    if (result.hasException) {
      return null;
    }

    return result.data?['transactionStatus'] as String?;
  }

  void _removeTx(String hash) {
    final txInfo = _pendingTxs.remove(hash);
    txInfo?.timer?.cancel();
    if (_pendingTxs.isEmpty) {
      _nodeSupportsTransactionStatus.clear();
    }
  }

  void _onTxConfirmed(PendingTxInfo txInfo) {
    _showNotification(txInfo);
    _scheduleRefreshCallback(txInfo.gqlUrl);
  }
  
  void _pollZekoArchiveForTx(PendingTxInfo txInfo, String txUrl, String senderAddress, [int retryCount = 0]) {
    if (_isPaused) return;
    txInfo.retryCount = retryCount;
    if (retryCount >= _zekoArchiveMaxRetries) {
      _removeTx(txInfo.hash);
      return;
    }
    txInfo.timer = Timer(
      Duration(seconds: _zekoArchivePollIntervalSeconds),
      () async {
        if (_isPaused) return;
        try {
          final found = await _checkTxExistsInArchive(txInfo.hash, txUrl, senderAddress, txInfo.nonce);
          if (!_pendingTxs.containsKey(txInfo.hash) || _isPaused) return;
          if (found) {
            _onTxConfirmed(txInfo);
            _removeTx(txInfo.hash);
          } else {
            _pollZekoArchiveForTx(txInfo, txUrl, senderAddress, retryCount + 1);
          }
        } catch (e) {
          if (!_pendingTxs.containsKey(txInfo.hash) || _isPaused) return;
          _pollZekoArchiveForTx(txInfo, txUrl, senderAddress, retryCount + 1);
        }
      },
    );
  }

  Future<bool> _checkTxExistsInArchive(String hash, String txUrl, String senderAddress, int? pendingNonce) async {
    const String query = r'''
      query checkTx($publicKey: String, $limit: Int) {
        fullTransactions(limit: $limit, query: { publicKey: $publicKey }) {
          body { hash nonce from }
          zkAppBody {
            hash
            zkappCommand { feePayer { body { nonce publicKey } } }
          }
        }
      }
    ''';

    try {
      final client = _zekoArchiveClients.putIfAbsent(
        txUrl,
        () => GraphQLClient(link: HttpLink(txUrl), cache: GraphQLCache()),
      );
      final options = QueryOptions(
        document: gql(query),
        variables: {'publicKey': senderAddress, 'limit': 10},
        fetchPolicy: FetchPolicy.noCache,
      );
      final result = await client.query(options);
      if (result.hasException || result.data == null) {
        return false;
      }
      final List<dynamic> txList = result.data!['fullTransactions'] ?? [];
      for (final tx in txList) {
        final bodyHash = tx['body']?['hash'];
        final zkAppHash = tx['zkAppBody']?['hash'];

        if (bodyHash == hash || zkAppHash == hash) {
          return true;
        }

        if (pendingNonce != null) {
          if (tx['body'] != null && tx['body']['from'] == senderAddress) {
            final confirmedNonce = _parseNonce(tx['body']['nonce']);
            if (confirmedNonce != null && confirmedNonce >= pendingNonce) {
              return true;
            }
          }
          final feePayer = tx['zkAppBody']?['zkappCommand']?['feePayer']?['body'];
          if (feePayer != null && feePayer['publicKey'] == senderAddress) {
            final confirmedNonce = _parseNonce(feePayer['nonce']);
            if (confirmedNonce != null && confirmedNonce >= pendingNonce) {
              return true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  int? _parseNonce(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _scheduleRefreshCallback(String gqlUrl) {
    _pendingRefreshUrls.add(gqlUrl);
    
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      for (final url in _pendingRefreshUrls) {
        _notifyTxConfirmedListeners(url);
      }
      _pendingRefreshUrls.clear();
    });
  }

  AppLocalizations _getCurrentLocalization() {
    final localeCode = globalAppStore.settings?.localeCode ?? 'en';
    switch (localeCode.toLowerCase()) {
      case 'zh':
        return AppLocalizationsZh();
      case 'ru':
        return AppLocalizationsRu();
      case 'tr':
        return AppLocalizationsTr();
      case 'uk':
        return AppLocalizationsUk();
      default:
        return AppLocalizationsEn();
    }
  }

  void _showNotification(PendingTxInfo txInfo) {
    try {
      final dic = _getCurrentLocalization();
      
      String successBody;
      if (txInfo.txType == MonitorTxType.payment && txInfo.amount != null && txInfo.tokenSymbol != null) {
        successBody = dic.notificationTxSuccessBodyWithAmount(
          txInfo.amount!,
          txInfo.tokenSymbol!,
        );
      } else {
        successBody = dic.notificationTxSuccessBody;
      }

      NotificationService().showTransactionNotification(
        isSuccess: true,
        txHash: txInfo.hash,
        successTitle: dic.notificationTxSuccess,
        failedTitle: dic.notificationTxFailed,
        successBody: successBody,
        failedBody: dic.notificationTxFailedBody,
      );
    } catch (e) {}
  }

  void dispose() {
    if (_lifecycleRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleRegistered = false;
    }
    _isPaused = false;
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = null;
    for (var txInfo in _pendingTxs.values) {
      txInfo.timer?.cancel();
    }
    _pendingTxs.clear();
    _pendingRefreshUrls.clear();
    _onTxConfirmedListeners.clear();
    _zekoArchiveClients.clear();
    _nodeSupportsTransactionStatus.clear();
  }
}
