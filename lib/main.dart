import 'package:flutter/material.dart';
import 'package:fohuit_lois/screens/main_screen.dart';
import 'package:fohuit_lois/services/logger_service.dart';
import 'package:fohuit_lois/services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'route_observer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import for FlutterLocalNotificationsPlugin
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// This function will be executed by the alarm manager in the background
@pragma('vm:entry-point')
void fireAlarm() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().showNotification();
  logger.i("Alarm fired!");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await AndroidAlarmManager.initialize(); // Initialize Alarm Manager

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Handle notification launch
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? initialRoute;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final String? payload = notificationAppLaunchDetails!.notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      final int? lawNumber = int.tryParse(payload);
      if (lawNumber != null) {
        initialRoute = '/home?lawNumber=$lawNumber'; // Custom route for deep linking
      }
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String? initialRoute;
  const MyApp({super.key, this.initialRoute});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the global key here
      title: '48 Lois',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(150, 1, 18, 173),
          secondary: Color.fromARGB(255, 1, 4, 156),
          surface: Colors.grey.shade900,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 243, 242, 241), fontSize: 20),
        ),
      ),
      home: initialRoute != null ? _handleInitialRoute(initialRoute!) : const SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }

  Widget _handleInitialRoute(String route) {
    final uri = Uri.parse(route);
    if (uri.path == '/home') {
      final lawNumber = int.tryParse(uri.queryParameters['lawNumber'] ?? '');
      if (lawNumber != null) {
        return MainScreen(initialLawNumber: lawNumber);
      }
    }
    return const SplashScreen(); // Fallback
  }
}

