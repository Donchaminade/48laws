import 'dart:math';
import 'package:flutter/material.dart'; // For MaterialPageRoute
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/laws.dart'; // Assuming allLaws is here
import '../models/law.dart';
import '../services/storage_service.dart';
import '../main.dart'; // To access navigatorKey
import '../screens/home_screen.dart'; // To navigate to HomeScreen

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Utilise l'icône de l'app

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      final int? lawNumber = int.tryParse(payload);
      if (lawNumber != null) {
        Law? law;
        for (var l in allLaws) {
          if (l.numero == lawNumber) {
            law = l;
            break;
          }
        }

        if (law != null) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialLawNumber: lawNumber),
            ),
          );
        }
      }
    }
  }

  Future<Law> _selectLawOfTheDay() async {
    final List<Law> allAvailableLaws = allLaws;
    final Map<int, List<DateTime>> history = await StorageService.getNotifiedLawsHistory();
    final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    // Filter out laws that have been notified more than twice in the last 7 days
    final List<Law> eligibleLaws = allAvailableLaws.where((law) {
      final List<DateTime> notifiedDates = history[law.numero] ?? [];
      final List<DateTime> recentNotifications = notifiedDates.where((date) => date.isAfter(sevenDaysAgo)).toList();
      return recentNotifications.length < 2; // Not more than twice a week
    }).toList();

    Law selectedLaw;
    if (eligibleLaws.isNotEmpty) {
      final _random = Random();
      selectedLaw = eligibleLaws[_random.nextInt(eligibleLaws.length)];
    } else {
      // Fallback: if all laws have been notified too often, pick any random law
      final _random = Random();
      selectedLaw = allAvailableLaws[_random.nextInt(allAvailableLaws.length)];
    }

    await StorageService.addNotifiedLawToHistory(selectedLaw.numero);
    return selectedLaw;
  }

  Future<void> scheduleDailyLawNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll(); // Cancel any existing daily notification

    final Law lawOfTheDay = await _selectLawOfTheDay();

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        'Loi du jour : ${lawOfTheDay.numero}',
        lawOfTheDay.titre,
        await _nextInstanceOfScheduledTime(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_law_channel',
            'Lois du Jour',
            channelDescription: 'Notifications quotidiennes des lois du pouvoir',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Loi du jour',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // Add app logo as large icon
            styleInformation: BigTextStyleInformation(''), // Pour un texte plus long
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Répéter chaque jour à la même heure
        payload: lawOfTheDay.numero.toString()); // Store law number in payload

    // Add the notified law to the unread list
    await StorageService.addUnreadNotification(lawOfTheDay.numero);
  }

  Future<tz.TZDateTime> _nextInstanceOfScheduledTime() async {
    final int hour = await StorageService.getNotificationTimeHour();
    final int minute = await StorageService.getNotificationTimeMinute();

    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("All notifications cancelled.");
  }
}
