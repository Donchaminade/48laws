import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class BottomNav extends StatefulWidget {
  final int index;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int notesCount = 0;
  int favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final allUserNotes = await StorageService.getAllNotes();
    final allFavoriteLaws = await StorageService.getAllFavoriteLaws();

    if (mounted) {
      setState(() {
        notesCount = allUserNotes.length;
        favoritesCount = allFavoriteLaws.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int itemIndex, {
    int badge = 0,
  }) {
    final isSelected = itemIndex == widget.index;

    Widget iconWidget = Icon(
      icon,
      color: isSelected
          ? const Color.fromARGB(255, 228, 194, 1)
          : Colors.white70,
    );

    if (badge > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
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
                key: ValueKey<int>(badge),
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
        onTap: () => widget.onTap(itemIndex),
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