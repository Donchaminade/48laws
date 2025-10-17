import 'package:logger/logger.dart';

// Instance globale du logger pour une utilisation dans toute l'application.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Affiche 1 ligne de la pile d'appels
    errorMethodCount: 5, // Affiche 5 lignes pour les erreurs
    lineLength: 80, // Longueur de la ligne
    colors: true, // Affiche des couleurs pour les différents niveaux de log
    printEmojis: true, // Affiche des emojis pour les niveaux
    printTime: true, // Affiche l'heure du log
  ),
);
