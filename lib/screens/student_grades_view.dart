import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class StudentGradesView extends StatefulWidget {
  final String studentName;
  final String className;
  final String level;
  final String cycle;

  const StudentGradesView({
    super.key,
    required this.studentName,
    required this.className,
    required this.level,
    required this.cycle,
  });

  @override
  State<StudentGradesView> createState() => _StudentGradesViewState();
}

class _StudentGradesViewState extends State<StudentGradesView>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> _allGrades = {};
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _trimestres = [
    'Trimestre 1',
    'Trimestre 2',
    'Trimestre 3',
  ];

  List<String> get _subjects => SchoolData.getSubjectsForLevel(widget.level);

  String _getSubjectTranslated(String subject) {
    switch (subject) {
      case 'Arabe':
        return tr('arabe');
      case 'Français':
        return tr('francais');
      case 'Anglais':
        return tr('anglais');
      case 'Mathématiques':
        return tr('maths');
      case 'Sciences physiques':
        return tr('sciences_physiques');
      case 'Sciences naturelles':
        return tr('sciences_naturelles');
      case 'Philosophie':
        return tr('philosophie');
      case 'Histoire':
        return tr('histoire');
      case 'Géographie':
        return tr('geographie');
      case 'Éducation islamique':
        return tr('islamique');
      case 'Éducation civique':
        return tr('civique');
      case 'Informatique':
        return tr('informatique');
      case 'Éducation physique':
        return tr('sport');
      case 'Éveil scientifique':
        return tr('eveil_scientifique');
      case 'Dessin':
        return tr('dessin');
      case 'Histoire-Géographie':
        return tr('histoire_geo');
      case 'Éducation scientifique':
        return tr('education_scientifique');
      case 'Éducation artistique':
        return tr('education_artistique');
      default:
        return subject;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGrades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGrades() async {
    try {
      _allGrades = await FirebaseService.loadGradesForClassName(
        widget.className,
      );
    } catch (e) {
      debugPrint('❌ _loadGrades error: $e');
      _allGrades = {};
    }
    if (mounted) setState(() => _isLoading = false);
  }

  double? _getSubjectAverage(String subject, String trimestre) {
    final key = '${widget.className}_$subject';
    final classGrades = _allGrades[key];
    if (classGrades == null) return null;

    final studentGrades = classGrades[widget.studentName];
    if (studentGrades == null) return null;

    final trimestreGrades = studentGrades[trimestre];
    if (trimestreGrades == null) return null;

    final d1 = trimestreGrades['Devoir 1'] != null
        ? (trimestreGrades['Devoir 1'] as num).toDouble()
        : null;
    final d2 = trimestreGrades['Devoir 2'] != null
        ? (trimestreGrades['Devoir 2'] as num).toDouble()
        : null;
    final exam = trimestreGrades['Examen'] != null
        ? (trimestreGrades['Examen'] as num).toDouble()
        : null;

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

  Map<String, double?> _getNotes(String subject, String trimestre) {
    final key = '${widget.className}_$subject';
    final classGrades = _allGrades[key];
    if (classGrades == null) return {};

    final studentGrades = classGrades[widget.studentName];
    if (studentGrades == null) return {};

    final trimestreGrades = studentGrades[trimestre];
    if (trimestreGrades == null) return {};

    return {
      'Devoir 1': trimestreGrades['Devoir 1'] != null
          ? (trimestreGrades['Devoir 1'] as num).toDouble()
          : null,
      'Devoir 2': trimestreGrades['Devoir 2'] != null
          ? (trimestreGrades['Devoir 2'] as num).toDouble()
          : null,
      'Examen': trimestreGrades['Examen'] != null
          ? (trimestreGrades['Examen'] as num).toDouble()
          : null,
    };
  }

  double? _getGeneralAverage(String trimestre) {
    double total = 0;
    int count = 0;
    for (var subject in _subjects) {
      final avg = _getSubjectAverage(subject, trimestre);
      if (avg != null) {
        total += avg;
        count++;
      }
    }
    if (count == 0) return null;
    return total / count;
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.amber.shade700;
    return Colors.red;
  }

  String _getMention(double avg) {
    if (avg >= 16) return '⭐ ${tr('very_good')}';
    if (avg >= 14) return '👏 ${tr('good')}';
    if (avg >= 12) return '👍 ${tr('fairly_good')}';
    if (avg >= 10) return '✅ ${tr('pass')}';
    return '❌ ${tr('insufficient')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_grades')),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: tr('trimester_1')),
            Tab(text: tr('trimester_2')),
            Tab(text: tr('trimester_3')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _trimestres.map((t) => _buildTrimestreView(t)).toList(),
            ),
    );
  }

  Widget _buildTrimestreView(String trimestre) {
    final generalAvg = _getGeneralAverage(trimestre);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: generalAvg != null
                  ? _getGradeColor(generalAvg).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: generalAvg != null
                    ? _getGradeColor(generalAvg).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr('general_average'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  generalAvg != null ? generalAvg.toStringAsFixed(2) : '--',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: generalAvg != null
                        ? _getGradeColor(generalAvg)
                        : Colors.grey,
                  ),
                ),
                if (generalAvg != null)
                  Text(
                    _getMention(generalAvg),
                    style: TextStyle(
                      color: _getGradeColor(generalAvg),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._subjects.map((subject) {
            final notes = _getNotes(subject, trimestre);
            final avg = _getSubjectAverage(subject, trimestre);

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
                        Expanded(
                          child: Text(
                            _getSubjectTranslated(subject),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: avg != null
                                ? _getGradeColor(avg).withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            avg != null ? avg.toStringAsFixed(2) : '--',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: avg != null
                                  ? _getGradeColor(avg)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _noteChip(tr('devoir_1'), notes['Devoir 1']),
                        const SizedBox(width: 8),
                        _noteChip(tr('devoir_2'), notes['Devoir 2']),
                        const SizedBox(width: 8),
                        _noteChip(tr('exam'), notes['Examen']),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _noteChip(String label, double? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: value != null
              ? _getGradeColor(value).withOpacity(0.08)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value != null
                ? _getGradeColor(value).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value != null ? value.toStringAsFixed(1) : '--',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: value != null ? _getGradeColor(value) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
