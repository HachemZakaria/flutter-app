import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'student_payments_screen.dart';

class PaymentsClassesScreen extends StatefulWidget {
  final String cycle;
  final String level;

  const PaymentsClassesScreen({
    super.key,
    required this.cycle,
    required this.level,
  });

  @override
  State<PaymentsClassesScreen> createState() => _PaymentsClassesScreenState();
}

class _PaymentsClassesScreenState extends State<PaymentsClassesScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final students = await FirebaseService.loadStudentsByCycle(widget.cycle);
      setState(() => _allStudents = students);
    } catch (e) {
      debugPrint('❌ _loadData error: $e');
    }
    setState(() => _isLoading = false);
  }

  int _getStudentCount(String className) {
    return _allStudents.where((s) => s['className'] == className).length;
  }

  @override
  Widget build(BuildContext context) {
    final classes = SchoolData.getClassesForLevel(widget.level);

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('payments')} - ${widget.level}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final className = classes[index];
                  final studentCount = _getStudentCount(className);

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentPaymentsScreen(
                            cycle: widget.cycle,
                            level: widget.level,
                            className: className,
                          ),
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
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
                            '$studentCount ${tr('students_count')}',
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
    );
  }
}
