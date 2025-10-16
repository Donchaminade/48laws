import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../data/laws.dart' show allLaws;
import '../models/law.dart';
import '../widgets/law_card.dart';
import '../services/storage_service.dart';
import '../route_observer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Law> lawsList = [];
  List<Law> display = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _searchFocusNode.unfocus();
  }

  void loadFavorites() async {
    final favs = await StorageService.getFavorites();
    setState(() {
      lawsList = allLaws
          .map((l) => l.copyWith(isFavorite: favs.contains(l.numero)))
          .toList();
      display = lawsList;
    });
  }

  void onSearch(String query) {
    setState(() {
      display = query.isEmpty
          ? lawsList
          : lawsList.where((l) {
              return l.titre.toLowerCase().contains(query.toLowerCase()) ||
                  l.numero.toString().contains(query);
            }).toList();
    });
  }

  void toggleFav(Law law) async {
    await StorageService.toggleFavorite(law.numero);
    loadFavorites();
  }

  void showLawDetails(Law law) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Loi ${law.numero}",
                  style: const TextStyle(
                    color: Color(0xFF8090FF),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  law.titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(color: Colors.white30, height: 30),
                Text(
                  law.texte,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Explication :",
                  style: TextStyle(
                    color: Color(0xFF8090FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  law.explication,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                            "Loi ${law.numero} : ${law.titre}\n\n${law.texte}");
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Partager"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 236, 194, 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        toggleFav(law);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        law.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: const Color.fromARGB(255, 221, 4, 4),
                      ),
                      label: Text(
                          law.isFavorite ? "Retirer" : "Favori"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: onSearch,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Rechercher...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo3.png'),
          ),
          title: _isSearchVisible
              ? _buildSearchField()
              : const Text(
                  'Les 48 lois du pouvoir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (_isSearchVisible) {
                    _searchFocusNode.requestFocus();
                  } else {
                    _searchController.clear();
                    onSearch('');
                  }
                });
              },
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 1, 14, 197),
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        backgroundColor: Colors.black,
        body: GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: display.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: () => showLawDetails(display[i]),
            child: LawCard(
              law: display[i],
              onToggleFav: toggleFav,
            ),
          ),
        ),
      ),
    );
  }
}
