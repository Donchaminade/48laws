import 'package:flutter/material.dart';
import '../screens/notes_screen.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/about_screen.dart';

import '../services/storage_service.dart';

class BottomNav extends StatefulWidget {
  final int index;
  const BottomNav({super.key, required this.index});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int notesCount = 0;
  int favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    // Les comptes sont chargés dans `build` pour une mise à jour dynamique.
  }

  /// Charge les comptes des notes et des favoris depuis StorageService.
  Future<void> _loadCounts() async {
    final allUserNotes = await StorageService.getAllNotes();
    final allFavoriteLaws = await StorageService.getAllFavoriteLaws();

    // Met à jour l'état seulement si les valeurs ont changé pour éviter des rebuilds inutiles
    if (notesCount != allUserNotes.length || favoritesCount != allFavoriteLaws.length) {
      // Vérifie si le widget est encore monté avant d'appeler setState
      if (mounted) {
        setState(() {
          notesCount = allUserNotes.length;
          favoritesCount = allFavoriteLaws.length;
        });
      }
    }
  }

  /// Navigue vers l'écran correspondant à l'index donné.
  void _navigate(BuildContext context, int newIndex) {
    if (newIndex == widget.index) return; // Ne fait rien si c'est déjà l'écran actuel

    Widget screen;
    switch (newIndex) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const NotesScreen();
        break;
      case 2:
        screen = const FavoritesScreen();
        break;
      case 3:
        screen = const AboutScreen();
        break;
      default:
        screen = const HomeScreen(); // Fallback
        break;
    }

    // Utilise pushReplacement pour remplacer l'écran actuel dans la pile de navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Appelle _loadCounts ici pour s'assurer que les badges sont à jour
    // chaque fois que la BottomNav est reconstruite (par ex. après une navigation).
    _loadCounts();

    return Container(
      height: 65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 1, 11, 155),
            Color.fromARGB(255, 1, 11, 150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 17, 17, 17).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.book, "Lois", 0),
          _navItem(context, Icons.note_alt, "Notes", 1, badge: notesCount),
          _navItem(context, Icons.favorite, "Favoris", 2, badge: favoritesCount),
          _navItem(context, Icons.info_outline, "À Propos", 3),
        ],
      ),
    );
  }

  /// Crée un élément de navigation pour la barre inférieure.
  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int itemIndex, {
    int badge = 0, // Nombre à afficher dans le badge
  }) {
    final isSelected = itemIndex == widget.index;

    Widget iconWidget = Icon(
      icon,
      color: isSelected
          ? const Color.fromARGB(255, 228, 194, 1) // Couleur si sélectionné
          : Colors.white70, // Couleur par défaut
    );

    // Ajoute un badge si le nombre est supérieur à 0
    if (badge > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none, // Permet au badge de déborder
        children: [
          iconWidget,
          Positioned(
            right: -6,
            top: -6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Container(
                key: ValueKey<int>(badge), // Clé pour l'animation
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => _navigate(context, itemIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.4 : 1.0,
                child: iconWidget,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? const Color.fromARGB(255, 206, 175, 2)
                      : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}