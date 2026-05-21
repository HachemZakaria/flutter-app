import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = true;

  final _studentController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  // ─── Charger ─────────────────────────────────────────
  Future<void> _loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('grades_data');

    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _grades = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─── Sauvegarder ────────────────────────────────────
  Future<void> _saveGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_grades);
    await prefs.setString('grades_data', data);
  }

  // ─── Ajouter ────────────────────────────────────────
  Future<void> _addGrade() async {
    if (_studentController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _gradeController.text.isEmpty)
      return;

    final grade = double.tryParse(_gradeController.text);
    if (grade == null || grade < 0 || grade > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La note doit être entre 0 et 20'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _grades.add({
        'student': _studentController.text.trim(),
        'subject': _subjectController.text.trim(),
        'grade': grade,
      });
    });

    await _saveGrades();

    _studentController.clear();
    _subjectController.clear();
    _gradeController.clear();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ─── Supprimer ──────────────────────────────────────
  Future<void> _deleteGrade(int index) async {
    setState(() {
      _grades.removeAt(index);
    });
    await _saveGrades();
  }

  // ─── Couleur selon la note ──────────────────────────
  Color _getGradeColor(double grade) {
    if (grade >= 16) return Colors.green;
    if (grade >= 12) return Colors.orange;
    if (grade >= 10) return Colors.amber;
    return Colors.red;
  }

  // ─── Mention ────────────────────────────────────────
  String _getMention(double grade) {
    if (grade >= 16) return 'Très bien';
    if (grade >= 14) return 'Bien';
    if (grade >= 12) return 'Assez bien';
    if (grade >= 10) return 'Passable';
    return 'Insuffisant';
  }

  // ─── Dialog Ajouter ─────────────────────────────────
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _studentController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'élève',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Matière',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gradeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Note /20',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _addGrade,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _studentController.dispose();
    _subjectController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes des Élèves'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grade_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune note',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Appuyez sur + pour ajouter une note',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final item = _grades[index];
                final grade = (item['grade'] as num).toDouble();

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getGradeColor(grade).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          grade.toStringAsFixed(1),
                          style: TextStyle(
                            color: _getGradeColor(grade),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      item['student'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Text(item['subject'] as String),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(grade).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getMention(grade),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getGradeColor(grade),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${grade.toStringAsFixed(1)}/20',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(grade),
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: grade / 20,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getGradeColor(grade),
                            ),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                    onLongPress: () => _deleteGrade(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
