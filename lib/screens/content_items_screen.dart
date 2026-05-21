import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class ContentItemsScreen extends StatefulWidget {
  final String moduleType;
  final String moduleTitle;
  final Color moduleColor;
  final String cycle;
  final String level;
  final String subject;
  final String trimestre;
  final bool isReadOnly;

  const ContentItemsScreen({
    super.key,
    required this.moduleType,
    required this.moduleTitle,
    required this.moduleColor,
    required this.cycle,
    required this.level,
    required this.subject,
    required this.trimestre,
    this.isReadOnly = false,
  });

  @override
  State<ContentItemsScreen> createState() => _ContentItemsScreenState();
}

class _ContentItemsScreenState extends State<ContentItemsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  String get _storageKey =>
      '${widget.moduleType}_${widget.cycle}_${widget.level}_${widget.subject}_${widget.trimestre}';

  String _getTrimestreTranslated(String trim) {
    switch (trim) {
      case 'Trimestre 1':
        return tr('trimester_1');
      case 'Trimestre 2':
        return tr('trimester_2');
      case 'Trimestre 3':
        return tr('trimester_3');
      default:
        return trim;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      _items = await FirebaseService.loadContent(_storageKey);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveItems() async {
    try {
      await FirebaseService.saveContent(_storageKey, _items);
    } catch (e) {}
  }

  // ═══════════════════════════════════════════════════════
  // AJOUTER UN CONTENU
  // ═══════════════════════════════════════════════════════

  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final linkController = TextEditingController();
    String? fileName;
    String? fileBase64;
    String? fileType;
    bool useLink = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              widget.moduleType == 'courses'
                  ? tr('add_course')
                  : tr('add_correction'),
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.moduleColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.subject} - ${_getTrimestreTranslated(widget.trimestre)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.moduleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Titre
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '${tr('title')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: tr('description'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Choix : Fichier direct OU Lien Google Drive
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              useLink = false;
                              linkController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !useLink
                                  ? widget.moduleColor.withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !useLink
                                    ? widget.moduleColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: !useLink
                                      ? widget.moduleColor
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppTranslations.isArabic
                                      ? 'ملف صغير'
                                      : 'Fichier < 1MB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: !useLink
                                        ? widget.moduleColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              useLink = true;
                              fileName = null;
                              fileBase64 = null;
                              fileType = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: useLink
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: useLink
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.link,
                                  color: useLink ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Google Drive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: useLink ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ✅ Option 1 : Upload fichier (< 1MB)
                  if (!useLink)
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.any,
                          withData: true,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;

                          if (file.size > 1 * 1024 * 1024) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.isArabic
                                      ? 'الملف كبير جداً! استخدم Google Drive'
                                      : 'Fichier trop gros ! Utilisez Google Drive',
                                ),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: 'Drive',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    setDialogState(() => useLink = true);
                                  },
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            fileName = file.name;
                            fileType = file.extension;
                            if (file.bytes != null) {
                              fileBase64 = base64Encode(file.bytes!);
                            }
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: fileName != null
                                ? Colors.green
                                : widget.moduleColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: fileName != null
                              ? Colors.green.withOpacity(0.05)
                              : widget.moduleColor.withOpacity(0.05),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              fileName != null
                                  ? Icons.check_circle
                                  : Icons.cloud_upload,
                              size: 36,
                              color: fileName != null
                                  ? Colors.green
                                  : widget.moduleColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fileName ?? tr('attach_file'),
                              style: TextStyle(
                                color: fileName != null
                                    ? Colors.green
                                    : widget.moduleColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (fileName == null)
                              Text(
                                AppTranslations.isArabic
                                    ? 'الحد الأقصى 1 ميغا'
                                    : 'Max 1 MB',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // ✅ Option 2 : Lien Google Drive
                  if (useLink)
                    Column(
                      children: [
                        TextField(
                          controller: linkController,
                          decoration: InputDecoration(
                            labelText: AppTranslations.isArabic
                                ? 'رابط Google Drive'
                                : 'Lien Google Drive',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.link,
                              color: Colors.blue,
                            ),
                            hintText: 'https://drive.google.com/...',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppTranslations.isArabic
                                      ? '1. ارفع الملف على Google Drive\n2. انقر يمين → مشاركة → نسخ الرابط\n3. الصق الرابط هنا'
                                      : '1. Uploadez sur Google Drive\n2. Clic droit → Partager → Copier le lien\n3. Collez le lien ici',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // Bouton retirer fichier
                  if (fileName != null && !useLink)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            fileName = null;
                            fileBase64 = null;
                            fileType = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: Text(
                          tr('delete'),
                          style: const TextStyle(color: Colors.red),
                        ),
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
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.isArabic
                              ? 'العنوان إجباري'
                              : 'Le titre est obligatoire',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _items.add({
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'fileName': fileName,
                      'fileBase64': fileBase64,
                      'fileType': fileType,
                      'link': linkController.text.trim(),
                      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      'time': DateFormat('HH:mm').format(DateTime.now()),
                    });
                  });

                  await _saveItems();
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.moduleColor,
                ),
                child: Text(
                  tr('save'),
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
  // OUVRIR FICHIER OU LIEN
  // ═══════════════════════════════════════════════════════

  void _openFile(Map<String, dynamic> item) async {
    // ✅ Si c'est un lien Google Drive
    final link = item['link']?.toString() ?? '';
    if (link.isNotEmpty) {
      try {
        final uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTranslations.isArabic
                      ? 'تعذر فتح الرابط'
                      : 'Impossible d\'ouvrir le lien',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    // ✅ Si c'est un fichier local
    if (item['fileBase64'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.isArabic
                ? 'لا يوجد ملف'
                : 'Aucun fichier disponible',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final bytes = base64Decode(item['fileBase64']);
      final fileName = item['fileName'] ?? 'fichier.pdf';

      if (kIsWeb) {
        // Web : téléchargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📄 $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Android : ouvrir le fichier
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // VOIR DÉTAIL
  // ═══════════════════════════════════════════════════════

  void _showDetail(Map<String, dynamic> item) {
    final link = item['link']?.toString() ?? '';
    final hasFile = item['fileBase64'] != null;
    final hasLink = link.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item['title'] ?? '', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((item['description'] ?? '').toString().isNotEmpty) ...[
              Text(item['description']),
              const SizedBox(height: 12),
            ],
            if (hasFile)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['fileName'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Type: ${item['fileType'] ?? '?'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (hasLink)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Drive',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            link,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${item['date']} - ${item['time']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (hasFile || hasLink)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openFile(item);
              },
              icon: Icon(hasLink ? Icons.open_in_new : Icons.download),
              label: Text(
                hasLink
                    ? (AppTranslations.isArabic
                          ? 'فتح الرابط'
                          : 'Ouvrir le lien')
                    : tr('download'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasLink ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SUPPRIMER
  // ═══════════════════════════════════════════════════════

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('confirm_delete')),
        content: Text(
          widget.moduleType == 'courses'
              ? AppTranslations.isArabic
                    ? 'حذف هذا الدرس ؟'
                    : 'Supprimer ce cours ?'
              : AppTranslations.isArabic
              ? 'حذف هذا التصحيح ؟'
              : 'Supprimer ce corrigé ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _items.removeAt(index));
              await _saveItems();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              tr('delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isCourses = widget.moduleType == 'courses';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.moduleTitle} - ${_getTrimestreTranslated(widget.trimestre)}',
        ),
        backgroundColor: widget.moduleColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: widget.moduleColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: widget.moduleColor.withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.moduleColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.cycle} • ${widget.level}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCourses
                                    ? Icons.menu_book_rounded
                                    : Icons.assignment_rounded,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isCourses
                                    ? tr('no_courses')
                                    : tr('no_corrections'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final hasFile = item['fileBase64'] != null;
                            final hasLink =
                                (item['link']?.toString() ?? '').isNotEmpty;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                onTap: () => _showDetail(item),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: widget.moduleColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    hasLink
                                        ? Icons.link
                                        : hasFile
                                        ? Icons.picture_as_pdf
                                        : (isCourses
                                              ? Icons.menu_book
                                              : Icons.assignment),
                                    color: hasLink
                                        ? Colors.blue
                                        : hasFile
                                        ? Colors.red
                                        : widget.moduleColor,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((item['description'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Text(
                                        item['description'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['date'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (hasFile) ...[
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.attach_file,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            ' ${item['fileName']}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                        if (hasLink) ...[
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.link,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          const Text(
                                            ' Drive',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasFile || hasLink)
                                      IconButton(
                                        onPressed: () => _openFile(item),
                                        icon: Icon(
                                          hasLink
                                              ? Icons.open_in_new
                                              : Icons.download,
                                          color: hasLink
                                              ? Colors.blue
                                              : Colors.green,
                                          size: 20,
                                        ),
                                        tooltip: hasLink
                                            ? 'Ouvrir'
                                            : tr('download'),
                                      ),
                                    if (!widget.isReadOnly)
                                      IconButton(
                                        onPressed: () =>
                                            _showDeleteDialog(index),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
