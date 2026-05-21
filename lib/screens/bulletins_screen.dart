import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class BulletinsScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;

  const BulletinsScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  @override
  State<BulletinsScreen> createState() => _BulletinsScreenState();
}

class _BulletinsScreenState extends State<BulletinsScreen> {
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic> _allGrades = {};
  Map<String, String> _appreciations = {};
  bool _isLoading = true;
  String _selectedTrimestre = 'Trimestre 1';

  final List<String> _trimestres = [
    'Trimestre 1',
    'Trimestre 2',
    'Trimestre 3',
  ];

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  List<String> get _subjects => SchoolData.getSubjectsForLevel(widget.level);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await FirebaseService.loadStudentsByClass(
        widget.className,
      );
      setState(() => _students = students);
    } catch (e) {
      debugPrint('❌ error: $e');
    }
  }

  Future<void> _loadGrades() async {
    try {
      final grades = await FirebaseService.loadGradesForClassName(
        widget.className,
      );
      setState(() => _allGrades = grades);
    } catch (e) {
      debugPrint('❌ error: $e');
    }
  }

  Future<void> _loadData() async {
    await _loadStudents();
    await _loadGrades();
    await _loadAppreciations();
    setState(() => _isLoading = false);
  }

  Future<void> _loadAppreciations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('appreciations_data');
    if (data != null) {
      final decoded = jsonDecode(data);
      _appreciations = Map<String, String>.from(decoded);
    }
  }

  Future<void> _saveAppreciations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appreciations_data', jsonEncode(_appreciations));
  }

  Map<String, double?> _getStudentNotes(
    String studentName,
    String subject,
    String trimestre,
  ) {
    final key = '${widget.className}_$subject';
    final classGrades = _allGrades[key];
    if (classGrades == null) return {'d1': null, 'd2': null, 'exam': null};

    final studentGrades = classGrades[studentName];
    if (studentGrades == null) return {'d1': null, 'd2': null, 'exam': null};

    final trimestreGrades = studentGrades[trimestre];
    if (trimestreGrades == null) {
      return {'d1': null, 'd2': null, 'exam': null};
    }

    return {
      'd1': trimestreGrades['Devoir 1'] != null
          ? (trimestreGrades['Devoir 1'] as num).toDouble()
          : null,
      'd2': trimestreGrades['Devoir 2'] != null
          ? (trimestreGrades['Devoir 2'] as num).toDouble()
          : null,
      'exam': trimestreGrades['Examen'] != null
          ? (trimestreGrades['Examen'] as num).toDouble()
          : null,
    };
  }

  double? _getSubjectAverage(
    String studentName,
    String subject,
    String trimestre,
  ) {
    final notes = _getStudentNotes(studentName, subject, trimestre);
    final d1 = notes['d1'];
    final d2 = notes['d2'];
    final exam = notes['exam'];

    if (d1 == null && d2 == null && exam == null) return null;

    double total = 0;
    int count = 0;
    if (d1 != null) {
      total += d1;
      count += 1;
    }
    if (d2 != null) {
      total += d2;
      count += 1;
    }
    if (exam != null) {
      total += exam * 2;
      count += 2;
    }

    if (count == 0) return null;
    return total / count;
  }

  double? _getGeneralAverage(String studentName, String trimestre) {
    double total = 0;
    int count = 0;

    for (var subject in _subjects) {
      final avg = _getSubjectAverage(studentName, subject, trimestre);
      if (avg != null) {
        total += avg;
        count++;
      }
    }

    if (count == 0) return null;
    return total / count;
  }

  int? _getRank(String studentName, String trimestre) {
    List<Map<String, dynamic>> ranked = [];

    for (var student in _students) {
      final name = '${student['prenom']} ${student['nom']}';
      final avg = _getGeneralAverage(name, trimestre);
      ranked.add({'name': name, 'average': avg});
    }

    ranked.sort((a, b) {
      if (a['average'] == null && b['average'] == null) return 0;
      if (a['average'] == null) return 1;
      if (b['average'] == null) return -1;
      return (b['average'] as double).compareTo(a['average'] as double);
    });

    for (int i = 0; i < ranked.length; i++) {
      if (ranked[i]['name'] == studentName) return i + 1;
    }
    return null;
  }

  String _getMention(double average) {
    if (average >= 16) return 'Très Bien';
    if (average >= 14) return 'Bien';
    if (average >= 12) return 'Assez Bien';
    if (average >= 10) return 'Passable';
    return 'Insuffisant';
  }

  String _getDecision(double average) {
    if (average >= 10) return 'Admis(e)';
    return 'Non Admis(e)';
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.amber.shade700;
    return Colors.red;
  }

  String _getAppreciationKey(String studentName) {
    return '${widget.className}_${studentName}_$_selectedTrimestre';
  }

  void _showAppreciationDialog(String studentName) {
    final key = _getAppreciationKey(studentName);
    final controller = TextEditingController(text: _appreciations[key] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${tr('appreciation')} - $studentName',
          style: const TextStyle(fontSize: 14),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: tr('appreciation'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _appreciations[key] = controller.text.trim();
              });
              _saveAppreciations();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _color),
            child: Text(
              tr('save'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(Map<String, dynamic> student) async {
    final studentName = '${student['prenom']} ${student['nom']}';
    final generalAvg = _getGeneralAverage(studentName, _selectedTrimestre);
    final rank = _getRank(studentName, _selectedTrimestre);
    final appreciationKey = _getAppreciationKey(studentName);
    final appreciation = _appreciations[appreciationKey] ?? '';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DAR ENNADJAH',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'BULLETIN DE NOTES',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _selectedTrimestre,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Nom', student['nom'] ?? ''),
                      _pdfInfoRow('Prénom', student['prenom'] ?? ''),
                      _pdfInfoRow(
                        'Date de naissance',
                        student['dateNaissance'] ?? '',
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Classe', widget.className),
                      _pdfInfoRow('Cycle', widget.cycle),
                      _pdfInfoRow('Niveau', widget.level),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _pdfCell('Matière', isHeader: true),
                      _pdfCell('Devoir 1', isHeader: true),
                      _pdfCell('Devoir 2', isHeader: true),
                      _pdfCell('Examen', isHeader: true),
                      _pdfCell('Moyenne', isHeader: true),
                    ],
                  ),
                  ..._subjects.map((subject) {
                    final notes = _getStudentNotes(
                      studentName,
                      subject,
                      _selectedTrimestre,
                    );
                    final avg = _getSubjectAverage(
                      studentName,
                      subject,
                      _selectedTrimestre,
                    );

                    return pw.TableRow(
                      children: [
                        _pdfCell(subject),
                        _pdfCell(
                          notes['d1'] != null
                              ? notes['d1']!.toStringAsFixed(2)
                              : '--',
                        ),
                        _pdfCell(
                          notes['d2'] != null
                              ? notes['d2']!.toStringAsFixed(2)
                              : '--',
                        ),
                        _pdfCell(
                          notes['exam'] != null
                              ? notes['exam']!.toStringAsFixed(2)
                              : '--',
                        ),
                        _pdfCell(
                          avg != null ? avg.toStringAsFixed(2) : '--',
                          isBold: true,
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Moyenne Générale :',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          generalAvg != null
                              ? '${generalAvg.toStringAsFixed(2)} / 20'
                              : '-- / 20',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Classement :'),
                        pw.Text(
                          rank != null
                              ? '$rank / ${_students.length}'
                              : '-- / ${_students.length}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Mention :'),
                        pw.Text(
                          generalAvg != null ? _getMention(generalAvg) : '--',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Décision :'),
                        pw.Text(
                          generalAvg != null ? _getDecision(generalAvg) : '--',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (appreciation.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Appréciation :',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        appreciation,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Signature du parent'),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Cachet et signature'),
                      pw.Text('de l\'établissement'),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bulletin_${studentName}_$_selectedTrimestre',
    );
  }

  pw.Widget _pdfCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader || isBold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            '$label : ',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('bulletins')} - ${widget.className}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: _color.withOpacity(0.05),
                  child: Row(
                    children: _trimestres.map((trimestre) {
                      final isSelected = _selectedTrimestre == trimestre;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTrimestre = trimestre;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? _color : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? _color
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                trimestre == 'Trimestre 1'
                                    ? tr('trimester_1')
                                    : trimestre == 'Trimestre 2'
                                    ? tr('trimester_2')
                                    : tr('trimester_3'),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? Center(
                          child: Text(
                            tr('no_students'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final studentName =
                                '${student['prenom']} ${student['nom']}';
                            final avg = _getGeneralAverage(
                              studentName,
                              _selectedTrimestre,
                            );
                            final rank = _getRank(
                              studentName,
                              _selectedTrimestre,
                            );
                            final appKey = _getAppreciationKey(studentName);
                            final hasApp =
                                _appreciations[appKey]?.isNotEmpty == true;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
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
                                  studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: avg != null
                                                ? _getGradeColor(
                                                    avg,
                                                  ).withOpacity(0.15)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            avg != null
                                                ? '${tr('average').substring(0, 3)}: ${avg.toStringAsFixed(2)}'
                                                : '${tr('average').substring(0, 3)}: --',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: avg != null
                                                  ? _getGradeColor(avg)
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          rank != null
                                              ? '${tr('rank')}: $rank/${_students.length}'
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _showAppreciationDialog(studentName),
                                      icon: Icon(
                                        Icons.edit_note,
                                        color: hasApp
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      tooltip: tr('appreciation'),
                                    ),
                                    IconButton(
                                      onPressed: () => _generatePDF(student),
                                      icon: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                      tooltip: tr('export_pdf'),
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
