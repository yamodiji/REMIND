import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/notification_provider.dart';
import '../models/reminder.dart';
import '../widgets/reminder_card.dart';
import '../widgets/add_reminder_dialog.dart';
import '../widgets/permission_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  void _checkPermissions() async {
    try {
      if (!mounted) return;
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.checkPermissions();
      
      if (!mounted) return;
      if (!notificationProvider.allPermissionsGranted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const PermissionDialog(),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Permission check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reminders'),
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedIndex = index),
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete_completed') {
                  _deleteCompleted();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete_completed',
                  child: Text('Delete Completed'),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<ReminderProvider>(
          builder: (context, provider, child) {
            List<Reminder> reminders;
            switch (_selectedIndex) {
              case 0:
                reminders = provider.todayReminders;
                break;
              case 1:
                reminders = provider.upcomingReminders;
                break;
              case 2:
                reminders = provider.completedReminders;
                break;
              default:
                reminders = [];
            }

            if (reminders.isEmpty) {
              return const Center(
                child: Text('No reminders'),
              );
            }

            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ReminderCard(
                    reminder: reminders[index],
                    onTap: () => _editReminder(reminders[index]),
                    onDelete: () => _deleteReminder(reminders[index].id),
                    onStatusChanged: () => _toggleReminder(reminders[index].id),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddReminderDialog(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );
  }

  void _deleteReminder(String id) async {
    try {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deleteReminder(id);
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }

  void _toggleReminder(String id) async {
    try {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.toggleReminderStatus(id);
    } catch (e) {
      debugPrint('Toggle failed: $e');
    }
  }

  void _deleteCompleted() async {
    try {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deleteAllCompleted();
    } catch (e) {
      debugPrint('Delete completed failed: $e');
    }
  }
} 