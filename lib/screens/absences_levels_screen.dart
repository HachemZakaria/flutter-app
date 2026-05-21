import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'absences_classes_screen.dart';
import 'attendance_screen.dart';
import 'branches_screen.dart';

class AbsencesLevelsScreen extends StatelessWidget {
  final String cycle;

  const AbsencesLevelsScreen({super.key, required this.cycle});

  Color get _color => Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);

  String _getCycleTranslated(String cycle) {
    switch (cycle) {
      case 'Préparatoire':
        return tr('preparatoire');
      case 'Primaire':
        return tr('primaire');
      case 'CEM':
        return tr('cem');
      case 'Lycée':
        return tr('lycee');
      default:
        return cycle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = SchoolData.levelsByCycle[cycle]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('absences')} - ${_getCycleTranslated(cycle)}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final hasBranches = SchoolData.hasBranches(level);

            return GestureDetector(
              onTap: () {
                if (hasBranches) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BranchesScreen(
                        cycle: cycle,
                        level: level,
                        classScreenBuilder: (cycle, level, className) {
                          // ✅ Ouvre directement l'écran d'absences de la classe
                          return AttendanceScreen(
                            cycle: cycle,
                            level: level,
                            className: className,
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AbsencesClassesScreen(cycle: cycle, level: level),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _color,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    level,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    hasBranches
                        ? '${SchoolData.getBranchesForLevel(level).length} ${tr('branches').toLowerCase()}'
                        : '${SchoolData.getClassesForLevel(level).length} ${tr('classes').toLowerCase()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(
                    AppTranslations.isArabic
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: _color,
                    size: 18,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
