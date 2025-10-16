import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fohuit_lois/screens/notification_history_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../data/laws.dart' show allLaws;
import '../models/law.dart';
import '../widgets/law_card.dart';
import '../services/storage_service.dart';
import '../route_observer.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final int? initialLawNumber; // New optional parameter
  const HomeScreen({super.key, this.initialLawNumber}); // Update constructor

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with RouteAware, SingleTickerProviderStateMixin {
  AnimationController? _logoRotationController;
  List<Law> lawsList = [];
  List<Law> display = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _logoRotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    loadFavorites();
    _searchController.addListener(() {
      setState(() {});
    });

    // Check for initialLawNumber and show details
    if (widget.initialLawNumber != null) {
      _showLawDetailsFromInitialNumber(widget.initialLawNumber!);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLawNumber != oldWidget.initialLawNumber && widget.initialLawNumber != null) {
      _showLawDetailsFromInitialNumber(widget.initialLawNumber!);
    }
  }

  void _showLawDetailsFromInitialNumber(int lawNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Law? foundLaw;
      for (var l in allLaws) {
        if (l.numero == lawNumber) {
          foundLaw = l;
          break;
        }
      }
      if (foundLaw != null) {
        showLawDetails(foundLaw);
      }
    });
  }

  // Public method to show law details from outside
  void showLawDetailsFromOutside(Law law) {
    showLawDetails(law);
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
    _logoRotationController?.dispose();
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

  void _showNotificationOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Options de notification",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return FutureBuilder<Map<String, dynamic>>(
                future: Future.wait([
                  StorageService.getNotificationsEnabled(),
                  StorageService.getTextSize(),
                  StorageService.getNotificationTimeHour(),
                  StorageService.getNotificationTimeMinute(),
                ]).then((results) => {
                      'notificationsEnabled': results[0] as bool,
                      'textSize': results[1] as double,
                      'notificationHour': results[2] as int,
                      'notificationMinute': results[3] as int,
                    }),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  bool notificationsEnabled = snapshot.data!['notificationsEnabled'];
                  double currentTextSize = snapshot.data!['textSize'];
                  int notificationHour = snapshot.data!['notificationHour'];
                  int notificationMinute = snapshot.data!['notificationMinute'];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text(
                          "Notifications quotidiennes",
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: notificationsEnabled,
                        onChanged: (bool newValue) async {
                          setState(() {
                            notificationsEnabled = newValue;
                          });
                          await StorageService.setNotificationsEnabled(newValue);
                          if (newValue) {
                            NotificationService().scheduleDailyLawNotification();
                          } else {
                            NotificationService().cancelAllNotifications();
                          }
                        },
                        activeColor: Colors.amber,
                      ),
                      ListTile(
                        title: const Text(
                          "Heure de notification",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          '${notificationHour.toString().padLeft(2, '0')}:${notificationMinute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.amber, fontSize: 16),
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: notificationHour, minute: notificationMinute),
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              notificationHour = picked.hour;
                              notificationMinute = picked.minute;
                            });
                            await StorageService.setNotificationTimeHour(picked.hour);
                            await StorageService.setNotificationTimeMinute(picked.minute);
                            if (notificationsEnabled) {
                              NotificationService().scheduleDailyLawNotification();
                            }
                          }
                        },
                      ),
                      const Divider(color: Colors.white30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              "Taille du texte :",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Expanded(
                              child: Slider(
                                value: currentTextSize,
                                min: 0.8,
                                max: 1.5,
                                divisions: 7, // 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5
                                label: currentTextSize.toStringAsFixed(1),
                                onChanged: (double newValue) async {
                                  setState(() {
                                    currentTextSize = newValue;
                                  });
                                  await StorageService.setTextSize(newValue);
                                },
                                activeColor: Colors.amber,
                                inactiveColor: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Autres options ici si nécessaire
                    ],
                  );
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Fermer",
                style: TextStyle(color: Color(0xFF8090FF)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showLawDetails(Law law) {
    showDialog(
      context: context,
      builder: (_) => FutureBuilder<double>(
        future: StorageService.getTextSize(),
        builder: (context, snapshot) {
          double textSize = snapshot.data ?? 1.0; // Default to 1.0 if not loaded

          return Dialog(
            backgroundColor: Colors.transparent, // Make dialog background transparent
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Remove border radius for full screen effect
            insetPadding: EdgeInsets.zero, // Remove default dialog padding
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: double.infinity, // Take full width
                maxHeight: double.infinity, // Take full height
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0), // Remove border radius for full screen effect
                      gradient: const LinearGradient(
                        colors: [Color(0xFF232526), Color(0xFF414345)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0, // Remove border
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0), // Remove border radius for full screen effect
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Text(
                              "Loi ${law.numero}",
                              style: TextStyle(
                                color: const Color(0xFF8090FF),
                                fontSize: 28 * textSize, // Apply text size
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              law.titre,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20 * textSize, // Apply text size
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(color: Colors.white30, height: 30),
                            
                            // Law Text Section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                law.texte,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16 * textSize, // Apply text size
                                  height: 1.5, // Improved line spacing
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Explanation Section
                            Text(
                              "Explication :",
                              style: TextStyle(
                                color: const Color(0xFF8090FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * textSize, // Apply text size
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                law.explication,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15 * textSize, // Apply text size
                                  fontStyle: FontStyle.italic,
                                   height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 25),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Share.share(
                                        "Loi ${law.numero} : ${law.titre}\n\n${law.texte}\n\nExplication :\n${law.explication}");
                                  },
                                  icon: const Icon(Icons.share, color: Colors.black),
                                  label: const Text("Partager", style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                    color: law.isFavorite ? Colors.redAccent : Colors.black,
                                  ),
                                  label: Text(
                                      law.isFavorite ? "Retirer" : "Favori", style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          )
        );
      },
      )
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Optional: subtle fill color
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.amber, width: 2.0), // Highlight on focus
        ),
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
          leading: GestureDetector(
            onTap: () => _showNotificationOptionsDialog(context),
            child: Builder(
              builder: (context) {
                final logoWidget = Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/logo3.png'),
                      ),
                    ),
                  ),
                );
                if (_logoRotationController == null) {
                  return logoWidget;
                }
                return RotationTransition(
                  turns: _logoRotationController!,
                  child: logoWidget,
                );
              }
            ),
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
            FutureBuilder<List<int>>(
              future: StorageService.getUnreadNotifications(),
              builder: (context, snapshot) {
                final int unreadCount = snapshot.data?.length ?? 0;
                print('Unread notifications count: $unreadCount');
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationHistoryScreen()),
                        );
                        // Refresh unread count after returning from history screen
                        setState(() {});
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                );
              },
            ),
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
