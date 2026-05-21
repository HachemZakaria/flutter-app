import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'grades_subjects_screen.dart';

class GradesClassesScreen extends StatelessWidget {
  final String cycle;
  final String level;
  final String? branch;

  const GradesClassesScreen({
    super.key,
    required this.cycle,
    required this.level,
    this.branch,
  });

  Color get _color => Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final classes = branch != null
        ? SchoolData.getClassesForBranch(level, branch!)
        : SchoolData.getClassesForLevel(level);

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('grades')} - ${branch ?? level}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GradesSubjectsScreen(
                      cycle: cycle,
                      level: level,
                      className: className,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: _color.withOpacity(0.1), blurRadius: 8),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        className,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _color,
                        ),
                        textAlign: TextAlign.center,
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
