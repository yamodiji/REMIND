import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Enable Notifications',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To receive reminder notifications, please grant the following permissions:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              
              // Notification permission
              _buildPermissionItem(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                description: 'Show reminder alerts and notifications',
                isGranted: notificationProvider.isNotificationPermissionGranted,
              ),
              
              const SizedBox(height: 12),
              
              // Schedule exact alarms permission
              _buildPermissionItem(
                context,
                icon: Icons.schedule,
                title: 'Schedule Exact Alarms',
                description: 'Set precise reminder times',
                isGranted: notificationProvider.isScheduleExactAlarmsPermissionGranted,
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'These permissions are required for the app to work properly.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (notificationProvider.allPermissionsGranted)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => _requestPermissions(context, notificationProvider),
                child: const Text('Grant Permissions'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPermissionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isGranted 
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isGranted 
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted 
              ? Colors.green
              : Theme.of(context).colorScheme.error,
          size: 20,
        ),
      ],
    );
  }

  void _requestPermissions(BuildContext context, NotificationProvider provider) async {
    await provider.requestAllPermissions();
    
    if (provider.allPermissionsGranted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All permissions granted! You can now receive reminders.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showPermissionDeniedDialog(context, provider);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Some permissions were not granted. You can enable them later in the app settings to receive notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// Shows Android 15 compatible notification permission explanation dialog
Future<bool> showNotificationPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(
          Icons.notifications_active,
          size: 48,
          color: Colors.blue,
        ),
        title: const Text('Stay Updated with Reminders'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This app needs notification permission to alert you about your important reminders.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '• Get timely reminder alerts\n'
              '• Never miss important tasks\n'
              '• Control notification settings anytime',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow Notifications'),
          ),
        ],
      );
    },
  );
  
  if (result == true) {
    // Request the actual system permission
    return await NotificationService.requestPermissions();
  }
  
  return false;
}

/// Shows dialog when permission is permanently denied
Future<void> showPermissionDeniedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(
          Icons.settings,
          size: 48,
          color: Colors.orange,
        ),
        title: const Text('Permission Required'),
        content: const Text(
          'Notifications are disabled for this app. To enable reminders, please:\n\n'
          '1. Tap "Open Settings"\n'
          '2. Go to "Notifications"\n'
          '3. Enable "Allow notifications"\n\n'
          'This ensures you never miss important reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    },
  );
}

/// Shows exact alarm permission dialog (Android 15 requirement)
Future<bool> showExactAlarmPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(
          Icons.schedule,
          size: 48,
          color: Colors.green,
        ),
        title: const Text('Precise Timing Required'),
        content: const Text(
          'To deliver reminders at the exact time you set, this app needs permission to schedule exact alarms.\n\n'
          'This ensures your reminders are delivered precisely when needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow Exact Timing'),
          ),
        ],
      );
    },
  );
  
  if (result == true) {
    await NotificationService.requestExactAlarmPermission();
    return true;
  }
  
  return false;
}

/// Request all necessary permissions with proper Android 15 flow
Future<bool> requestAllPermissions(BuildContext context) async {
  try {
    // Check if notification permission is already granted
    final notificationStatus = await Permission.notification.status;
    
    if (notificationStatus.isGranted) {
      return true;
    }
    
    // Show explanation dialog first (Android 15 best practice)
    final shouldRequestNotification = await showNotificationPermissionDialog(context);
    
    if (!shouldRequestNotification) {
      return false;
    }
    
    // Request exact alarm permission for Android 15
    await showExactAlarmPermissionDialog(context);
    
    // Check final status
    final finalStatus = await Permission.notification.status;
    
    if (finalStatus.isPermanentlyDenied) {
      await showPermissionDeniedDialog(context);
      return false;
    }
    
    return finalStatus.isGranted;
    
  } catch (e) {
    debugPrint('Permission request error: $e');
    return false;
  }
}

/// Check and show permission status to user
Future<void> checkPermissionStatus(BuildContext context) async {
  final notificationStatus = await Permission.notification.status;
  final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
  
  String message = '';
  IconData icon = Icons.check_circle;
  Color color = Colors.green;
  
  if (notificationStatus.isGranted && exactAlarmStatus.isGranted) {
    message = 'All permissions granted! Reminders will work perfectly.';
  } else if (notificationStatus.isGranted) {
    message = 'Notifications enabled. For best experience, allow exact timing.';
    icon = Icons.warning;
    color = Colors.orange;
  } else {
    message = 'Notifications disabled. Enable them to receive reminders.';
    icon = Icons.error;
    color = Colors.red;
  }
  
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color.withOpacity(0.1),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Widget that wraps permission requests in proper UI context
class PermissionRequestWrapper extends StatefulWidget {
  final Widget child;
  final bool requestOnInit;
  
  const PermissionRequestWrapper({
    super.key,
    required this.child,
    this.requestOnInit = true,
  });

  @override
  State<PermissionRequestWrapper> createState() => _PermissionRequestWrapperState();
}

class _PermissionRequestWrapperState extends State<PermissionRequestWrapper> {
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    if (widget.requestOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestPermissionsIfNeeded();
      });
    }
  }

  Future<void> _requestPermissionsIfNeeded() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;
    
    // Wait a bit for the UI to settle
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      await PermissionDialog.requestAllPermissions(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 