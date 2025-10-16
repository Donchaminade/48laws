import 'package:flutter/material.dart';
import '../models/law.dart';
import '../data/laws.dart' show allLaws; // Importer la liste globale allLaws
import '../services/storage_service.dart';
import '../widgets/law_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Law> favoriteLaws = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    final favs = await StorageService.getFavorites();
    setState(() {
      favoriteLaws = allLaws
          .where((l) => favs.contains(l.numero))
          .map((l) => l.copyWith(isFavorite: true))
          .toList();
    });
  }

  void toggleFav(Law law) async {
    await StorageService.toggleFavorite(law.numero);
    loadFavorites(); // Recharge les favoris
  }

  void showLawDetails(Law law) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Loi ${law.numero}",
                style: const TextStyle(
                    color: Color.fromARGB(255, 221, 199, 3),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                law.titre,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const Divider(color: Colors.white30, height: 30),
              Text(
                law.texte,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                "Explication :",
                style: TextStyle(
                    color: const Color.fromARGB(255, 93, 103, 240),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                law.explication,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Favoris",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 2, 145),
        centerTitle: true,
      ),
      body: favoriteLaws.isEmpty
          ? const Center(
              child: Text(
                'Aucune loi favorite pour l’instant.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteLaws.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => showLawDetails(favoriteLaws[i]),
                child: LawCard(
                  law: favoriteLaws[i],
                  onToggleFav: toggleFav,
                ),
              ),
            ),
    );
  }
}
