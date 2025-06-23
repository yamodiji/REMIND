import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(reminder.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onStatusChanged?.call(),
            backgroundColor: reminder.isCompleted ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: reminder.isCompleted ? Icons.undo : Icons.check,
            label: reminder.isCompleted ? 'Undo' : 'Done',
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Reminder content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        reminder.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: reminder.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: reminder.isCompleted
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (reminder.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            decoration: reminder.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Date and time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          
                          if (reminder.isRepeating) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                          
                          if (reminder.isImportant) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.priority_high,
                              size: 16,
                              color: Colors.red,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Quick action button
                IconButton(
                  onPressed: onStatusChanged,
                  icon: Icon(
                    reminder.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: reminder.isCompleted 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (reminder.isCompleted) {
      return Colors.green;
    } else if (reminder.isOverdue) {
      return Colors.red;
    } else if (reminder.isToday) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final reminderDate = reminder.dateTime;
    
    // Check if it's today
    if (DateFormat.yMd().format(now) == DateFormat.yMd().format(reminderDate)) {
      return 'Today ${DateFormat.jm().format(reminderDate)}';
    }
    
    // Check if it's tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (DateFormat.yMd().format(tomorrow) == DateFormat.yMd().format(reminderDate)) {
      return 'Tomorrow ${DateFormat.jm().format(reminderDate)}';
    }
    
    // Check if it's yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (DateFormat.yMd().format(yesterday) == DateFormat.yMd().format(reminderDate)) {
      return 'Yesterday ${DateFormat.jm().format(reminderDate)}';
    }
    
    // Check if it's this week
    final difference = reminderDate.difference(now).inDays;
    if (difference.abs() <= 7) {
      return '${DateFormat.E().format(reminderDate)} ${DateFormat.jm().format(reminderDate)}';
    }
    
    // Default format
    return DateFormat.yMd().add_jm().format(reminderDate);
  }
} 