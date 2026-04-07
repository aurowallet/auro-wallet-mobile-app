import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:auro_wallet/service/notification_service.dart';
import 'package:auro_wallet/store/app.dart';
import 'package:auro_wallet/store/assets/types/transferData.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:auro_wallet/walletSdk/minaSDK.dart' show decodeMemo;

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
  final String? receiverAddress;
  final String? explorerUrl;
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
    this.receiverAddress,
    this.explorerUrl,
    this.retryCount = 0,
  });
}

typedef TxConfirmedCallback = void Function(String gqlUrl);

bool isValidMinaTxHash(String hash) {
  try {
    if (hash.isEmpty) return false;
    if (!hash.startsWith('5J')) return false;
    bs58check.decode(hash);
    return true;
  } catch (e) {
    return false;
  }
}

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
  final Map<String, GraphQLClient> _archiveClients = {};
  static const int _maxCachedClients = 5;

  GraphQLClient _getOrCreateClient(Map<String, GraphQLClient> cache, String url) {
    final existing = cache[url];
    if (existing != null) {
      // Move to end for LRU eviction
      cache.remove(url);
      cache[url] = existing;
      return existing;
    }
    if (cache.length >= _maxCachedClients) {
      cache.remove(cache.keys.first);
    }
    final client = GraphQLClient(link: HttpLink(url), cache: GraphQLCache());
    cache[url] = client;
    return client;
  }
  
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
    String? receiverAddress,
    String? explorerUrl,
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
          receiverAddress: receiverAddress,
          explorerUrl: explorerUrl,
        );
        if (txUrl != null && txUrl.isNotEmpty && senderAddress != null && senderAddress.isNotEmpty) {
          _pendingTxs[hash] = txInfo;
          _pollZekoArchiveForTx(txInfo, txUrl, senderAddress);
        }
        return;
      }

      final isSupported = await _checkNodeSupportsTransactionStatus(gqlUrl);
      
      if (!isSupported) {
        if (_nodeSupportsTransactionStatus[gqlUrl] == false) {
          return;
        }
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
        txUrl: txUrl,
        senderAddress: senderAddress,
        receiverAddress: receiverAddress,
        explorerUrl: explorerUrl,
      );
      
      _pendingTxs[hash] = txInfo;
      _startPollingForTx(txInfo);
    } catch (_) {
    }
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

      final result = await client.query(options).timeout(const Duration(seconds: 10));
      
      if (result.data != null && result.data!.containsKey('transactionStatus')) {
        _nodeSupportsTransactionStatus[gqlUrl] = true;
        return true;
      }
      
      if (result.hasException && result.exception?.graphqlErrors.isNotEmpty == true) {
        final errors = result.exception!.graphqlErrors;
        for (final error in errors) {
          final message = error.message.toLowerCase();
          if (message.contains('cannot query field') || message.contains('unknown field')) {
            _nodeSupportsTransactionStatus[gqlUrl] = false;
            return false;
          }
        }
        _nodeSupportsTransactionStatus[gqlUrl] = true;
        return true;
      }

      if (result.hasException) {
        return false;
      }
      _nodeSupportsTransactionStatus[gqlUrl] = false;
      return false;
    } catch (_) {
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
      } else if (status == TX_STATUS_UNKNOWN && retryCount >= _maxPollRetries ~/ 2) {
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

    final result = await client.query(options).timeout(const Duration(seconds: 10));
    
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

    final result = await client.query(options).timeout(const Duration(seconds: 10));
    
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

  void _onTxConfirmed(PendingTxInfo txInfo, {bool isNonceMatch = false}) {
    _showNotification(txInfo, isSuccess: true, isNonceMatch: isNonceMatch);
    _scheduleRefreshCallback(txInfo.gqlUrl);
  }


  static const Duration _fetchTimeout = Duration(seconds: 15);

  Future<TransferData?> fetchTransactionByHash(String hash, String archiveUrl) async {
    if (!isValidMinaTxHash(hash)) return null;

    const String query = r'''
      query transactionByHash($hash: String!) {
        transactionByHash(hash: $hash) {
          kind
          timestamp
          nonce
          body {
            amount
            dateTime
            failureReason
            fee
            from
            hash
            kind
            memo
            nonce
            to
          }
          zkAppBody {
            dateTime
            failureReasons {
              failures
              index
            }
            hash
            zkappCommand {
              accountUpdates {
                body {
                  publicKey
                  tokenId
                  balanceChange {
                    magnitude
                    sgn
                  }
                }
              }
              feePayer {
                body {
                  fee
                  nonce
                  publicKey
                }
              }
              memo
            }
          }
        }
      }
    ''';

    final client = _getOrCreateClient(_archiveClients, archiveUrl);
    final options = QueryOptions(
      document: gql(query),
      variables: {'hash': hash},
      fetchPolicy: FetchPolicy.noCache,
    );

    try {
      final result = await client.query(options).timeout(_fetchTimeout);
      if (result.hasException || result.data == null) return null;

      final txData = result.data!['transactionByHash'];
      if (txData == null) return null;

      final String kind = txData['kind'] ?? '';
      final body = txData['body'];
      final zkAppBody = txData['zkAppBody'];

      final safeTxData = txData is Map<String, dynamic> ? txData : Map<String, dynamic>.from(txData);
      if (kind == 'zkApp' && zkAppBody != null) {
        final parsed = _parseZkAppTransaction(Map<String, dynamic>.from(zkAppBody), safeTxData);
        if (parsed != null) return parsed;
        return null;
      } else if (body != null) {
        return _parseCommonTransaction(Map<String, dynamic>.from(body), safeTxData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _toStringAmount(dynamic value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(0);
    return value.toString();
  }

  TransferData _parseCommonTransaction(Map<String, dynamic> body, Map<String, dynamic> txData) {
    String kind = body['kind'] ?? txData['kind'] ?? 'payment';
    String type;
    switch (kind.toUpperCase()) {
      case 'STAKE_DELEGATION':
        type = 'delegation';
        break;
      case 'PAYMENT':
        type = 'payment';
        break;
      default:
        type = kind;
    }
    final amount = body['amount'];
    final fee = body['fee'];
    final failureReason = body['failureReason'];
    return TransferData()
      ..hash = body['hash'] ?? ''
      ..type = type
      ..fee = fee != null ? _toStringAmount(fee) : null
      ..amount = amount != null ? _toStringAmount(amount) : '0'
      ..nonce = _parseNonce(body['nonce']) ?? _parseNonce(txData['nonce'])
      ..sender = body['from']
      ..receiver = body['to']
      ..memo = decodeMemo(body['memo'])
      ..time = body['dateTime']
      ..status = failureReason == null ? 'applied' : 'failed'
      ..success = failureReason == null
      ..failureReason = failureReason != null ? failureReason.toString() : '';
  }

  TransferData? _parseZkAppTransaction(Map<String, dynamic> zkAppBody, Map<String, dynamic> txData) {
    final zkappCommand = zkAppBody['zkappCommand'];
    if (zkappCommand == null) return null;
    final feePayerBody = zkappCommand['feePayer']?['body'];
    final accountUpdates = zkappCommand['accountUpdates'] as List<dynamic>?;
    final firstUpdate = (accountUpdates != null && accountUpdates.isNotEmpty)
        ? accountUpdates.first as Map<String, dynamic>
        : null;
    final receiver = firstUpdate?['body']?['publicKey'];
    final fee = feePayerBody?['fee'];

    final failureReasons = zkAppBody['failureReasons'] as List<dynamic>?;
    final bool isFailed = failureReasons != null && failureReasons.isNotEmpty;
    final failureStr = isFailed ? failureReasons.toString() : '';

    return TransferData()
      ..hash = zkAppBody['hash'] ?? ''
      ..type = 'zkApp'
      ..fee = fee != null ? _toStringAmount(fee) : null
      ..amount = '0'
      ..nonce = _parseNonce(feePayerBody?['nonce']) ?? _parseNonce(txData['nonce'])
      ..sender = feePayerBody?['publicKey']
      ..receiver = receiver
      ..memo = decodeMemo(zkappCommand['memo'])
      ..time = zkAppBody['dateTime']
      ..status = isFailed ? 'failed' : 'applied'
      ..success = !isFailed
      ..failureReason = failureStr
      ..transaction = jsonEncode(zkappCommand);
  }

  Future<TransferData?> fetchZekoTransactionByHash(String hash, String archiveUrl, String senderAddress) async {
    if (!isValidMinaTxHash(hash)) return null;
    if (senderAddress.isEmpty) return null;

    const String query = r'''
      query checkTx($publicKey: String, $limit: Int) {
        fullTransactions(limit: $limit, query: { publicKey: $publicKey }) {
          body {
            amount
            dateTime
            failureReason
            fee
            from
            hash
            kind
            memo
            nonce
            to
          }
          zkAppBody {
            dateTime
            failureReasons {
              failures
              index
            }
            hash
            zkappCommand {
              accountUpdates {
                body {
                  publicKey
                  tokenId
                  balanceChange {
                    magnitude
                    sgn
                  }
                }
              }
              feePayer {
                body {
                  fee
                  nonce
                  publicKey
                }
              }
              memo
            }
          }
        }
      }
    ''';

    try {
      final client = _getOrCreateClient(_zekoArchiveClients, archiveUrl);
      final options = QueryOptions(
        document: gql(query),
        variables: {'publicKey': senderAddress, 'limit': 20},
        fetchPolicy: FetchPolicy.noCache,
      );
      final result = await client.query(options).timeout(_fetchTimeout);
      if (result.hasException || result.data == null) return null;

      final List<dynamic> txList = result.data!['fullTransactions'] ?? [];
      for (final tx in txList) {
        final bodyHash = tx['body']?['hash'];
        final zkAppHash = tx['zkAppBody']?['hash'];

        if (bodyHash == hash && tx['body'] != null) {
          return _parseCommonTransaction(
            Map<String, dynamic>.from(tx['body']),
            tx is Map<String, dynamic> ? tx : Map<String, dynamic>.from(tx),
          );
        }
        if (zkAppHash == hash && tx['zkAppBody'] != null) {
          return _parseZkAppTransaction(
            Map<String, dynamic>.from(tx['zkAppBody']),
            tx is Map<String, dynamic> ? tx : Map<String, dynamic>.from(tx),
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? getArchiveUrl() {
    return globalAppStore.settings?.currentNode?.txUrl;
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
          final matchType = await _checkTxExistsInArchive(txInfo.hash, txUrl, senderAddress, txInfo.nonce);
          if (!_pendingTxs.containsKey(txInfo.hash) || _isPaused) return;
          if (matchType != null) {
            _onTxConfirmed(txInfo, isNonceMatch: matchType == 'nonce');
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

  Future<String?> _checkTxExistsInArchive(String hash, String txUrl, String senderAddress, int? pendingNonce) async {
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
      final client = _getOrCreateClient(_zekoArchiveClients, txUrl);
      final options = QueryOptions(
        document: gql(query),
        variables: {'publicKey': senderAddress, 'limit': 10},
        fetchPolicy: FetchPolicy.noCache,
      );
      final result = await client.query(options).timeout(const Duration(seconds: 10));
      if (result.hasException || result.data == null) {
        return null;
      }
      final List<dynamic> txList = result.data!['fullTransactions'] ?? [];
      for (final tx in txList) {
        final bodyHash = tx['body']?['hash'];
        final zkAppHash = tx['zkAppBody']?['hash'];

        if (bodyHash == hash || zkAppHash == hash) {
          return 'hash';
        }

        if (pendingNonce != null) {
          if (tx['body'] != null && tx['body']['from'] == senderAddress) {
            final confirmedNonce = _parseNonce(tx['body']['nonce']);
            if (confirmedNonce != null && confirmedNonce >= pendingNonce) {
              return 'nonce';
            }
          }
          final feePayer = tx['zkAppBody']?['zkappCommand']?['feePayer']?['body'];
          if (feePayer != null && feePayer['publicKey'] == senderAddress) {
            final confirmedNonce = _parseNonce(feePayer['nonce']);
            if (confirmedNonce != null && confirmedNonce >= pendingNonce) {
              return 'nonce';
            }
          }
        }
      }
      return null;
    } catch (e) {
      return null;
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
    String localeCode = globalAppStore.settings?.localeCode ?? '';
    if (localeCode.isEmpty) {
      localeCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    }
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

  String _shortAddress(String? addr) {
    if (addr == null || addr.length < 10) return addr ?? '';
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  void _showNotification(PendingTxInfo txInfo, {required bool isSuccess, bool isNonceMatch = false}) {
    try {
      final dic = _getCurrentLocalization();
      
      String title;
      String body;

      if (isSuccess) {
        // Nonce-based match means a different tx with higher nonce was confirmed,
        // so the original tx was likely replaced. Use generic notification.
        if (isNonceMatch) {
          title = dic.notificationTxSuccess;
          body = dic.notificationTxSuccessBody;
        } else {
          switch (txInfo.txType) {
            case MonitorTxType.payment:
              final amount = txInfo.amount ?? '0';
              final symbol = txInfo.tokenSymbol ?? 'MINA';
              title = dic.notificationSentTitle(amount, symbol);
              body = txInfo.receiverAddress != null ? dic.notificationSentBody(_shortAddress(txInfo.receiverAddress)) : dic.notificationTxSuccessBody;
              break;
            case MonitorTxType.delegation:
              title = dic.notificationDelegationSuccessTitle;
              body = txInfo.receiverAddress != null ? dic.notificationDelegationSuccessBody(_shortAddress(txInfo.receiverAddress)) : dic.notificationTxSuccessBody;
              break;
            case MonitorTxType.zkApp:
              title = dic.notificationZkAppSuccessTitle;
              body = dic.notificationZkAppSuccessBody;
              break;
          }
        }
      } else {
        switch (txInfo.txType) {
          case MonitorTxType.payment:
            final amount = txInfo.amount ?? '0';
            final symbol = txInfo.tokenSymbol ?? 'MINA';
            title = dic.notificationSendFailedTitle;
            body = dic.notificationSendFailedBody(amount, symbol);
            break;
          case MonitorTxType.delegation:
            title = dic.notificationDelegationFailedTitle;
            body = dic.notificationDelegationFailedBody;
            break;
          case MonitorTxType.zkApp:
            title = dic.notificationZkAppFailedTitle;
            body = dic.notificationZkAppFailedBody;
            break;
        }
      }

      NotificationService().showTransactionNotification(
        txHash: txInfo.hash,
        txUrl: txInfo.txUrl,
        explorerUrl: txInfo.explorerUrl,
        senderAddress: txInfo.senderAddress,
        isZeko: txInfo.isZeko,
        title: title,
        body: body,
      );
    } catch (_) {
    }
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
    _archiveClients.clear();
    _nodeSupportsTransactionStatus.clear();
  }
}
