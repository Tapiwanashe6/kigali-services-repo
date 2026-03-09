import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isSimulationEnabled = false;
  Timer? _simulationTimer;
  int _notificationId = 0;

  // Sample notification content for simulation
  final List<Map<String, String>> _sampleNotifications = [
    {
      'title': '📍 Nearby Service',
      'body': 'There is a Pharmacy just 500m away from you!',
    },
    {
      'title': '🍽️ Restaurant Alert',
      'body': 'You\'re near a highly rated Restaurant. Check it out!',
    },
    {
      'title': '🏥 Health Center',
      'body': 'A Hospital is located within 1km of your current location.',
    },
    {
      'title': '☕ Coffee Break?',
      'body': 'There\'s a Café nearby. Take a break and enjoy!',
    },
    {
      'title': '🛍️ Shopping Nearby',
      'body': 'You\'re near a popular shopping area in Kigali.',
    },
    {
      'title': '🏛️ Tourist Spot',
      'body': 'Don\'t miss this nearby Tourist Attraction!',
    },
    {
      'title': '📚 Library Nearby',
      'body': 'A Library is just around the corner from you.',
    },
    {
      'title': '🚓 Emergency Service',
      'body': 'Police station located nearby for your safety.',
    },
  ];

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    // This would typically use a navigation service or callback
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // Start simulating notifications
  Future<void> startSimulation() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Request permissions first
    await requestPermissions();

    _isSimulationEnabled = true;

    // Show initial notification immediately
    await _showRandomNotification();

    // Schedule notifications every 10 seconds for simulation
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        if (_isSimulationEnabled) {
          _showRandomNotification();
        }
      },
    );
  }

  // Stop simulating notifications
  void stopSimulation() {
    _isSimulationEnabled = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => _isSimulationEnabled;

  // Show a random notification from the sample list
  Future<void> _showRandomNotification() async {
    if (!_isSimulationEnabled) return;

    final random = DateTime.now().millisecondsSinceEpoch % _sampleNotifications.length;
    final notification = _sampleNotifications[random];

    const androidDetails = AndroidNotificationDetails(
      'kigali_services_channel',
      'Kigali Services Notifications',
      channelDescription: 'Notifications about nearby services in Kigali',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
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

    await _notificationsPlugin.show(
      _notificationId++,
      notification['title'],
      notification['body'],
      notificationDetails,
    );
  }

  // Show a specific notification (for testing,)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'kigali_services_channel',
      'Kigali Services Notifications',
      channelDescription: 'Notifications about nearby services in Kigali',
      importance: Importance.high,
      priority: Priority.high,
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

    await _notificationsPlugin.show(
      _notificationId++,
      title,
      body,
      notificationDetails,
    );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    _notificationId = 0;
  }

  // Dispose resources
  void dispose() {
    stopSimulation();
    _notificationsPlugin.cancelAll();
  }
}

