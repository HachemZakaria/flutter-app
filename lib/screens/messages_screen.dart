import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../data/school_data.dart';
import '../services/firebase_service.dart';

class MessagesScreen extends StatefulWidget {
  final bool isAdmin;
  final bool isReadOnly;
  const MessagesScreen({
    super.key,
    this.isAdmin = false,
    this.isReadOnly = false,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountStr = prefs.getString('current_account');
      if (accountStr != null) {
        _currentUser = jsonDecode(accountStr);
      }

      if (_currentUser != null) {
        final userId = _currentUser!['uid'] ?? '';
        _messages = await FirebaseService.loadMessages(userId);
      }
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  // ═══════════════════════════════════════════════════════
  // ADMIN : Choix du type de message
  // ═══════════════════════════════════════════════════════

  void _showSendOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.send, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic ? 'إرسال رسالة' : 'Envoyer un message',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message à un parent
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: Text(
                AppTranslations.isArabic
                    ? 'رسالة لولي معين'
                    : 'Message à un parent',
              ),
              subtitle: Text(
                AppTranslations.isArabic
                    ? 'اختر ولياً من القائمة'
                    : 'Choisir un parent dans la liste',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSelectParent();
              },
            ),
            const Divider(),
            // Message à une classe
            ListTile(
              leading: const Icon(Icons.class_, color: Colors.orange),
              title: Text(
                AppTranslations.isArabic
                    ? 'رسالة لقسم كامل'
                    : 'Message à toute une classe',
              ),
              subtitle: Text(
                AppTranslations.isArabic
                    ? 'جميع أولياء القسم'
                    : 'Tous les parents de la classe',
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSelectClass();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ADMIN : Sélectionner un parent (avec recherche)
  // ═══════════════════════════════════════════════════════

  void _showSelectParent() async {
    List<Map<String, dynamic>> accounts = [];
    try {
      accounts = await FirebaseService.loadAllAccounts();
    } catch (e) {}

    if (!mounted) return;

    final searchController = TextEditingController();
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = accounts.where((acc) {
            final role = acc['role'] ?? '';
            if (role != 'parent' && role != 'student') return false;
            if (searchQuery.isEmpty) return true;

            final name = (acc['parentName'] ?? acc['studentName'] ?? '')
                .toString()
                .toLowerCase();
            final email = (acc['email'] ?? '').toString().toLowerCase();
            final query = searchQuery.toLowerCase();

            return name.contains(query) || email.contains(query);
          }).toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppTranslations.isArabic
                  ? 'اختر المرسل إليه'
                  : 'Choisir le destinataire',
              style: const TextStyle(fontSize: 16),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // ✅ Barre de recherche
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: tr('search'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setDialogState(() {
                                  searchController.clear();
                                  searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filtered.length} ${AppTranslations.isArabic ? "نتيجة" : "résultat(s)"}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              AppTranslations.isArabic
                                  ? 'لا توجد نتائج'
                                  : 'Aucun résultat',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final acc = filtered[index];
                              final isParent = acc['role'] == 'parent';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isParent
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.blue.withOpacity(0.15),
                                  child: Icon(
                                    isParent
                                        ? Icons.family_restroom
                                        : Icons.school,
                                    color: isParent
                                        ? Colors.green
                                        : Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  acc['parentName'] ?? acc['studentName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  acc['email'] ?? '',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showMessageDialog(
                                    toUserId: acc['uid'] ?? '',
                                    toName:
                                        acc['parentName'] ??
                                        acc['studentName'] ??
                                        '',
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ADMIN : Sélectionner une classe
  // ═══════════════════════════════════════════════════════

  void _showSelectClass() {
    String? selectedCycle;
    String? selectedLevel;
    String? selectedClass;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppTranslations.isArabic ? 'اختر القسم' : 'Choisir la classe',
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCycle,
                    decoration: InputDecoration(
                      labelText: tr('cycle'),
                      border: const OutlineInputBorder(),
                    ),
                    items: SchoolData.cycles.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCycle = value;
                        selectedLevel = null;
                        selectedClass = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedCycle != null)
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: tr('level'),
                        border: const OutlineInputBorder(),
                      ),
                      items: SchoolData.levelsByCycle[selectedCycle]!.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedLevel = value;
                          selectedClass = null;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  if (selectedLevel != null)
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: InputDecoration(
                        labelText: tr('class_'),
                        border: const OutlineInputBorder(),
                      ),
                      items: SchoolData.getClassesForLevel(selectedLevel!).map((
                        c,
                      ) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedClass = value;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              if (selectedClass != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showClassMessageDialog(selectedClass!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(
                    AppTranslations.isArabic ? 'التالي' : 'Suivant',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // DIALOG : Message individuel
  // ═══════════════════════════════════════════════════════

  void _showMessageDialog({required String toUserId, required String toName}) {
    final messageController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.person, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppTranslations.isArabic ? "إلى" : "À"}: $toName',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            content: TextField(
              controller: messageController,
              enabled: !isSending,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppTranslations.isArabic ? 'الرسالة' : 'Message',
                border: const OutlineInputBorder(),
              ),
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
                        if (messageController.text.isEmpty) return;

                        setDialogState(() => isSending = true);

                        try {
                          await FirebaseService.sendMessage(
                            fromUserId: _currentUser!['uid'] ?? '',
                            fromName:
                                _currentUser!['parentName'] ??
                                _currentUser!['studentName'] ??
                                'Admin',
                            toUserId: toUserId,
                            toName: toName,
                            message: messageController.text.trim(),
                          );
                          await _load();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setDialogState(() => isSending = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                        AppTranslations.isArabic ? 'إرسال' : 'Envoyer',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // DIALOG : Message à toute une classe
  // ═══════════════════════════════════════════════════════

  void _showClassMessageDialog(String className) {
    final messageController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.class_, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${AppTranslations.isArabic ? "إلى القسم" : "À la classe"}: $className',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            content: TextField(
              controller: messageController,
              enabled: !isSending,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: AppTranslations.isArabic ? 'الرسالة' : 'Message',
                border: const OutlineInputBorder(),
              ),
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
                        if (messageController.text.isEmpty) return;

                        setDialogState(() => isSending = true);

                        try {
                          await FirebaseService.sendMessageToClass(
                            fromUserId: _currentUser!['uid'] ?? '',
                            fromName: 'Administration',
                            className: className,
                            message: messageController.text.trim(),
                          );
                          await _load();
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setDialogState(() => isSending = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
                        AppTranslations.isArabic ? 'إرسال' : 'Envoyer',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // PARENT : Répondre à l'école
  // ═══════════════════════════════════════════════════════

  void _showReplyToSchool() {
    _showMessageDialog(
      toUserId: 'admin',
      toName: AppTranslations.isArabic ? 'الإدارة' : 'Administration',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.isArabic ? 'الرسائل' : 'Messages'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton(
              onPressed: widget.isAdmin ? _showSendOptions : _showReplyToSchool,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.edit, color: Colors.white),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.message, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.isArabic
                        ? 'لا توجد رسائل'
                        : 'Aucun message',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isSent = m['fromUserId'] == _currentUser?['uid'];
                final isClassMsg = m['isClassMessage'] == true;
                final dateStr = m['date']?.toString() ?? '';
                String formattedDate = '';
                try {
                  final date = DateTime.parse(dateStr);
                  formattedDate = DateFormat('dd/MM HH:mm').format(date);
                } catch (_) {}

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSent
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                    ),
                  ),
                  color: isSent ? Colors.blue.withOpacity(0.03) : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: isSent
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      child: Icon(
                        isSent
                            ? Icons.send
                            : (isClassMsg ? Icons.class_ : Icons.inbox),
                        color: isSent ? Colors.blue : Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isSent
                                ? '${AppTranslations.isArabic ? "إلى" : "À"}: ${m['toName']}'
                                : '${AppTranslations.isArabic ? "من" : "De"}: ${m['fromName']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isClassMsg)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              m['className'] ?? '',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          m['message'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // Bouton répondre (pour parent)
                    trailing: !widget.isAdmin && !isSent && !widget.isReadOnly
                        ? IconButton(
                            onPressed: () {
                              _showMessageDialog(
                                toUserId: m['fromUserId'] ?? '',
                                toName: m['fromName'] ?? '',
                              );
                            },
                            icon: const Icon(Icons.reply, color: Colors.blue),
                            tooltip: AppTranslations.isArabic
                                ? 'رد'
                                : 'Répondre',
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
