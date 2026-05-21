import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../data/app_translations.dart';

class AnnouncementsScreen extends StatefulWidget {
  final bool isAdmin;
  const AnnouncementsScreen({super.key, this.isAdmin = false});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _announcements = await FirebaseService.loadAnnouncements();
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              AppTranslations.isArabic ? 'إعلان جديد' : 'Nouvelle annonce',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  enabled: !isSending,
                  decoration: InputDecoration(
                    labelText: AppTranslations.isArabic ? 'العنوان' : 'Titre',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  enabled: !isSending,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppTranslations.isArabic ? 'الرسالة' : 'Message',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        if (titleController.text.isEmpty ||
                            messageController.text.isEmpty)
                          return;

                        setDialogState(() => isSending = true);

                        try {
                          await FirebaseService.addAnnouncement(
                            titleController.text.trim(),
                            messageController.text.trim(),
                          );
                          await _load();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setDialogState(() => isSending = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppTranslations.isArabic ? 'نشر' : 'Publier',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.isArabic ? 'الإعلانات' : 'Annonces'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.isArabic
                        ? 'لا توجد إعلانات'
                        : 'Aucune annonce',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final a = _announcements[index];
                final dateStr = a['date']?.toString() ?? '';
                String formattedDate = '';
                try {
                  final date = DateTime.parse(dateStr);
                  formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
                } catch (_) {}

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.campaign, color: Colors.purple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (widget.isAdmin)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await FirebaseService.deleteAnnouncement(
                                    a['id'],
                                  );
                                  await _load();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a['message'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
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
