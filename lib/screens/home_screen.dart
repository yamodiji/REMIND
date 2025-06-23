import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkPermissions();
  }

  void _checkPermissions() async {
    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.checkPermissions();
    
    if (!notificationProvider.allPermissionsGranted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showPermissionDialog();
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(reminderProvider),
              _buildStatsCards(reminderProvider),
              _buildTabSection(),
              _buildRemindersList(reminderProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildSliverAppBar(ReminderProvider reminderProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Reminders',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete_completed':
                _deleteCompletedReminders(reminderProvider);
                break;
              case 'settings':
                _openSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete_completed',
              child: ListTile(
                leading: Icon(Icons.delete_sweep),
                title: Text('Delete Completed'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(ReminderProvider reminderProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active',
                reminderProvider.activeCount.toString(),
                Icons.schedule,
                Colors.blue,
              ).animate().slideX(delay: 100.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                reminderProvider.completedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ).animate().slideX(delay: 200.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Overdue',
                reminderProvider.overdueCount.toString(),
                Icons.warning,
                Colors.red,
              ).animate().slideX(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _selectedIndex = index),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(ReminderProvider reminderProvider) {
    List<Reminder> reminders;
    
    switch (_selectedIndex) {
      case 0:
        reminders = reminderProvider.todayReminders;
        break;
      case 1:
        reminders = reminderProvider.upcomingReminders;
        break;
      case 2:
        reminders = reminderProvider.completedReminders;
        break;
      default:
        reminders = [];
    }

    if (reminders.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No reminders found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reminder = reminders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ReminderCard(
              reminder: reminder,
              onTap: () => _showReminderDetails(reminder),
              onStatusChanged: () => reminderProvider.toggleReminderStatus(reminder.id),
              onDelete: () => reminderProvider.deleteReminder(reminder.id),
            ).animate().slideX(delay: (index * 100).ms),
          );
        },
        childCount: reminders.length,
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddReminderDialog(),
    );
  }

  void _showReminderDetails(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );
  }

  void _deleteCompletedReminders(ReminderProvider reminderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Reminders'),
        content: const Text('Are you sure you want to delete all completed reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              reminderProvider.deleteAllCompleted();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    final notificationProvider = context.read<NotificationProvider>();
    notificationProvider.openSettings();
  }
} 