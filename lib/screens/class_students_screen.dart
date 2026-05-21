import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class ClassStudentsScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;

  const ClassStudentsScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  @override
  State<ClassStudentsScreen> createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;
  bool _isImporting = false;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateController = TextEditingController();
  final _lieuController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  List<Map<String, dynamic>> get _classStudents => _allStudents;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _isLoading = false;
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      _allStudents = await FirebaseService.loadStudentsByClass(
        widget.className,
      );
    } catch (e) {
      if (mounted) _showMessage(e.toString(), isError: true);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _addStudent() async {
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty) {
      _showMessage(tr('fill_all_fields'), isError: true);
      return;
    }

    try {
      final id = 'STU_${DateTime.now().millisecondsSinceEpoch}';
      final newStudent = {
        'studentId': id,
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'dateNaissance': _dateController.text.trim(),
        'lieuNaissance': _lieuController.text.trim(),
        'parentName': _parentNameController.text.trim(),
        'parentEmail': _parentEmailController.text.trim().toLowerCase(),
        'cycle': widget.cycle,
        'level': widget.level,
        'className': widget.className,
      };

      final firebaseId = await FirebaseService.addStudent(newStudent);
      newStudent['firebaseId'] = firebaseId;

      setState(() {
        _allStudents.add(newStudent);
      });

      _clearControllers();
      if (mounted) Navigator.pop(context);
      _showMessage(
        AppTranslations.isArabic ? '✅ تمت الإضافة' : '✅ Élève ajouté',
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _updateStudent(
    Map<String, dynamic> oldStudent,
    Map<String, dynamic> newData,
  ) async {
    try {
      final firebaseId = oldStudent['firebaseId'] as String;

      await FirebaseService.updateStudent(firebaseId, newData);

      final index = _allStudents.indexOf(oldStudent);
      if (index != -1) {
        setState(() {
          _allStudents[index] = {
            ...oldStudent,
            'nom': newData['nom'],
            'prenom': newData['prenom'],
            'dateNaissance': newData['dateNaissance'],
            'lieuNaissance': newData['lieuNaissance'],
            'parentName': newData['parentName'],
            'parentEmail': newData['parentEmail'],
          };
        });
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _deleteStudent(Map<String, dynamic> student) async {
    try {
      final firebaseId = student['firebaseId'] as String;

      await FirebaseService.deleteStudent(firebaseId);

      setState(() {
        _allStudents.remove(student);
      });
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _clearClass() async {
    try {
      await FirebaseService.clearClass(widget.className);

      setState(() {
        _allStudents.removeWhere((s) => s['className'] == widget.className);
      });

      if (mounted) {
        _showMessage(
          AppTranslations.isArabic
              ? 'تم تفريغ القسم بنجاح'
              : 'Classe vidée avec succès',
        );
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Future<void> _importCSV() async {
    try {
      setState(() => _isImporting = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null) {
        setState(() => _isImporting = false);
        return;
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        setState(() => _isImporting = false);
        return;
      }

      final content = utf8.decode(bytes);
      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        setState(() => _isImporting = false);
        _showMessage(
          AppTranslations.isArabic ? 'الملف فارغ' : 'Fichier vide',
          isError: true,
        );
        return;
      }

      int importedCount = 0;
      int errorCount = 0;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final columns = line.split(',');
        if (columns.length < 2) {
          errorCount++;
          continue;
        }

        final nom = columns[0].trim();
        final prenom = columns.length > 1 ? columns[1].trim() : '';
        final dateNaissance = columns.length > 2 ? columns[2].trim() : '';
        final lieuNaissance = columns.length > 3 ? columns[3].trim() : '';
        final parentName = columns.length > 4 ? columns[4].trim() : '';
        final parentEmail = columns.length > 5
            ? columns[5].trim().toLowerCase()
            : '';

        if (nom.isEmpty && prenom.isEmpty) {
          errorCount++;
          continue;
        }

        final exists = _allStudents.any(
          (s) =>
              s['nom']?.toString().toLowerCase() == nom.toLowerCase() &&
              s['prenom']?.toString().toLowerCase() == prenom.toLowerCase() &&
              s['className'] == widget.className,
        );

        if (!exists) {
          final newStudent = {
            'studentId':
                'STU_${DateTime.now().millisecondsSinceEpoch}_$importedCount',
            'nom': nom,
            'prenom': prenom,
            'dateNaissance': dateNaissance,
            'lieuNaissance': lieuNaissance,
            'parentName': parentName,
            'parentEmail': parentEmail,
            'cycle': widget.cycle,
            'level': widget.level,
            'className': widget.className,
          };

          final firebaseId = await FirebaseService.addStudent(newStudent);
          newStudent['firebaseId'] = firebaseId;

          _allStudents.add(newStudent);
          importedCount++;
        }
      }

      setState(() {
        _isImporting = false;
      });

      if (mounted) _showImportResult(importedCount, errorCount);
    } catch (e) {
      setState(() => _isImporting = false);
      _showMessage('${tr('error')}: $e', isError: true);
    }
  }

  Future<void> _exportPDF() async {
    if (_classStudents.isEmpty) {
      _showMessage(
        AppTranslations.isArabic
            ? 'لا يوجد تلاميذ للتصدير'
            : 'Aucun élève à exporter',
        isError: true,
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Liste des Élèves',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  '${widget.cycle} - ${widget.level}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Classe : ${widget.className}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Nombre d\'élèves : ${_classStudents.length}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _pdfCell('N°', isHeader: true),
                      _pdfCell('Nom', isHeader: true),
                      _pdfCell('Prénom', isHeader: true),
                      _pdfCell('Date de naissance', isHeader: true),
                      _pdfCell('Lieu de naissance', isHeader: true),
                    ],
                  ),
                  ..._classStudents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final student = entry.value;
                    return pw.TableRow(
                      children: [
                        _pdfCell('${index + 1}'),
                        _pdfCell(student['nom'] ?? ''),
                        _pdfCell(student['prenom'] ?? ''),
                        _pdfCell(student['dateNaissance'] ?? ''),
                        _pdfCell(student['lieuNaissance'] ?? ''),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Liste_${widget.className}',
    );
  }

  pw.Widget _pdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  void _showAddDialog() {
    _clearControllers();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${tr('add_student')} - ${widget.className}',
          style: const TextStyle(fontSize: 16),
        ),
        content: _buildStudentForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: _addStudent,
            style: ElevatedButton.styleFrom(backgroundColor: _color),
            child: Text(tr('add'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> student) {
    _nomController.text = student['nom'] ?? '';
    _prenomController.text = student['prenom'] ?? '';
    _dateController.text = student['dateNaissance'] ?? '';
    _lieuController.text = student['lieuNaissance'] ?? '';
    _parentNameController.text = student['parentName'] ?? '';
    _parentEmailController.text = student['parentEmail'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('edit_student'), style: const TextStyle(fontSize: 16)),
        content: _buildStudentForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nomController.text.isEmpty ||
                  _prenomController.text.isEmpty) {
                _showMessage(tr('fill_all_fields'), isError: true);
                return;
              }
              await _updateStudent(student, {
                'nom': _nomController.text.trim(),
                'prenom': _prenomController.text.trim(),
                'dateNaissance': _dateController.text.trim(),
                'lieuNaissance': _lieuController.text.trim(),
                'parentName': _parentNameController.text.trim(),
                'parentEmail': _parentEmailController.text.trim().toLowerCase(),
              });
              _clearControllers();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              tr('edit'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('delete')),
        content: Text(
          '${tr('delete_student')} ${student['prenom']} ${student['nom']} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteStudent(student);
              Navigator.pop(context);
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

  void _showClearClassDialog() {
    if (_classStudents.isEmpty) {
      _showMessage(
        AppTranslations.isArabic
            ? 'القسم فارغ بالفعل'
            : 'La classe est déjà vide',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(tr('warning')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.isArabic
                  ? 'هل تريد تفريغ القسم ${widget.className} ؟'
                  : 'Voulez-vous vider la classe ${widget.className} ?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_classStudents.length} ${AppTranslations.isArabic ? "تلميذ سيتم حذفهم" : "élève(s) seront supprimés"}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearClass();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              AppTranslations.isArabic ? 'نعم، تفريغ' : 'Oui, vider',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _color,
              child: Text(
                (student['prenom'] as String).substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${student['prenom']} ${student['nom']}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow(
              Icons.person,
              tr('student_name'),
              '${student['prenom']} ${student['nom']}',
            ),
            _detailRow(
              Icons.calendar_today,
              tr('birth_date'),
              student['dateNaissance']?.toString().isNotEmpty == true
                  ? student['dateNaissance']
                  : '-',
            ),
            _detailRow(
              Icons.location_city,
              tr('birth_place'),
              student['lieuNaissance']?.toString().isNotEmpty == true
                  ? student['lieuNaissance']
                  : '-',
            ),
            _detailRow(
              Icons.family_restroom,
              AppTranslations.isArabic ? 'اسم الولي' : 'Nom du parent',
              student['parentName']?.toString().isNotEmpty == true
                  ? student['parentName']
                  : '-',
            ),
            _detailRow(
              Icons.email,
              AppTranslations.isArabic ? 'بريد الولي' : 'Email du parent',
              student['parentEmail']?.toString().isNotEmpty == true
                  ? student['parentEmail']
                  : '-',
            ),
            _detailRow(Icons.class_, tr('class_'), widget.className),
            _detailRow(
              Icons.school,
              tr('cycle'),
              '${widget.cycle} - ${widget.level}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomController,
            decoration: InputDecoration(
              labelText: '${tr('last_name')} *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prenomController,
            decoration: InputDecoration(
              labelText: '${tr('first_name')} *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: tr('birth_date'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              hintText: '15/03/2012',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lieuController,
            decoration: InputDecoration(
              labelText: tr('birth_place'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_city),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _parentNameController,
            decoration: InputDecoration(
              labelText: AppTranslations.isArabic
                  ? 'اسم الولي'
                  : 'Nom du parent',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.family_restroom),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _parentEmailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: AppTranslations.isArabic
                  ? 'بريد الولي'
                  : 'Email du parent',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
              hintText: 'parent@email.com',
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _nomController.clear();
    _prenomController.clear();
    _dateController.clear();
    _lieuController.clear();
    _parentNameController.clear();
    _parentEmailController.clear();
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showImportResult(int imported, int errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              imported > 0 ? Icons.check_circle : Icons.warning,
              color: imported > 0 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic ? 'نتيجة الاستيراد' : 'Résultat Import',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$imported ${AppTranslations.isArabic ? "تلميذ تم استيرادهم" : "élève(s) importé(s)"}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (errors > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$errors ${AppTranslations.isArabic ? "سطر تم تجاهله" : "ligne(s) ignorée(s)"}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: _color),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateController.dispose();
    _lieuController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isImporting ? null : _importCSV,
            icon: _isImporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.upload_file),
            tooltip: tr('import_csv'),
          ),
          IconButton(
            onPressed: _exportPDF,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: tr('export_pdf'),
          ),
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.person_add),
            tooltip: tr('add_student'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') _showClearClassDialog();
              if (value == 'refresh') _loadStudents();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(AppTranslations.isArabic ? 'تحديث' : 'Actualiser'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      tr('empty_class'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: _color.withOpacity(0.05),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.cycle,
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.level,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${_classStudents.length} ${tr('students_count')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_classStudents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _isImporting ? null : _importCSV,
                      icon: const Icon(Icons.upload_file),
                      label: Text(tr('import_csv')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _classStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tr('no_students'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _classStudents.length,
                          itemBuilder: (context, index) {
                            final student = _classStudents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () => _showStudentDetail(student),
                                leading: CircleAvatar(
                                  backgroundColor: _color,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${student['prenom']} ${student['nom']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  student['dateNaissance']
                                              ?.toString()
                                              .isNotEmpty ==
                                          true
                                      ? '📅 ${student['dateNaissance']}  📍 ${student['lieuNaissance']}'
                                      : '-',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      tooltip: tr('edit'),
                                      onPressed: () => _showEditDialog(student),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      tooltip: tr('delete'),
                                      onPressed: () =>
                                          _showDeleteDialog(student),
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
