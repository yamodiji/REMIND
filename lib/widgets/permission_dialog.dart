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

  Future<void> _requestPermissions(BuildContext context, NotificationProvider provider) async {
    await provider.requestAllPermissions();
    
    if (provider.allPermissionsGranted) {
      if (context.mounted) {
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
      }
    } else {
      if (context.mounted) {
        _showPermissionDeniedDialog(context, provider);
      }
    }
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context, NotificationProvider provider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Some permissions were not granted. You can enable them manually in Settings to use all features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

/// Modern permission helper that follows Android 13-15 best practices
class ModernPermissionManager {
  
  /// Requests notification permission with proper Android 13+ handling
  static Future<bool> requestNotificationPermission() async {
    // Android 13+ requires explicit notification permission
    final permission = Permission.notification;
    final status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    return false;
  }
  
  /// Requests schedule exact alarm permission (Android 12+)
  static Future<bool> requestExactAlarmPermission() async {
    final permission = Permission.scheduleExactAlarm;
    final status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // For exact alarms, we often need to direct users to settings
    if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    final result = await permission.request();
    return result.isGranted;
  }
  
  /// Comprehensive permission check for reminder apps
  static Future<PermissionStatus> checkAllPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    
    if (notificationStatus.isGranted && exactAlarmStatus.isGranted) {
      return PermissionStatus.granted;
    } else if (notificationStatus.isPermanentlyDenied || exactAlarmStatus.isPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    } else {
      return PermissionStatus.denied;
    }
  }
  
  /// Shows contextual permission explanation dialog
  static Future<bool> showPermissionRationale(BuildContext context) async {
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
          title: const Text('Stay Updated'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app needs notification permissions to:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text('• Alert you about upcoming reminders'),
              Text('• Send notifications at exact times'),
              Text('• Keep you on track with your tasks'),
              SizedBox(height: 16),
              Text(
                'You can change these permissions anytime in Settings.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
}

/// Extension to check specific permission groups
extension PermissionStatusExtension on PermissionStatus {
  bool get isAllowed => this == PermissionStatus.granted || this == PermissionStatus.limited;
}

/// Utility for handling permission flows in a modern way
class PermissionFlow {
  
  /// Main entry point for requesting all necessary permissions
  static Future<bool> requestAllPermissions(BuildContext context) async {
    try {
      // First, show rationale if needed
      final shouldRequest = await ModernPermissionManager.showPermissionRationale(context);
      
      if (!shouldRequest) {
        return false;
      }
      
      // Request notification permission (Android 13+ requirement)
      final notificationGranted = await ModernPermissionManager.requestNotificationPermission();
      
      // Request exact alarm permission (for precise timing)
      final exactAlarmGranted = await ModernPermissionManager.requestExactAlarmPermission();
      
      return notificationGranted && exactAlarmGranted;
      
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }
  
  /// Check if we should show permission rationale
  static Future<bool> shouldShowRationale() async {
    final notificationStatus = await Permission.notification.status;
    return notificationStatus.isDenied && !notificationStatus.isPermanentlyDenied;
  }
} 