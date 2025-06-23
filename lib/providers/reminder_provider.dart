import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final Box<Reminder> _reminderBox = Hive.box<Reminder>('reminders');
  
  List<Reminder> get allReminders => _reminderBox.values.toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

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

  Future<void> addReminder(Reminder reminder) async {
    try {
      await _reminderBox.put(reminder.id, reminder);
      await NotificationService.scheduleReminder(reminder);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _reminderBox.put(reminder.id, reminder);
      
      // Cancel existing notification and reschedule
      await NotificationService.cancelReminder(reminder.id);
      if (!reminder.isCompleted) {
        await NotificationService.scheduleReminder(reminder);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _reminderBox.delete(id);
      await NotificationService.cancelReminder(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      rethrow;
    }
  }

  Future<void> toggleReminderStatus(String id) async {
    try {
      final reminder = _reminderBox.get(id);
      if (reminder != null) {
        reminder.isCompleted = !reminder.isCompleted;
        await updateReminder(reminder);
      }
    } catch (e) {
      debugPrint('Error toggling reminder status: $e');
      rethrow;
    }
  }

  Future<void> markAsCompleted(String id) async {
    try {
      final reminder = _reminderBox.get(id);
      if (reminder != null) {
        reminder.isCompleted = true;
        await updateReminder(reminder);
      }
    } catch (e) {
      debugPrint('Error marking reminder as completed: $e');
      rethrow;
    }
  }

  Future<void> snoozeReminder(String id, Duration duration) async {
    try {
      final reminder = _reminderBox.get(id);
      if (reminder != null) {
        reminder.dateTime = DateTime.now().add(duration);
        await updateReminder(reminder);
      }
    } catch (e) {
      debugPrint('Error snoozing reminder: $e');
      rethrow;
    }
  }

  Reminder? getReminderById(String id) {
    return _reminderBox.get(id);
  }

  Future<void> deleteAllCompleted() async {
    try {
      final completedIds = completedReminders.map((r) => r.id).toList();
      for (final id in completedIds) {
        await deleteReminder(id);
      }
    } catch (e) {
      debugPrint('Error deleting completed reminders: $e');
      rethrow;
    }
  }

  Future<void> clearAllReminders() async {
    try {
      await _reminderBox.clear();
      await NotificationService.cancelAllReminders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all reminders: $e');
      rethrow;
    }
  }

  int get totalReminders => allReminders.length;
  int get activeCount => activeReminders.length;
  int get completedCount => completedReminders.length;
  int get overdueCount => overdueReminders.length;
} 