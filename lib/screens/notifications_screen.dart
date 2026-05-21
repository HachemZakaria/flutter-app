import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../data/app_translations.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _notifications = await FirebaseService.loadNotifications(widget.userId);
      // Marquer toutes comme lues
      await FirebaseService.markAllNotificationsAsRead(widget.userId);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'announcement':
        return Icons.campaign;
      case 'message':
        return Icons.message;
      case 'grade':
        return Icons.grade;
      case 'absence':
        return Icons.event_busy;
      case 'payment':
        return Icons.payments;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'announcement':
        return Colors.purple;
      case 'message':
        return Colors.blue;
      case 'grade':
        return Colors.orange;
      case 'absence':
        return Colors.red;
      case 'payment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.isArabic ? 'الإشعارات' : 'Notifications'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.isArabic
                        ? 'لا توجد إشعارات'
                        : 'Aucune notification',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final type = n['type'] ?? '';
                final color = _getColor(type);
                final dateStr = n['date']?.toString() ?? '';
                String formattedDate = '';
                try {
                  final date = DateTime.parse(dateStr);
                  formattedDate = DateFormat('dd/MM HH:mm').format(date);
                } catch (_) {}

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(_getIcon(type), color: color),
                    ),
                    title: Text(
                      n['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['message'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
