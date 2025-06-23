import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isNotificationPermissionGranted = false;
  bool _isScheduleExactAlarmsPermissionGranted = false;
  bool _isInitialized = false;

  bool get isNotificationPermissionGranted => _isNotificationPermissionGranted;
  bool get isScheduleExactAlarmsPermissionGranted => _isScheduleExactAlarmsPermissionGranted;
  bool get isInitialized => _isInitialized;

  bool get allPermissionsGranted => 
      _isNotificationPermissionGranted && _isScheduleExactAlarmsPermissionGranted;

  Future<void> checkPermissions() async {
    try {
      _isNotificationPermissionGranted = await Permission.notification.isGranted;
      
      // Check for schedule exact alarms permission (Android 12+)
      _isScheduleExactAlarmsPermissionGranted = 
          await Permission.scheduleExactAlarm.isGranted;
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      _isNotificationPermissionGranted = status.isGranted;
      notifyListeners();
      return _isNotificationPermissionGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<bool> requestScheduleExactAlarmsPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.request();
      _isScheduleExactAlarmsPermissionGranted = status.isGranted;
      notifyListeners();
      return _isScheduleExactAlarmsPermissionGranted;
    } catch (e) {
      debugPrint('Error requesting schedule exact alarms permission: $e');
      return false;
    }
  }

  Future<void> requestAllPermissions() async {
    await requestNotificationPermission();
    await requestScheduleExactAlarmsPermission();
  }

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }
} 