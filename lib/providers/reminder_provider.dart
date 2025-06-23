import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  Box<Reminder>? _reminderBox;
  final List<Reminder> _fallbackReminders = <Reminder>[];
  bool _useHive = false;
  
  ReminderProvider() {
    _initializeBox();
  }
  
  /// Initialize Hive box with error handling
  void _initializeBox() {
    try {
      if (Hive.isBoxOpen('reminders')) {
        _reminderBox = Hive.box<Reminder>('reminders');
        _useHive = true;
        debugPrint('✅ ReminderProvider: Using Hive storage');
      } else {
        debugPrint('⚠️ ReminderProvider: Hive box not available, using fallback');
        _useHive = false;
      }
    } catch (e) {
      debugPrint('❌ ReminderProvider: Failed to initialize Hive box: $e');
      _useHive = false;
    }
  }
  
  /// Get all reminders from storage (Hive or fallback)
  List<Reminder> get allReminders {
    if (_useHive && _reminderBox != null) {
      try {
        return _reminderBox!.values.toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      } catch (e) {
        debugPrint('❌ Error reading from Hive: $e');
        // Fall back to in-memory storage
        _useHive = false;
        return _fallbackReminders..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }
    } else {
      return _fallbackReminders..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }

  List<Reminder> get activeReminders => allReminders
      .where((reminder) => !reminder.isCompleted)
      .toList();

  List<Reminder> get completedReminders => allReminders
      .where((reminder) => reminder.isCompleted)
      .toList();

  List<Reminder> get todayReminders => activeReminders
      .where((reminder) => reminder.isToday)
      .toList();

  List<Reminder> get upcomingReminders => activeReminders
      .where((reminder) => reminder.isUpcoming && !reminder.isToday)
      .toList();

  List<Reminder> get overdueReminders => activeReminders
      .where((reminder) => reminder.isOverdue)
      .toList();

  /// Add reminder with comprehensive error handling
  Future<void> addReminder(Reminder reminder) async {
    try {
      // Try to save to Hive first
      if (_useHive && _reminderBox != null) {
        await _reminderBox!.put(reminder.id, reminder);
      } else {
        // Fallback to in-memory storage
        _fallbackReminders.removeWhere((r) => r.id == reminder.id);
        _fallbackReminders.add(reminder);
      }
      
      // Schedule notification with error handling
      try {
        await NotificationService.scheduleReminder(reminder);
      } catch (e) {
        debugPrint('⚠️ Failed to schedule notification: $e');
        // Continue - reminder is still saved, just no notification
      }
      
      notifyListeners();
      debugPrint('✅ Reminder added successfully: ${reminder.title}');
    } catch (e) {
      debugPrint('❌ Error adding reminder: $e');
      rethrow;
    }
  }

  /// Update reminder with error handling
  Future<void> updateReminder(Reminder reminder) async {
    try {
      // Save to storage
      if (_useHive && _reminderBox != null) {
        await _reminderBox!.put(reminder.id, reminder);
      } else {
        final index = _fallbackReminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _fallbackReminders[index] = reminder;
        } else {
          _fallbackReminders.add(reminder);
        }
      }
      
      // Update notifications with error handling
      try {
        // Cancel existing notification
        await NotificationService.cancelReminder(reminder.id);
        
        // Reschedule if not completed
        if (!reminder.isCompleted) {
          await NotificationService.scheduleReminder(reminder);
        }
      } catch (e) {
        debugPrint('⚠️ Failed to update notification: $e');
        // Continue - reminder is still updated
      }
      
      notifyListeners();
      debugPrint('✅ Reminder updated successfully: ${reminder.title}');
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
      rethrow;
    }
  }

  /// Delete reminder with error handling
  Future<void> deleteReminder(String id) async {
    try {
      // Remove from storage
      if (_useHive && _reminderBox != null) {
        await _reminderBox!.delete(id);
      } else {
        _fallbackReminders.removeWhere((r) => r.id == id);
      }
      
      // Cancel notification with error handling
      try {
        await NotificationService.cancelReminder(id);
      } catch (e) {
        debugPrint('⚠️ Failed to cancel notification: $e');
        // Continue - reminder is still deleted
      }
      
      notifyListeners();
      debugPrint('✅ Reminder deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      rethrow;
    }
  }

  /// Toggle reminder status with error handling
  Future<void> toggleReminderStatus(String id) async {
    try {
      final reminder = getReminderById(id);
      if (reminder != null) {
        reminder.isCompleted = !reminder.isCompleted;
        await updateReminder(reminder);
      } else {
        debugPrint('⚠️ Reminder not found for toggle: $id');
      }
    } catch (e) {
      debugPrint('❌ Error toggling reminder status: $e');
      rethrow;
    }
  }

  /// Mark reminder as completed with error handling
  Future<void> markAsCompleted(String id) async {
    try {
      final reminder = getReminderById(id);
      if (reminder != null) {
        reminder.isCompleted = true;
        await updateReminder(reminder);
      } else {
        debugPrint('⚠️ Reminder not found for completion: $id');
      }
    } catch (e) {
      debugPrint('❌ Error marking reminder as completed: $e');
      rethrow;
    }
  }

  /// Snooze reminder with error handling
  Future<void> snoozeReminder(String id, Duration duration) async {
    try {
      final reminder = getReminderById(id);
      if (reminder != null) {
        reminder.dateTime = DateTime.now().add(duration);
        await updateReminder(reminder);
      } else {
        debugPrint('⚠️ Reminder not found for snooze: $id');
      }
    } catch (e) {
      debugPrint('❌ Error snoozing reminder: $e');
      rethrow;
    }
  }

  /// Get reminder by ID with null safety
  Reminder? getReminderById(String id) {
    try {
      if (_useHive && _reminderBox != null) {
        return _reminderBox!.get(id);
      } else {
        return _fallbackReminders.firstWhere(
          (r) => r.id == id,
          orElse: () => throw StateError('Not found'),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Reminder not found: $id');
      return null;
    }
  }

  /// Delete all completed reminders with error handling
  Future<void> deleteAllCompleted() async {
    try {
      final completedIds = completedReminders.map((r) => r.id).toList();
      
      for (final id in completedIds) {
        try {
          await deleteReminder(id);
        } catch (e) {
          debugPrint('⚠️ Failed to delete completed reminder $id: $e');
          // Continue with other reminders
        }
      }
      
      debugPrint('✅ Deleted ${completedIds.length} completed reminders');
    } catch (e) {
      debugPrint('❌ Error deleting completed reminders: $e');
      rethrow;
    }
  }

  /// Clear all reminders with error handling
  Future<void> clearAllReminders() async {
    try {
      // Clear storage
      if (_useHive && _reminderBox != null) {
        await _reminderBox!.clear();
      } else {
        _fallbackReminders.clear();
      }
      
      // Cancel all notifications with error handling
      try {
        await NotificationService.cancelAllReminders();
      } catch (e) {
        debugPrint('⚠️ Failed to cancel all notifications: $e');
        // Continue - reminders are still cleared
      }
      
      notifyListeners();
      debugPrint('✅ All reminders cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing all reminders: $e');
      rethrow;
    }
  }

  // Statistics getters with null safety
  int get totalReminders => allReminders.length;
  int get activeCount => activeReminders.length;
  int get completedCount => completedReminders.length;
  int get overdueCount => overdueReminders.length;
  
  /// Check if storage is available
  bool get isStorageAvailable => _useHive && _reminderBox != null;
  
  /// Get storage type for debugging
  String get storageType => _useHive ? 'Hive' : 'Memory';
  
  @override
  void dispose() {
    // No need to close Hive box here - it's managed globally
    super.dispose();
  }
} 