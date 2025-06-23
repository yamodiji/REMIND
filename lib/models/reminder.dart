import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  bool isRepeating;

  @HiveField(6)
  RepeatType repeatType;

  @HiveField(7)
  int reminderSound;

  @HiveField(8)
  String? imagePath;

  @HiveField(9)
  bool isImportant;

  @HiveField(10)
  String? contactName;

  @HiveField(11)
  String? contactPhone;

  @HiveField(12)
  DateTime createdAt;

  Reminder({
    String? id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.isRepeating = false,
    this.repeatType = RepeatType.none,
    this.reminderSound = 0,
    this.imagePath,
    this.isImportant = false,
    this.contactName,
    this.contactPhone,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dateTime);
  
  bool get isToday => DateTime.now().difference(dateTime).inDays == 0;
  
  bool get isUpcoming => DateTime.now().isBefore(dateTime);

  @override
  String toString() {
    return 'Reminder{id: $id, title: $title, dateTime: $dateTime}';
  }
}

@HiveType(typeId: 1)
enum RepeatType {
  @HiveField(0)
  none,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
  
  @HiveField(4)
  yearly,
}

extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.none:
        return 'None';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
    }
  }
} 