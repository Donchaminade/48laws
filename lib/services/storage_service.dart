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

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  static const _lastNotifiedLawsKey = 'lastNotifiedLaws'; // Stores a list of "lawNumber:timestamp"

  // Retrieves the history of notified laws
  // Returns a Map where key is lawNumber (int) and value is a List of timestamps (DateTime)
  static Future<Map<int, List<DateTime>>> getNotifiedLawsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyStrings = prefs.getStringList(_lastNotifiedLawsKey) ?? [];
    final Map<int, List<DateTime>> history = {};

    for (String entry in historyStrings) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final int lawNumber = int.tryParse(parts[0]) ?? -1;
        final int timestamp = int.tryParse(parts[1]) ?? -1;
        if (lawNumber != -1 && timestamp != -1) {
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          history.update(lawNumber, (list) => list..add(dateTime),
              ifAbsent: () => [dateTime]);
        }
      }
    }
    return history;
  }

  // Adds a law to the notification history with the current timestamp
  // Cleans up old entries (older than 7 days)
  static Future<void> addNotifiedLawToHistory(int lawNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, List<DateTime>> currentHistory = await getNotifiedLawsHistory();
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Add current notification
    currentHistory.update(lawNumber, (list) => list..add(now),
        ifAbsent: () => [now]);

    // Clean up old entries
    final Map<int, List<DateTime>> cleanedHistory = {};
    currentHistory.forEach((num, dates) {
      final List<DateTime> recentDates = dates.where((date) => date.isAfter(sevenDaysAgo)).toList();
      if (recentDates.isNotEmpty) {
        cleanedHistory[num] = recentDates;
      }
    });

    // Convert back to list of strings for SharedPreferences
    final List<String> newHistoryStrings = [];
    cleanedHistory.forEach((num, dates) {
      for (DateTime date in dates) {
        newHistoryStrings.add('$num:${date.millisecondsSinceEpoch}');
      }
    });

    await prefs.setStringList(_lastNotifiedLawsKey, newHistoryStrings);
  }
}