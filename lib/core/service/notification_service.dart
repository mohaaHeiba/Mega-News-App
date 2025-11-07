import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service (for main app context)
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Create channel for news notifications
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'news_channel',
          'News Updates',
          description: 'Notifications for latest news articles',
          importance: Importance.high,
        ),
      );

      // Create channel for background service
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'news_background',
          'Background Service',
          description: 'Background service notification',
          importance: Importance.low,
        ),
      );

      // Request permissions for Android 13+ (only in main app context)
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (e) {
        // Permission request might fail in some contexts, that's okay
        print('Could not request notification permission: $e');
      }
    }

    _initialized = true;
  }

  /// Initialize the notification service for background use (no permission requests)
  Future<void> initializeForBackground() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin (without permission requests)
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Don't create channels or request permissions in background isolate
    // Channels should already be created in main app context

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to article detail here
    // For now, we'll just handle it silently
  }

  /// Show a notification with article information
  Future<void> showNewsNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'News Updates',
      channelDescription: 'Notifications for latest news articles',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Show multiple notifications for new articles
  Future<void> showMultipleNewsNotifications(
    List<Map<String, dynamic>> articles,
  ) async {
    if (!_initialized) {
      await initialize();
    }

    // Show up to 5 notifications (to avoid overwhelming the user)
    final articlesToNotify = articles.take(5).toList();

    for (int i = 0; i < articlesToNotify.length; i++) {
      final article = articlesToNotify[i];
      await showNewsNotification(
        id: i,
        title: article['title'] ?? 'Breaking News',
        body: article['description'] ?? 'New article available',
        payload: article['url'],
      );
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

