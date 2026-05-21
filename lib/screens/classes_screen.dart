import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'class_students_screen.dart';

class ClassesScreen extends StatefulWidget {
  final String cycle;
  final String level;

  const ClassesScreen({super.key, required this.cycle, required this.level});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  Map<String, int> _studentCounts = {};

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadStudentCounts();
  }

  Future<void> _loadStudentCounts() async {
    try {
      final allStudents = await FirebaseService.loadStudentsByCycle(
        widget.cycle,
      );
      Map<String, int> counts = {};
      for (var student in allStudents) {
        final className = student['className'] as String? ?? '';
        counts[className] = (counts[className] ?? 0) + 1;
      }
      if (mounted) {
        setState(() {
          _studentCounts = counts;
        });
      }
    } catch (e) {
      debugPrint('❌ _loadStudentCounts error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = SchoolData.getClassesForLevel(widget.level);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr('classes')} - ${widget.level}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(tr('choose_class'), style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final className = classes[index];
                  final count = _studentCounts[className] ?? 0;

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassStudentsScreen(
                            cycle: widget.cycle,
                            level: widget.level,
                            className: className,
                          ),
                        ),
                      );
                      //_loadStudentCounts(); // Rafraîchir
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _color.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: _color.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.class_, color: _color, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            className,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count ${tr('students_count')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
      ),
    );
  }
}
