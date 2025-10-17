import 'package:flutter/material.dart';
import 'package:fohuit_lois/services/logger_service.dart';
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
    logger.i('All unread notifications cleared.');
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialLawNumber: law.numero),
      ),
    );
  }

  Future<void> _deleteNotification(Law law, DateTime date) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cette notification de l'historique ?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteNotificationFromHistory(law.numero, date);
      _loadNotificationHistory(); // Refresh the list
    }
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
                    'Aucune notification reçue ces 3 derniers jours.',
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

                    return GestureDetector(
                      onLongPress: () => _deleteNotification(law, date),
                      child: Card(
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
                      ),
                    );
                  },
                ),
    );
  }
}