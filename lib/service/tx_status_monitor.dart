import 'dart:async';
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

  PendingTxInfo({
    required this.hash,
    this.paymentId,
    this.amount,
    this.tokenSymbol,
    required this.txType,
    required this.gqlUrl,
    required this.createdAt,
    this.timer,
  });
}

// Callback type for transaction confirmed
typedef TxConfirmedCallback = void Function(String gqlUrl);

class TxStatusMonitor {
  static final TxStatusMonitor _instance = TxStatusMonitor._internal();
  factory TxStatusMonitor() => _instance;
  TxStatusMonitor._internal();

  final Map<String, PendingTxInfo> _pendingTxs = {};
  final Map<String, bool> _nodeSupportsTransactionStatus = {};
  
  // Callback for notifying when transaction is confirmed
  TxConfirmedCallback? onTxConfirmed;
  
  // Debounce: track pending refresh requests per gqlUrl
  final Set<String> _pendingRefreshUrls = {};
  Timer? _refreshDebounceTimer;

  static const int _pollIntervalSeconds = 5;

  static const String TX_STATUS_PENDING = 'PENDING';
  static const String TX_STATUS_INCLUDED = 'INCLUDED';
  static const String TX_STATUS_UNKNOWN = 'UNKNOWN';

  void addPendingTx({
    required String hash,
    String? paymentId,
    String? amount,
    String? tokenSymbol,
    required MonitorTxType txType,
    required String gqlUrl,
  }) async {
    if (hash.isEmpty || paymentId == null || paymentId.isEmpty) {
      return;
    }

    if (_pendingTxs.containsKey(hash)) {
      return;
    }

    final isSupported = await _checkNodeSupportsTransactionStatus(gqlUrl);
    
    if (!isSupported) {
      // Show "transaction sent" notification immediately for unsupported nodes
      final txInfo = PendingTxInfo(
        hash: hash,
        paymentId: paymentId,
        amount: amount,
        tokenSymbol: tokenSymbol,
        txType: txType,
        gqlUrl: gqlUrl,
        createdAt: DateTime.now(),
      );
      _showSentNotification(txInfo);
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
    );
    
    _pendingTxs[hash] = txInfo;
    _startPollingForTx(txInfo);
  }

  /// Check if the node supports transactionStatus query by making a test query
  /// If field doesn't exist: graphqlErrors + no data
  /// If field exists: has data (even if status is UNKNOWN)
  Future<bool> _checkNodeSupportsTransactionStatus(String gqlUrl) async {
    if (_nodeSupportsTransactionStatus.containsKey(gqlUrl)) {
      return _nodeSupportsTransactionStatus[gqlUrl]!;
    }

    // Try a test query with dummy ID to check if field exists
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
      
      // Check GraphQL errors - if error is about invalid input (not missing field), field IS supported
      if (result.hasException && result.exception?.graphqlErrors.isNotEmpty == true) {
        final errors = result.exception!.graphqlErrors;
        for (final error in errors) {
          final message = error.message.toLowerCase();
          // "Invalid transaction" or "Malformed input" means the field exists but input is bad
          // This is different from "Cannot query field" which means field doesn't exist
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
      _nodeSupportsTransactionStatus[gqlUrl] = false;
      return false;
    }
  }

  void _startPollingForTx(PendingTxInfo txInfo) {
    _checkTxStatus(txInfo);
  }

  Future<void> _checkTxStatus(PendingTxInfo txInfo) async {
    try {
      final status = txInfo.txType == MonitorTxType.zkApp
          ? await _fetchZkTxStatus(txInfo.paymentId!, txInfo.gqlUrl)
          : await _fetchTxStatus(txInfo.paymentId!, txInfo.gqlUrl);

      if (status == TX_STATUS_INCLUDED) {
        _onTxConfirmed(txInfo);
        _removeTx(txInfo.hash);
      } else if (status == TX_STATUS_UNKNOWN || status == null) {
        _removeTx(txInfo.hash);
      } else {
        txInfo.timer = Timer(
          Duration(seconds: _pollIntervalSeconds),
          () => _checkTxStatus(txInfo),
        );
      }
    } catch (e) {
      _removeTx(txInfo.hash);
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
  }

  void _onTxConfirmed(PendingTxInfo txInfo) {
    _showNotification(txInfo);
    _scheduleRefreshCallback(txInfo.gqlUrl);
  }
  
  /// Schedule a refresh callback with debounce
  /// Multiple transactions from same network will only trigger one refresh
  void _scheduleRefreshCallback(String gqlUrl) {
    _pendingRefreshUrls.add(gqlUrl);
    
    // Cancel existing timer and start new one (debounce)
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      for (final url in _pendingRefreshUrls) {
        onTxConfirmed?.call(url);
      }
      _pendingRefreshUrls.clear();
    });
  }

  /// Get localization strings based on current app locale
  /// This ensures notifications use current language even after language switch
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
      // Only show amount for payment type transactions
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
    } catch (e) {
      // Ignore notification errors
    }
  }

  void _showSentNotification(PendingTxInfo txInfo) {
    try {
      final dic = _getCurrentLocalization();
      
      String body;
      // Only show amount for payment type transactions
      if (txInfo.txType == MonitorTxType.payment && txInfo.amount != null && txInfo.tokenSymbol != null) {
        body = dic.notificationTxSuccessBodyWithAmount(
          txInfo.amount!,
          txInfo.tokenSymbol!,
        );
      } else {
        body = dic.notificationTxSuccessBody;
      }

      NotificationService().showTransactionNotification(
        isSuccess: true,
        txHash: txInfo.hash,
        successTitle: dic.notificationTxSuccess,
        failedTitle: dic.notificationTxFailed,
        successBody: body,
        failedBody: dic.notificationTxFailedBody,
      );
    } catch (e) {
      // Ignore notification errors
    }
  }

  void dispose() {
    for (var txInfo in _pendingTxs.values) {
      txInfo.timer?.cancel();
    }
    _pendingTxs.clear();
  }
}
