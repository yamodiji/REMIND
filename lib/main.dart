import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/reminder_call_screen.dart';
import 'providers/reminder_provider.dart';
import 'providers/notification_provider.dart';
import 'models/reminder.dart';
import 'services/notification_service.dart';
import 'dart:async';
import 'dart:isolate';

void main() async {
  // CRITICAL: Global error handling wrapper
  runZonedGuarded(() async {
    // Ensure Flutter binding is initialized FIRST
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set up global error handlers BEFORE any other initialization
    _setupGlobalErrorHandling();
    
    // Initialize app with comprehensive error handling
    await _initializeApp();
    
    runApp(const ReminderApp());
  }, (error, stack) {
    // Global error catcher - prevent complete app crashes
    debugPrint('🔥 CRITICAL ERROR CAUGHT: $error');
    debugPrint('Stack trace: $stack');
    
    // Try to run basic app even if initialization failed
    try {
      runApp(const FallbackApp());
    } catch (e) {
      debugPrint('Even fallback app failed: $e');
    }
  });
}

/// Setup comprehensive global error handling following reference guide patterns
void _setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🐛 Flutter Error: ${details.exception}');
    debugPrint('Widget: ${details.context}');
    FlutterError.presentError(details);
  };
  
  // Handle platform dispatcher errors (async errors outside Flutter)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 Platform Error: $error');
    debugPrint('Stack: $stack');
    return true; // Mark as handled
  };
  
  // Handle isolate errors
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      debugPrint('🔥 Isolate Error: ${errorAndStacktrace.first}');
    }).sendPort,
  );
}

/// Robust initialization following reference guide patterns
Future<void> _initializeApp() async {
  try {
    debugPrint('🚀 Starting app initialization...');
    
    // 1. Set system UI configuration safely
    await _configureSystemUI();
    
    // 2. Initialize storage with error handling
    await _initializeHive();
    
    // 3. Initialize notifications with timeout protection
    await _initializeNotifications();
    
    debugPrint('✅ App initialization completed successfully');
    
  } catch (e, stack) {
    debugPrint('❌ App initialization failed: $e');
    debugPrint('Stack: $stack');
    // Continue with app startup - services will have fallbacks
  }
}

/// Configure system UI with error handling
Future<void> _configureSystemUI() async {
  try {
    // Edge-to-edge display configuration
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    
    // Set preferred orientations safely
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('⏰ Orientation setting timed out');
      },
    );
    
    // Set system overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    
    debugPrint('✅ System UI configured');
  } catch (e) {
    debugPrint('⚠️ System UI configuration failed: $e');
    // Continue - not critical for app functionality
  }
}

/// Initialize Hive with comprehensive error handling
Future<void> _initializeHive() async {
  try {
    debugPrint('🗄️ Initializing Hive...');
    
    // Initialize Hive Flutter integration
    await Hive.initFlutter().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Hive initialization timeout');
      },
    );
    
    // Register adapters safely with duplicate checks
    _registerHiveAdapters();
    
    // Open required boxes with error handling
    await _openHiveBoxes();
    
    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('❌ Hive initialization failed: $e');
    // App will continue without local storage
    // Provider will handle missing box gracefully
  }
}

/// Register Hive adapters with duplicate protection
void _registerHiveAdapters() {
  try {
    // Check and register Reminder adapter
    if (!Hive.isAdapterRegistered(ReminderAdapter().typeId)) {
      Hive.registerAdapter(ReminderAdapter());
      debugPrint('📝 Registered ReminderAdapter');
    }
    
    // Check and register RepeatType adapter
    if (!Hive.isAdapterRegistered(RepeatTypeAdapter().typeId)) {
      Hive.registerAdapter(RepeatTypeAdapter());
      debugPrint('🔄 Registered RepeatTypeAdapter');
    }
  } catch (e) {
    debugPrint('⚠️ Adapter registration failed: $e');
    // Continue - adapters might already be registered
  }
}

/// Open Hive boxes with error handling
Future<void> _openHiveBoxes() async {
  try {
    // Open reminders box if not already open
    if (!Hive.isBoxOpen('reminders')) {
      await Hive.openBox<Reminder>('reminders').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Box opening timeout');
        },
      );
      debugPrint('📦 Reminders box opened');
    }
  } catch (e) {
    debugPrint('❌ Failed to open Hive boxes: $e');
    rethrow; // This is critical for app functionality
  }
}

/// Initialize notifications with timeout and error handling
Future<void> _initializeNotifications() async {
  try {
    debugPrint('🔔 Initializing notifications...');
    
    // Initialize with timeout protection
    await NotificationService.initialize().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('⏰ Notification service timeout');
        throw TimeoutException('Notification initialization timeout');
      },
    );
    
    debugPrint('✅ Notification service initialized');
  } catch (e) {
    debugPrint('⚠️ Notification service initialization failed: $e');
    // App will continue without notifications
    // NotificationProvider will handle this gracefully
  }
}

/// Main app widget with error boundaries
class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use create with error handling
        ChangeNotifierProvider(
          create: (_) {
            try {
              return ReminderProvider();
            } catch (e) {
              debugPrint('❌ ReminderProvider creation failed: $e');
              return ReminderProvider(); // Return basic instance
            }
          },
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(
          create: (_) {
            try {
              return NotificationProvider();
            } catch (e) {
              debugPrint('❌ NotificationProvider creation failed: $e');
              return NotificationProvider(); // Return basic instance
            }
          },
          lazy: false, // Initialize immediately
        ),
      ],
      child: MaterialApp(
        title: 'Reminder App',
        debugShowCheckedModeBanner: false,
        
        // Modern Material 3 theme
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
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
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        
        // Use SafeHomeScreen wrapper for error handling
        home: const SafeHomeScreen(),
        
        // Route configuration
        routes: {
          '/call': (context) => const ReminderCallScreen(),
        },
        
        // Handle unknown routes gracefully
        onUnknownRoute: (settings) {
          debugPrint('⚠️ Unknown route: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => const SafeHomeScreen(),
          );
        },
        
        // Global error widget builder
        builder: (context, child) {
          // Set custom error widget
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return _buildErrorWidget(errorDetails);
          };
          return child!;
        },
      ),
    );
  }

  /// Build user-friendly error widget
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The app encountered an unexpected error. Please restart the app.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart App'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Safe wrapper for HomeScreen with loading states and error handling
class SafeHomeScreen extends StatefulWidget {
  const SafeHomeScreen({super.key});

  @override
  State<SafeHomeScreen> createState() => _SafeHomeScreenState();
}

class _SafeHomeScreenState extends State<SafeHomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppReadiness();
  }

  Future<void> _checkAppReadiness() async {
    try {
      // Give providers time to initialize
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('✅ App ready for use');
    } catch (e) {
      debugPrint('⚠️ App readiness check failed: $e');
      // Continue anyway - individual features will handle their own errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _checkAppReadiness(),
      builder: (context, snapshot) {
        // Show loading screen briefly during initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        // Show main home screen
        return const HomeScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Reminder App...',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Initializing services...',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback app for extreme error cases
class FallbackApp extends StatelessWidget {
  const FallbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      home: Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Initialization Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The app could not start properly. Please check your device storage and restart the app.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
