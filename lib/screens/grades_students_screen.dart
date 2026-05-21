import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'preparatoire_eval_screen.dart';

class GradesStudentsScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;
  final String subject;

  const GradesStudentsScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
    required this.subject,
  });

  @override
  State<GradesStudentsScreen> createState() => _GradesStudentsScreenState();
}

class _GradesStudentsScreenState extends State<GradesStudentsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _students = [];
  Map<String, Map<String, Map<String, double?>>> _grades = {};
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _trimestres = [
    'Trimestre 1',
    'Trimestre 2',
    'Trimestre 3',
  ];
  final List<String> _noteTypes = ['Devoir 1', 'Devoir 2', 'Examen'];

  double get _maxNote => SchoolData.getMaxNote(widget.level);
  bool get _isPreparatoire => SchoolData.isPreparatoire(widget.level);

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

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

  String _getNoteTypeTranslated(String type) {
    switch (type) {
      case 'Devoir 1':
        return tr('devoir_1');
      case 'Devoir 2':
        return tr('devoir_2');
      case 'Examen':
        return tr('exam');
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // ✅ Si Préparatoire, rediriger vers l'écran d'évaluation
    if (_isPreparatoire) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PreparatoireEvalScreen(
              cycle: widget.cycle,
              level: widget.level,
              className: widget.className,
              subject: widget.subject,
            ),
          ),
        );
      });
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await _loadStudents();
    await _loadGrades();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    try {
      final all = await FirebaseService.loadAllStudents();
      _students = all.where((s) => s['className'] == widget.className).toList();
    } catch (e) {}
  }

  Future<void> _loadGrades() async {
    try {
      final key = '${widget.className}_${widget.subject}';
      final classGrades = await FirebaseService.loadGradesForClass(key);
      classGrades.forEach((studentName, trimestreData) {
        _grades[studentName] = {};
        (trimestreData as Map<String, dynamic>).forEach((trimestre, notes) {
          _grades[studentName]![trimestre] = {};
          (notes as Map<String, dynamic>).forEach((noteType, value) {
            _grades[studentName]![trimestre]![noteType] = value != null
                ? (value as num).toDouble()
                : null;
          });
        });
      });
    } catch (e) {}
  }

  Future<void> _saveGrades() async {
    try {
      final key = '${widget.className}_${widget.subject}';
      await FirebaseService.saveGrades(key, _grades);
    } catch (e) {}
  }

  double? _calculateAverage(String studentName, String trimestre) {
    final notes = _grades[studentName]?[trimestre];
    if (notes == null) return null;
    final d1 = notes['Devoir 1'];
    final d2 = notes['Devoir 2'];
    final exam = notes['Examen'];
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

  void _showGradeInput(String studentName, String trimestre, String noteType) {
    final controller = TextEditingController();
    final currentGrade = _grades[studentName]?[trimestre]?[noteType];
    if (currentGrade != null) controller.text = currentGrade.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getNoteTypeTranslated(noteType),
          style: const TextStyle(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: TextStyle(fontWeight: FontWeight.bold, color: _color),
            ),
            Text(
              '${widget.subject} - ${_getTrimestreTranslated(trimestre)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText:
                    '${AppTranslations.isArabic ? "العلامة" : "Note"} /${_maxNote.toInt()}',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade, color: _color),
                suffixText: '/${_maxNote.toInt()}',
              ),
            ),
          ],
        ),
        actions: [
          if (currentGrade != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _grades[studentName]?[trimestre]?.remove(noteType);
                });
                _saveGrades();
                Navigator.pop(context);
              },
              child: Text(
                tr('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value == null || value < 0 || value > _maxNote) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppTranslations.isArabic
                          ? 'العلامة بين 0 و ${_maxNote.toInt()}'
                          : 'Note entre 0 et ${_maxNote.toInt()}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() {
                _grades[studentName] ??= {};
                _grades[studentName]![trimestre] ??= {};
                _grades[studentName]![trimestre]![noteType] = value;
              });
              _saveGrades();
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

  Color _getGradeColor(double grade) {
    final ratio = grade / _maxNote;
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.6) return Colors.orange;
    if (ratio >= 0.5) return Colors.amber.shade700;
    return Colors.red;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreparatoire)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
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
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: _color.withOpacity(0.05),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.className,
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '/${_maxNote.toInt()}',
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_students.length} ${tr('students_count')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                      : TabBarView(
                          controller: _tabController,
                          children: _trimestres
                              .map((t) => _buildTrimestreTab(t))
                              .toList(),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrimestreTab(String trimestre) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final studentName = '${student['prenom']} ${student['nom']}';
        final average = _calculateAverage(studentName, trimestre);

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
                    CircleAvatar(
                      backgroundColor: _color,
                      radius: 18,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: average != null
                            ? _getGradeColor(average).withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        average != null
                            ? '${average.toStringAsFixed(2)}/${_maxNote.toInt()}'
                            : '--/${_maxNote.toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: average != null
                              ? _getGradeColor(average)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: _noteTypes.map((noteType) {
                    final grade = _grades[studentName]?[trimestre]?[noteType];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _showGradeInput(studentName, trimestre, noteType),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: grade != null
                                ? _getGradeColor(grade).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: grade != null
                                  ? _getGradeColor(grade).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getNoteTypeTranslated(noteType),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                grade != null ? grade.toStringAsFixed(1) : '--',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: grade != null
                                      ? _getGradeColor(grade)
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                '/${_maxNote.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
