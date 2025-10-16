import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../data/laws.dart'; // To get law details from law number
import '../models/law.dart'; // To use Law object
import 'main_screen.dart'; // To navigate to MainScreen

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<Map<String, dynamic>> _notificationHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationHistory();
    _markAllNotificationsAsRead();
  }

  Future<void> _markAllNotificationsAsRead() async {
    await StorageService.clearUnreadNotifications();
  }

  Future<void> _loadNotificationHistory() async {
    final Map<int, List<DateTime>> historyMap = await StorageService.getNotifiedLawsHistory();
    final List<Map<String, dynamic>> historyList = [];

    historyMap.forEach((lawNumber, dates) {
      // Use a loop to find the law safely
      Law? foundLaw;
      for (var l in allLaws) {
        if (l.numero == lawNumber) {
          foundLaw = l;
          break;
        }
      }

      if (foundLaw != null) {
        for (DateTime date in dates) {
          historyList.add({
            'law': foundLaw,
            'date': date,
          });
        }
      }
    });

    // Sort by date, newest first
    historyList.sort((a, b) => b['date'].compareTo(a['date']));

    setState(() {
      _notificationHistory = historyList;
      _isLoading = false;
    });
  }

  void _showLawDetailsFromHistory(BuildContext context, Law law) {
    // Navigate to MainScreen and pass the law number
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(key: ValueKey(law.numero))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des notifications'),
        backgroundColor: const Color.fromARGB(255, 1, 14, 197),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificationHistory.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune notification historique pour le moment.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _notificationHistory.length,
                  itemBuilder: (context, index) {
                    final entry = _notificationHistory[index];
                    final Law law = entry['law'];
                    final DateTime date = entry['date'];

                    return Card(
                      color: const Color.fromARGB(255, 8, 8, 8),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active, color: Colors.amber),
                        title: Text(
                          'Loi ${law.numero}: ${law.titre}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Notifié le: ${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => _showLawDetailsFromHistory(context, law),
                      ),
                    );
                  },
                ),
    );
  }
}