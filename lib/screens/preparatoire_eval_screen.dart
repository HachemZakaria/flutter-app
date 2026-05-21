import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class PreparatoireEvalScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;
  final String subject;

  const PreparatoireEvalScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
    required this.subject,
  });

  @override
  State<PreparatoireEvalScreen> createState() => _PreparatoireEvalScreenState();
}

class _PreparatoireEvalScreenState extends State<PreparatoireEvalScreen> {
  List<Map<String, dynamic>> _students = [];
  Map<String, Map<String, String>> _evaluations = {};
  bool _isLoading = true;

  List<String> get _competences =>
      SchoolData.getCompetencesForSubject(widget.subject);

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadStudents();
    await _loadEvaluations();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    try {
      final all = await FirebaseService.loadAllStudents();
      _students = all.where((s) => s['className'] == widget.className).toList();
    } catch (e) {}
  }

  Future<void> _loadEvaluations() async {
    try {
      final key = 'prep_${widget.className}_${widget.subject}';
      final data = await FirebaseService.loadGradesForClass(key);
      data.forEach((studentName, compData) {
        _evaluations[studentName] = {};
        (compData as Map<String, dynamic>).forEach((comp, value) {
          _evaluations[studentName]![comp] = value.toString();
        });
      });
    } catch (e) {}
  }

  Future<void> _saveEvaluations() async {
    try {
      final key = 'prep_${widget.className}_${widget.subject}';
      await FirebaseService.saveGrades(key, _evaluations);
    } catch (e) {}
  }

  String _getEvaluation(String studentName, String competence) {
    return _evaluations[studentName]?[competence] ?? '';
  }

  void _setEvaluation(String studentName, String competence, String value) {
    setState(() {
      _evaluations[studentName] ??= {};
      _evaluations[studentName]![competence] = value;
    });
    _saveEvaluations();
  }

  Map<String, int> _getStudentSummary(String studentName) {
    int a = 0, eca = 0, na = 0;
    for (var comp in _competences) {
      final val = _getEvaluation(studentName, comp);
      if (val == 'A')
        a++;
      else if (val == 'ECA')
        eca++;
      else if (val == 'NA')
        na++;
    }
    return {'A': a, 'ECA': eca, 'NA': na};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
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
                      Expanded(
                        child: Text(
                          widget.subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppTranslations.isArabic
                              ? 'تقييم بالكفاءات'
                              : 'Compétences',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendChip(
                        'A',
                        AppTranslations.isArabic ? 'مكتسب' : 'Acquis',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _legendChip(
                        'ECA',
                        AppTranslations.isArabic ? 'في طور' : 'En cours',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _legendChip(
                        'NA',
                        AppTranslations.isArabic ? 'غير مكتسب' : 'Non acquis',
                        Colors.red,
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
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final studentName =
                                '${student['prenom']} ${student['nom']}';
                            final summary = _getStudentSummary(studentName);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
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
                                title: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    _miniChip(
                                      '🟢 ${summary['A']}',
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    _miniChip(
                                      '🟡 ${summary['ECA']}',
                                      Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    _miniChip(
                                      '🔴 ${summary['NA']}',
                                      Colors.red,
                                    ),
                                  ],
                                ),
                                children: [
                                  const Divider(height: 1),
                                  ..._competences.map((comp) {
                                    final currentVal = _getEvaluation(
                                      studentName,
                                      comp,
                                    );

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              comp,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          _evalButton(
                                            studentName,
                                            comp,
                                            'A',
                                            Colors.green,
                                            currentVal,
                                          ),
                                          const SizedBox(width: 4),
                                          _evalButton(
                                            studentName,
                                            comp,
                                            'ECA',
                                            Colors.orange,
                                            currentVal,
                                          ),
                                          const SizedBox(width: 4),
                                          _evalButton(
                                            studentName,
                                            comp,
                                            'NA',
                                            Colors.red,
                                            currentVal,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _legendChip(String code, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ✅ Avec possibilité de décocher
  Widget _evalButton(
    String studentName,
    String comp,
    String value,
    Color color,
    String currentVal,
  ) {
    final isSelected = currentVal == value;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // ✅ Décocher
          _setEvaluation(studentName, comp, '');
        } else {
          // ✅ Cocher
          _setEvaluation(studentName, comp, value);
        }
      },
      child: Container(
        width: 36,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
