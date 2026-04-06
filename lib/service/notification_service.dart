import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static bool _coldStartChecked = false;
  static const String _lastLaunchPayloadKey = 'last_launch_notification_payload';
  static const String _notificationEnabledKey = 'notification_enabled';

  bool get isNotificationEnabled {
    try {
      final box = GetStorage('configuration');
      final value = box.read(_notificationEnabledKey);
      if (value == null) return true;
      return value == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final box = GetStorage('configuration');
    await box.write(_notificationEnabledKey, enabled);
  }
  
  void Function(Map<String, String> payload)? _onNotificationTap;
  final List<String> _pendingNotificationPayloads = [];

  set onNotificationTap(void Function(Map<String, String> payload)? callback) {
    _onNotificationTap = callback;
  }
  
  void Function(Map<String, String> payload)? get onNotificationTap => _onNotificationTap;

  Map<String, String> _parsePayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      }
    } catch (_) {}
    return {'hash': raw};
  }

  void consumePendingNotification() {
    if (_pendingNotificationPayloads.isNotEmpty && _onNotificationTap != null) {
      final payloads = List<String>.from(_pendingNotificationPayloads);
      _pendingNotificationPayloads.clear();
      final parsed = _parsePayload(payloads.last);
      _onNotificationTap!(parsed);
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (!_coldStartChecked) {
        _coldStartChecked = true;
        try {
          final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
          if (launchDetails != null &&
              launchDetails.didNotificationLaunchApp &&
              launchDetails.notificationResponse != null) {
            final payload = launchDetails.notificationResponse!.payload;
            if (payload != null && !_isLaunchNotificationAlreadyProcessed(payload)) {
              _markLaunchNotificationProcessed(payload);
              _onNotificationResponse(launchDetails.notificationResponse!);
            }
          }
        } catch (_) {}
      }

      _isInitialized = true;
    } catch (_) {}
  }

  bool _isLaunchNotificationAlreadyProcessed(String payload) {
    try {
      final box = GetStorage('configuration');
      return box.read(_lastLaunchPayloadKey) == payload;
    } catch (_) {
      return false;
    }
  }

  void _markLaunchNotificationProcessed(String payload) {
    try {
      final box = GetStorage('configuration');
      box.write(_lastLaunchPayloadKey, payload);
    } catch (_) {}
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      if (_onNotificationTap != null) {
        _onNotificationTap!(_parsePayload(response.payload!));
      } else {
        _pendingNotificationPayloads.add(response.payload!);
      }
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  Future<bool> isPermissionGranted() async {
    try {
      if (Platform.isIOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final settings = await iosPlugin.checkPermissions();
          return settings?.isEnabled ?? false;
        }
      } else if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          return await androidPlugin.areNotificationsEnabled() ?? false;
        }
      }
    } catch (_) {}
    return false;
  }

  static int notificationIdForHash(String txHash) {
    return txHash.hashCode & 0x7FFFFFFF;
  }

  Future<void> showTransactionNotification({
    required String txHash,
    String? txUrl,
    String? explorerUrl,
    String? senderAddress,
    bool isZeko = false,
    required String title,
    required String body,
  }) async {
    final payload = jsonEncode({
      'hash': txHash,
      if (txUrl != null && txUrl.isNotEmpty) 'txUrl': txUrl,
      if (explorerUrl != null && explorerUrl.isNotEmpty) 'explorerUrl': explorerUrl,
      if (senderAddress != null && senderAddress.isNotEmpty) 'senderAddress': senderAddress,
      if (isZeko) 'isZeko': 'true',
    });
    await _showNotification(
      id: notificationIdForHash(txHash),
      title: title,
      body: body,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isNotificationEnabled) return;
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'auro_wallet_channel',
      'Auro Wallet Notifications',
      channelDescription: 'Notifications for transaction updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification',
      color: Color(0xFF594AF1),
      colorized: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
