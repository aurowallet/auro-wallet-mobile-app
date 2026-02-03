import 'dart:io';
import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  
  // Callback for handling notification taps
  void Function(String? txHash)? _onNotificationTap;
  
  // Store pending notification hash when callback is not yet set
  String? _pendingNotificationHash;
  
  // Setter for callback - also processes any pending notification
  set onNotificationTap(void Function(String? txHash)? callback) {
    _onNotificationTap = callback;
    if (callback != null && _pendingNotificationHash != null) {
      callback(_pendingNotificationHash);
      _pendingNotificationHash = null;
    }
  }
  
  void Function(String? txHash)? get onNotificationTap => _onNotificationTap;

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

      _isInitialized = true;
    } catch (e) {
      // Ignore initialization errors
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      if (_onNotificationTap != null) {
        _onNotificationTap!(response.payload);
      } else {
        _pendingNotificationHash = response.payload;
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

  Future<void> showTransactionNotification({
    required bool isSuccess,
    required String txHash,
    required String successTitle,
    required String failedTitle,
    required String successBody,
    required String failedBody,
  }) async {
    await _showNotification(
      id: txHash.hashCode,
      title: isSuccess ? successTitle : failedTitle,
      body: isSuccess ? successBody : failedBody,
      payload: txHash,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
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
