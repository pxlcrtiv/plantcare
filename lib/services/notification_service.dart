import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/plant.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // no-op: FCM delivers data-only messages here; local scheduling handles the rest
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  Function(String payload)? onNotificationTap;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap?.call(details.payload ?? '');
      },
    );

    await _createNotificationChannel();

    final token = await _firebaseMessaging.getToken();
    await _storeFcmToken(token);

    _firebaseMessaging.onTokenRefresh.listen(_storeFcmToken);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final plantId = message.data['plantId'] as String?;
      if (plantId != null) {
        onNotificationTap?.call(plantId);
      }
    });

    await _firebaseMessaging
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _createNotificationChannel() async {
    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'plant_care_channel',
          'Plant Care Reminders',
          description: 'Reminders for plant care tasks',
          importance: Importance.high,
        ),
      );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'plant_care_channel',
      'Plant Care Reminders',
      channelDescription: 'Reminders for plant care tasks',
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['plantId'] as String?,
    );
  }

  Future<void> _storeFcmToken(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> scheduleWateringReminder(Plant plant) async {
    final wateringFrequency = plant.careSchedule['wateringFrequency'] ?? 7;
    final nextWatering = DateTime.now().add(Duration(days: wateringFrequency));

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.zonedSchedule(
      plant.id.hashCode,
      'Water ${plant.name}',
      _wateringReminderBody(plant),
      tz.TZDateTime.from(nextWatering, tz.local),
      const AndroidNotificationDetails(
        'plant_care_channel',
        'Plant Care Reminders',
        channelDescription: 'Reminders for plant care tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> scheduleFertilizingReminder(Plant plant) async {
    final fertilizingEnabled =
        plant.careSchedule['fertilizingEnabled'] ?? false;
    if (!fertilizingEnabled) return;

    final fertilizingFrequency =
        plant.careSchedule['fertilizingFrequency'] ?? 30;
    final nextFertilizing =
        DateTime.now().add(Duration(days: fertilizingFrequency));

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.zonedSchedule(
      plant.id.hashCode + 1000,
      'Fertilize ${plant.name}',
      'Time to fertilize your ${plant.name}!',
      tz.TZDateTime.from(nextFertilizing, tz.local),
      const AndroidNotificationDetails(
        'plant_care_channel',
        'Plant Care Reminders',
        channelDescription: 'Reminders for plant care tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelPlantReminders(String plantId) async {
    await _localNotifications.cancel(plantId.hashCode);
    await _localNotifications.cancel(plantId.hashCode + 1000);
  }

  String _wateringReminderBody(Plant plant) {
    final reminderText = plant.careSchedule['reminderText'];
    if (reminderText is String && reminderText.trim().isNotEmpty) {
      return reminderText;
    }
    return 'Time to water your ${plant.name}!';
  }
}
