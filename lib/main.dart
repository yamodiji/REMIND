import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/reminder_call_screen.dart';
import 'providers/reminder_provider.dart';
import 'providers/notification_provider.dart';
import 'models/reminder.dart';
import 'services/notification_service.dart';
import 'dart:async';

void main() async {
  runZonedGuarded(() async {
    // CRITICAL: Ensure Flutter binding is initialized first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize app with error handling
    await _initializeApp();
    
    runApp(const ReminderApp());
  }, (error, stack) {
    debugPrint('Global error caught: $error');
    debugPrint('Stack trace: $stack');
    // Run app anyway to prevent complete crash
    runApp(const ReminderApp());
  });
}

Future<void> _initializeApp() async {
  try {
    // Set preferred orientations safely
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).catchError((e) {
      debugPrint('Orientation setting failed: $e');
    });
    
    // Initialize Hive with comprehensive error handling
    await _initializeHive();
    
    // Initialize notifications with error handling
    await _initializeNotifications();
    
  } catch (e) {
    debugPrint('App initialization error: $e');
    // Continue app startup even if some services fail
  }
}

Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();
    
    // Register adapters safely
    if (!Hive.isAdapterRegistered(ReminderAdapter().typeId)) {
      Hive.registerAdapter(ReminderAdapter());
    }
    if (!Hive.isAdapterRegistered(RepeatTypeAdapter().typeId)) {
      Hive.registerAdapter(RepeatTypeAdapter());
    }
    
    // Open box with error handling
    if (!Hive.isBoxOpen('reminders')) {
      await Hive.openBox<Reminder>('reminders');
    }
    
    debugPrint('Hive initialized successfully');
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
    // App will continue without local storage
  }
}

Future<void> _initializeNotifications() async {
  try {
    await NotificationService.initialize();
    debugPrint('NotificationService initialized successfully');
  } catch (e) {
    debugPrint('NotificationService initialization failed: $e');
    // App will continue without notifications
  }
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Reminder App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Android 15 edge-to-edge support
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          // Android 15 edge-to-edge support
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        // Home screen with simple error handling
        home: const HomeScreen(),
        routes: {
          '/call': (context) => const ReminderCallScreen(),
        },
        // Handle navigation errors gracefully
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          );
        },
        builder: (context, child) {
          // Add error boundary
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Please restart the app'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Restart app
                          SystemNavigator.pop();
                        },
                        child: const Text('Restart'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return child!;
        },
      ),
    );
  }
}

// Safe wrapper for HomeScreen
class SafeHomeScreen extends StatelessWidget {
  const SafeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAppReadiness(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Reminder App...'),
                ],
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('App initialization incomplete'),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to navigate to home anyway
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text('Continue Anyway'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // App is ready, show main screen
        return const HomeScreen();
      },
    );
  }
  
  Future<bool> _checkAppReadiness() async {
    // Give services time to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if essential services are available
    bool hiveReady = Hive.isBoxOpen('reminders');
    
    debugPrint('App readiness check: Hive=$hiveReady');
    
    return true; // Always return true to allow app to continue
  }
}
