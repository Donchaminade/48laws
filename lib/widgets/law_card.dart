import 'package:flutter/material.dart';
import '../models/law.dart';

class LawCard extends StatelessWidget {
  final Law law;
  final VoidCallback? onTap;
  final Function(Law) onToggleFav;

  const LawCard({
    super.key,
    required this.law,
    this.onTap,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Affiche la modale quand on tape
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 92, 76, 76),
          borderRadius: BorderRadius.circular(22),
          border: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5)
              .computeLuminance() > 0.5
              ? Border.all(color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), width: 2)
              : null,
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 8, 8, 8), Color.fromARGB(255, 1, 14, 131)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loi ${law.numero}',
              style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(
              law.titre,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            IconButton(
              icon: Icon(
                law.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: law.isFavorite ? Colors.amber : const Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () => onToggleFav(law),
            ),
          ],
        ),
      ),
    );
  }
}
