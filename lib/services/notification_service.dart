import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import '../models/reminder.dart';

// Use TZDateTime alias
typedef TZDateTime = tz.TZDateTime;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) return;
    
    try {
      // Initialize timezone data first with error handling
      try {
        tz.initializeTimeZones();
      } catch (e) {
        debugPrint('Timezone initialization failed: $e');
        // Continue without timezone - notifications will still work
      }
      
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: false, // We'll request manually
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize notifications plugin with timeout
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Notification initialization timed out');
          throw TimeoutException('Notification initialization timeout', const Duration(seconds: 10));
        },
      );

      // Create notification channels for Android 15
      await _createNotificationChannels();
      
      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
      
    } catch (e) {
      debugPrint('NotificationService initialization failed: $e');
      // Mark as initialized to prevent retry loops
      _isInitialized = true;
      // Don't throw - let app continue without notifications
    }
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Channel for reminder notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
      'instant_reminder_channel',
      'Instant Reminders',
      description: 'Channel for instant reminder notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
        
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instantChannel);
  }

  /// Android 15 compatible permission request with proper dialogs
  static Future<bool> requestPermissions() async {
    try {
      // Check current status
      final status = await Permission.notification.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        // Show custom explanation dialog first
        final shouldRequest = await _showPermissionExplanationDialog();
        if (!shouldRequest) return false;
        
        // Request permission
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        await _showOpenSettingsDialog();
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  static Future<bool> _showPermissionExplanationDialog() async {
    // This would be called from a widget context
    // For now, just return true to proceed with request
    return true;
  }

  static Future<void> _showOpenSettingsDialog() async {
    // This would show a dialog to open app settings
    // Implementation would be in the UI layer
    await openAppSettings();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to reminder call screen
    // This would be handled by the app's navigation system
  }

  static Future<bool> scheduleReminder(Reminder reminder) async {
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      // Check permissions first
      final hasPermission = await Permission.notification.isGranted;
      if (!hasPermission) {
        debugPrint('No notification permission');
        return false;
      }

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
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: false,
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

      final scheduledDate = _convertToTimeZone(reminder.dateTime);
      
      await _notifications.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        reminder.description,
        scheduledDate,
        details,
        payload: reminder.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: _getDateTimeComponents(reminder.repeatType),
      );
      
      debugPrint('Reminder scheduled successfully: ${reminder.title}');
      return true;
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
      return false;
    }
  }

  static Future<void> cancelReminder(String reminderId) async {
    try {
      await _notifications.cancel(reminderId.hashCode);
      debugPrint('Reminder cancelled: $reminderId');
    } catch (e) {
      debugPrint('Failed to cancel reminder: $e');
    }
  }

  static Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All reminders cancelled');
    } catch (e) {
      debugPrint('Failed to cancel all reminders: $e');
    }
  }

  static Future<bool> showInstantNotification(Reminder reminder) async {
    if (!_isInitialized) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      // Check permissions first
      final hasPermission = await Permission.notification.isGranted;
      if (!hasPermission) {
        debugPrint('No notification permission for instant notification');
        return false;
      }

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
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: true,
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
      
      debugPrint('Instant notification shown: ${reminder.title}');
      return true;
    } catch (e) {
      debugPrint('Failed to show instant notification: $e');
      return false;
    }
  }

  static TZDateTime _convertToTimeZone(DateTime dateTime) {
    final location = tz.local;
    return TZDateTime.from(dateTime, location);
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

  static Future<bool> checkPermissionStatus() async {
    return await Permission.notification.isGranted;
  }

  static Future<void> requestExactAlarmPermission() async {
    try {
      await Permission.scheduleExactAlarm.request();
    } catch (e) {
      debugPrint('Failed to request exact alarm permission: $e');
    }
  }
}

 