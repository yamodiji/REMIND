import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';

class ReminderCallScreen extends StatefulWidget {
  const ReminderCallScreen({super.key});

  @override
  State<ReminderCallScreen> createState() => _ReminderCallScreenState();
}

class _ReminderCallScreenState extends State<ReminderCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  Reminder? _currentReminder;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Make app fullscreen for call-like experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // TODO: Get reminder from arguments or notification payload
    _loadReminder();
  }

  void _loadReminder() {
    // In a real app, you'd get this from navigation arguments or notification payload
    final reminderProvider = context.read<ReminderProvider>();
    final reminders = reminderProvider.activeReminders;
    if (reminders.isNotEmpty) {
      setState(() {
        _currentReminder = reminders.first;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentReminder == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading reminder...',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade700,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildReminderContent()),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Text(
            'Reminder',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(DateTime.now()),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -1);
  }

  Widget _buildReminderContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar/Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: _currentReminder!.imagePath != null
                      ? ClipOval(
                          child: Image.asset(
                            _currentReminder!.imagePath!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          _currentReminder!.isImportant
                              ? Icons.priority_high
                              : Icons.notifications,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
              );
            },
          ).animate().scale(delay: 200.ms),
          
          const SizedBox(height: 40),
          
          // Reminder Title
          Text(
            _currentReminder!.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
          
          const SizedBox(height: 16),
          
          // Reminder Description
          if (_currentReminder!.description.isNotEmpty)
            Text(
              _currentReminder!.description,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 24),
          
          // Scheduled Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              _formatDateTime(_currentReminder!.dateTime),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 800.ms).scale(begin: 0.8),
          
          // Contact Info (if available)
          if (_currentReminder!.contactName != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentReminder!.contactName!,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Snooze Button
          _buildActionButton(
            icon: Icons.snooze,
            label: 'Snooze',
            color: Colors.orange,
            onTap: _showSnoozeOptions,
          ).animate().slideX(begin: -1, delay: 300.ms),
          
          // Dismiss Button
          _buildActionButton(
            icon: Icons.close,
            label: 'Dismiss',
            color: Colors.red,
            onTap: _dismissReminder,
          ).animate().scale(delay: 400.ms),
          
          // Mark Done Button
          _buildActionButton(
            icon: Icons.check,
            label: 'Done',
            color: Colors.green,
            onTap: _markAsDone,
          ).animate().slideX(begin: 1, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Snooze for',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ..._buildSnoozeOptions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSnoozeOptions() {
    final options = [
      ('5 minutes', const Duration(minutes: 5)),
      ('10 minutes', const Duration(minutes: 10)),
      ('30 minutes', const Duration(minutes: 30)),
      ('1 hour', const Duration(hours: 1)),
    ];

    return options
        .map((option) => ListTile(
              title: Text(option.$1),
              onTap: () => _snoozeReminder(option.$2),
            ))
        .toList();
  }

  void _snoozeReminder(Duration duration) {
    final reminderProvider = context.read<ReminderProvider>();
    reminderProvider.snoozeReminder(_currentReminder!.id, duration);
    Navigator.pop(context); // Close snooze options
    Navigator.pop(context); // Close call screen
  }

  void _dismissReminder() {
    Navigator.pop(context);
  }

  void _markAsDone() {
    final reminderProvider = context.read<ReminderProvider>();
    reminderProvider.markAsCompleted(_currentReminder!.id);
    Navigator.pop(context);
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }
} 