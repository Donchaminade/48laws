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
}