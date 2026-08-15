import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/plant.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = 
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> scheduleWateringReminder(Plant plant) async {
    // Get the next watering date from the plant's care schedule
    final wateringFrequency = plant.careSchedule['wateringFrequency'] ?? 7;
    final nextWatering = DateTime.now().add(Duration(days: wateringFrequency));
    
    await _localNotifications.zonedSchedule(
      plant.id.hashCode, // Unique ID based on plant ID
      'Water ${plant.name}',
      'Time to water your ${plant.name}!',
      tz.TZDateTime.from(nextWatering, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plant_care_channel',
          'Plant Care Reminders',
          channelDescription: 'Reminders for plant care tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> scheduleFertilizingReminder(Plant plant) async {
    final fertilizingEnabled = plant.careSchedule['fertilizingEnabled'] ?? false;
    if (!fertilizingEnabled) return;
    
    final fertilizingFrequency = plant.careSchedule['fertilizingFrequency'] ?? 30;
    final nextFertilizing = DateTime.now().add(Duration(days: fertilizingFrequency));
    
    await _localNotifications.zonedSchedule(
      plant.id.hashCode + 1000, // Unique ID
      'Fertilize ${plant.name}',
      'Time to fertilize your ${plant.name}!',
      tz.TZDateTime.from(nextFertilizing, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plant_care_channel',
          'Plant Care Reminders',
          channelDescription: 'Reminders for plant care tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelPlantReminders(String plantId) async {
    await _localNotifications.cancel(plantId.hashCode);
    await _localNotifications.cancel(plantId.hashCode + 1000); // fertilizing reminder
  }

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  void get onBackgroundMessage =>
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
}

// Background message handler
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}