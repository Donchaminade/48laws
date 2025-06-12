import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favKey = 'favorites';
  static const _noteKeyPrefix = 'notes_';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
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

  static Future<List<String>> getNotes(int numero) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_noteKeyPrefix$numero') ?? [];
  }

  static Future<void> addNote(int numero, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getNotes(numero);
    existing.add(note);
    await prefs.setStringList('$_noteKeyPrefix$numero', existing);
  }

  static Future<Map<int, List<String>>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final notesMap = <int, List<String>>{};
    for (var key in keys) {
      if (key.startsWith(_noteKeyPrefix)) {
        final numero = int.parse(key.replaceFirst(_noteKeyPrefix, ''));
        final notes = prefs.getStringList(key) ?? [];
        notesMap[numero] = notes;
      }
    }
    return notesMap;
  }
}
