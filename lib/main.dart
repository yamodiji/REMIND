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


void main() async {
  // CRITICAL: Ensure Flutter binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive with error handling
    await Hive.initFlutter();
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(RepeatTypeAdapter());
    await Hive.openBox<Reminder>('reminders');
    debugPrint('Hive initialized successfully');
    
    // Initialize notifications (Android 15 compatible)
    await NotificationService.initialize();
    debugPrint('NotificationService initialized successfully');
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    runApp(const ReminderApp());
    
  } catch (e) {
    debugPrint('App initialization error: $e');
    // Run app even if some services fail to initialize
    runApp(const ReminderApp());
  }
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
        // Home screen
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
      ),
    );
  }
}
