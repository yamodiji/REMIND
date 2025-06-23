import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
    
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to reminder call screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> scheduleReminder(Reminder reminder) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      _convertToTimeZone(reminder.dateTime),
      details,
      payload: reminder.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _getDateTimeComponents(reminder.repeatType),
    );
  }

  static Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  static Future<void> showInstantNotification(Reminder reminder) async {
    const AndroidNotificationDetails androidDetails = 
        AndroidNotificationDetails(
      'instant_reminder_channel',
      'Instant Reminders',
      channelDescription: 'Channel for instant reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
    );

    const DarwinNotificationDetails iosDetails = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      details,
      payload: reminder.id,
    );
  }

  static TZDateTime _convertToTimeZone(DateTime dateTime) {
    // For simplicity, using local timezone
    return TZDateTime.from(dateTime, local);
  }

  static DateTimeComponents? _getDateTimeComponents(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatType.yearly:
        return DateTimeComponents.dateAndTime;
      case RepeatType.none:
        return null;
    }
  }
}

// Import timezone for local notifications
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Initialize timezone
class TimeZoneHelper {
  static void initialize() {
    tz.initializeTimeZones();
  }
}

// Use TZDateTime alias
typedef TZDateTime = tz.TZDateTime;
final tz.Location local = tz.getLocation('UTC'); 