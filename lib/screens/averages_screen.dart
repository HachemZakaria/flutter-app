import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class AveragesScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;

  const AveragesScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  @override
  State<AveragesScreen> createState() => _AveragesScreenState();
}

class _AveragesScreenState extends State<AveragesScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic> _allGrades = {};
  bool _isLoading = true;
  late TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadStudents();
    await _loadGrades();
    setState(() => _isLoading = false);
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

  double? _getSubjectAverage(
    String studentName,
    String subject,
    String trimestre,
  ) {
    final key = '${widget.className}_$subject';
    final classGrades = _allGrades[key];
    if (classGrades == null) return null;

    final studentGrades = classGrades[studentName];
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

  String _getMention(double average) {
    if (average >= 16) return tr('very_good');
    if (average >= 14) return tr('good');
    if (average >= 12) return tr('fairly_good');
    if (average >= 10) return tr('pass');
    return tr('insufficient');
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.amber.shade700;
    return Colors.red;
  }

  List<Map<String, dynamic>> _getRankedStudents(String trimestre) {
    List<Map<String, dynamic>> ranked = [];

    for (var student in _students) {
      final name = '${student['prenom']} ${student['nom']}';
      final avg = _getGeneralAverage(name, trimestre);
      ranked.add({'student': student, 'name': name, 'average': avg});
    }

    ranked.sort((a, b) {
      if (a['average'] == null && b['average'] == null) return 0;
      if (a['average'] == null) return 1;
      if (b['average'] == null) return -1;
      return (b['average'] as double).compareTo(a['average'] as double);
    });

    return ranked;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('average')} - ${widget.className}'),
        backgroundColor: _color,
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
          : _students.isEmpty
          ? Center(
              child: Text(
                tr('no_students'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _trimestres
                  .map((trimestre) => _buildTrimestreTab(trimestre))
                  .toList(),
            ),
    );
  }

  Widget _buildTrimestreTab(String trimestre) {
    final ranked = _getRankedStudents(trimestre);

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        final item = ranked[index];
        final studentName = item['name'] as String;
        final average = item['average'] as double?;
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? Colors.amber.withOpacity(0.2)
                            : _color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: rank <= 3 ? 16 : 14,
                            color: rank <= 3 ? null : _color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: average != null
                            ? _getGradeColor(average).withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: average != null
                              ? _getGradeColor(average).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        average != null ? average.toStringAsFixed(2) : '--',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: average != null
                              ? _getGradeColor(average)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                if (average != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _getMention(average),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getGradeColor(average),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
