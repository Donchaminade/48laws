import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart'; // For MaterialPageRoute
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fohuit_lois/services/logger_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

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
    logger.i('Notification payload received: $payload');
    if (payload != null && payload.isNotEmpty) {
      final int? lawNumber = int.tryParse(payload);
      logger.i('Parsed law number from payload: $lawNumber');
      if (lawNumber != null) {
        Law? law;
        for (var l in allLaws) {
          if (l.numero == lawNumber) {
            law = l;
            break;
          }
        }

        if (law != null) {
          logger.i('Navigating to HomeScreen with initialLawNumber: $lawNumber');
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialLawNumber: lawNumber),
            ),
          );
        } else {
          logger.w('Law not found for law number: $lawNumber');
        }
      } else {
        logger.w('Failed to parse law number from payload.');
      }
    } else {
      logger.w('Notification payload is null or empty.');
    }
  }

  Future<void> scheduleDailyLawNotification() async {
    final int hour = await StorageService.getNotificationTimeHour();
    final int minute = await StorageService.getNotificationTimeMinute();

    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(0); // Cancel any existing alarm
      await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        0, // Alarm ID
        fireAlarm, // The top-level function from main.dart
        startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute),
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
      );
      logger.i("Scheduled alarm for Android at $hour:$minute daily.");
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.cancelAll(); // Annule toutes les notifications existantes

      final Law lawToNotify = await _getOrCreateLawOfTheDay(); // Obtient ou crée la loi du jour

      await flutterLocalNotificationsPlugin.zonedSchedule(
          0, // Notification ID
          'Loi du jour : ${lawToNotify.numero}',
          lawToNotify.titre,
          await _nextInstanceOfScheduledTime(),
          const NotificationDetails(
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
          payload: lawToNotify.numero.toString()); // Store law number in payload

      logger.i('Notification for Law ${lawToNotify.numero} scheduled for iOS.');
    }
  }

  Future<void> showNotification() async {
    final Law lawToNotify = await _getOrCreateLawOfTheDay();
    await flutterLocalNotificationsPlugin.show(
      0,
      'Loi du jour : ${lawToNotify.numero}',
      lawToNotify.titre,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_law_channel',
          'Lois du Jour',
          channelDescription: 'Notifications quotidiennes des lois du pouvoir',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Loi du jour',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(null),
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: lawToNotify.numero.toString(),
    );
    logger.i('Showing notification for Law ${lawToNotify.numero}');
  }


  Future<Law> _getOrCreateLawOfTheDay() async {
    final DateTime now = DateTime.now();
    final DateTime? lastSelectedDate = await StorageService.getLawOfTheDayDate();
    final int? lastSelectedLawNumber = await StorageService.getCurrentLawOfTheDay();

    // Check if a law was already selected for today
    if (lastSelectedDate != null &&
        lastSelectedLawNumber != null &&
        lastSelectedDate.year == now.year &&
        lastSelectedDate.month == now.month &&
        lastSelectedDate.day == now.day) {
      // Return the already selected law for today
      Law? existingLaw;
      for (var l in allLaws) {
        if (l.numero == lastSelectedLawNumber) {
          existingLaw = l;
          break;
        }
      }
      if (existingLaw != null) {
        logger.d('Returning already selected Law of the Day: ${existingLaw.numero}');
        return existingLaw;
      }
    }

    // If no law was selected for today, or if it's a new day, select a new one
    final List<Law> allAvailableLaws = allLaws;
    final Map<int, List<DateTime>> history = await StorageService.getNotifiedLawsHistory();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

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

    // Store the newly selected law as the Law of the Day for today
    await StorageService.setCurrentLawOfTheDay(selectedLaw.numero);
    // Add to history and unread only when a NEW law is selected for the day
    await StorageService.addNotifiedLawToHistory(selectedLaw.numero);
    await StorageService.addUnreadNotification(selectedLaw.numero);
    logger.i('Selected new Law of the Day: ${selectedLaw.numero} and added to history/unread.');

    return selectedLaw;
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
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(0);
      logger.i("Cancelled Android alarm.");
    }
    await flutterLocalNotificationsPlugin.cancelAll();
    logger.i("All notifications cancelled.");
  }
}
