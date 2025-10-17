import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favKey = 'favorites';
  static const _noteKeyPrefix = 'notes_';

  // --- FAVORITES ---

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Retourne une liste d'entiers (numéros de loi)
    return prefs.getStringList(_favKey)?.map(int.parse).toList() ?? [];
  }

  static Future<void> toggleFavorite(int numero) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    if (favs.contains(numero)) {
      favs.remove(numero);
    } else {
      favs.add(numero);
    }
    await prefs.setStringList(_favKey, favs.map((e) => e.toString()).toList());
  }

  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favKey);
  }

  // Cette méthode est spécifiquement pour le BottomNav pour obtenir le compte des favoris
  static Future<List<int>> getAllFavoriteLaws() async {
    return await getFavorites();
  }

  // --- NOTES ---

  // Obtient la note unique pour une loi donnée
  static Future<String?> getNoteForLaw(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_noteKeyPrefix$lawNumber');
  }

  // Sauvegarde/Met à jour la note pour une loi donnée
  static Future<void> saveNoteForLaw(int lawNumber, String noteText) async {
    final prefs = await SharedPreferences.getInstance();
    if (noteText.isEmpty) {
      // Si la note est vide, on la supprime (équivalent à supprimer)
      await prefs.remove('$_noteKeyPrefix$lawNumber');
    } else {
      await prefs.setString('$_noteKeyPrefix$lawNumber', noteText);
    }
  }

  // Supprime la note pour une loi donnée
  static Future<void> deleteNoteForLaw(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_noteKeyPrefix$lawNumber');
  }


  // Récupère toutes les notes stockées
  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final List<Map<String, dynamic>> notesList = [];

    for (var key in keys) {
      if (key.startsWith(_noteKeyPrefix)) {
        final lawNumber = int.parse(key.replaceFirst(_noteKeyPrefix, ''));
        final noteText = prefs.getString(key); // Utilise getString car c'est une note unique
        if (noteText != null && noteText.isNotEmpty) {
          notesList.add({
            'lawNumber': lawNumber,
            'note': noteText,
          });
        }
      }
    }
    return notesList;
  }

  // --- NOTIFICATIONS ---

  static const _notificationsEnabledKey = 'notificationsEnabled';
  static const _notificationTimeHourKey = 'notificationTimeHour';
  static const _notificationTimeMinuteKey = 'notificationTimeMinute';

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  static Future<int> getNotificationTimeHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notificationTimeHourKey) ?? 8; // Default to 8 AM
  }

  static Future<void> setNotificationTimeHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationTimeHourKey, hour);
  }

  static Future<int> getNotificationTimeMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notificationTimeMinuteKey) ?? 0; // Default to 0 minutes
  }

  static Future<void> setNotificationTimeMinute(int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationTimeMinuteKey, minute);
  }

  static const _unreadNotificationsKey = 'unreadNotifications'; // Stores a list of law numbers that are unread

  static Future<List<int>> getUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unreadNotificationsKey)?.map(int.parse).toList() ?? [];
  }

  static Future<void> addUnreadNotification(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> unread = await getUnreadNotifications();
    if (!unread.contains(lawNumber)) {
      unread.add(lawNumber);
      await prefs.setStringList(_unreadNotificationsKey, unread.map((e) => e.toString()).toList());
    }
  }

  static Future<void> clearUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unreadNotificationsKey);
  }

  static const _lastNotifiedLawsKey = 'lastNotifiedLaws'; // Stores a list of "lawNumber:timestamp"

  // Retrieves the history of notified laws
  // Returns a Map where key is lawNumber (int) and value is a List of timestamps (DateTime)
  static Future<Map<int, List<DateTime>>> getNotifiedLawsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList(_lastNotifiedLawsKey) ?? [];
    final Map<int, List<DateTime>> history = {};
    final DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

    for (String entry in historyStrings) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final int lawNumber = int.tryParse(parts[0]) ?? -1;
        final int timestamp = int.tryParse(parts[1]) ?? -1;
        if (lawNumber != -1 && timestamp != -1) {
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (dateTime.isAfter(threeDaysAgo)) {
            history.update(lawNumber, (list) => list..add(dateTime),
                ifAbsent: () => [dateTime]);
          }
        }
      }
    }
    return history;
  }

  static Future<void> addNotifiedLawToHistory(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, List<DateTime>> currentHistory = await getNotifiedLawsHistory();
    final DateTime now = DateTime.now();

    currentHistory.update(lawNumber, (list) => list..add(now), ifAbsent: () => [now]);

    final List<String> newHistoryStrings = [];
    currentHistory.forEach((num, dates) {
      for (DateTime date in dates) {
        newHistoryStrings.add('$num:${date.millisecondsSinceEpoch}');
      }
    });

    await prefs.setStringList(_lastNotifiedLawsKey, newHistoryStrings);
  }

  static Future<void> deleteNotificationFromHistory(int lawNumber, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, List<DateTime>> currentHistory = await getNotifiedLawsHistory();

    if (currentHistory.containsKey(lawNumber)) {
      currentHistory[lawNumber]!.removeWhere((d) => d.isAtSameMomentAs(date));
      if (currentHistory[lawNumber]!.isEmpty) {
        currentHistory.remove(lawNumber);
      }
    }

    final List<String> newHistoryStrings = [];
    currentHistory.forEach((num, dates) {
      for (DateTime d in dates) {
        newHistoryStrings.add('$num:${d.millisecondsSinceEpoch}');
      }
    });

    await prefs.setStringList(_lastNotifiedLawsKey, newHistoryStrings);
  }

  // --- TEXT SIZE ---

  static const _textSizeKey = 'textSize';
  static const double _defaultTextSize = 1.0; // Default scale factor

  static const _currentLawOfTheDayKey = 'currentLawOfTheDay';
  static const _lawOfTheDayDateKey = 'lawOfTheDayDate';

  static Future<int?> getCurrentLawOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentLawOfTheDayKey);
  }

  static Future<void> setCurrentLawOfTheDay(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentLawOfTheDayKey, lawNumber);
    await prefs.setString(_lawOfTheDayDateKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLawOfTheDayDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lawOfTheDayDateKey);
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  static Future<void> clearCurrentLawOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentLawOfTheDayKey);
    await prefs.remove(_lawOfTheDayDateKey);
  }

  static Future<double> getTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textSizeKey) ?? _defaultTextSize;
  }

  static Future<void> setTextSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textSizeKey, value);
  }
}