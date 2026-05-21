import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'levels_screen.dart';

class CyclesScreen extends StatelessWidget {
  const CyclesScreen({super.key});

  Color _getCycleColor(String cycle) {
    return Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);
  }

  IconData _getCycleIcon(String cycle) {
    switch (cycle) {
      case 'Préparatoire':
        return Icons.child_care;
      case 'Primaire':
        return Icons.menu_book;
      case 'CEM':
        return Icons.school;
      case 'Lycée':
        return Icons.science;
      default:
        return Icons.school;
    }
  }

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

  String _getCycleDescription(String cycle) {
    final levels = SchoolData.levelsByCycle[cycle]!;
    if (AppTranslations.isArabic) {
      switch (cycle) {
        case 'Préparatoire':
          return 'سنة واحدة';
        case 'Primaire':
          return '${levels.length} سنوات';
        case 'CEM':
          return '${levels.length} سنوات';
        case 'Lycée':
          return '${levels.length} سنوات';
        default:
          return '${levels.length} سنوات';
      }
    } else {
      switch (cycle) {
        case 'Préparatoire':
          return '1 année';
        case 'Primaire':
          return '${levels.length} années (1ère AP → 5ème AP)';
        case 'CEM':
          return '${levels.length} années (1ère AM → 4ème AM)';
        case 'Lycée':
          return '${levels.length} années (1ère AS → 3ème AS)';
        default:
          return '${levels.length} années';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('students_management')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('choose_cycle'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              AppTranslations.isArabic
                  ? 'اختر المرحلة لرؤية الأقسام'
                  : 'Sélectionnez le cycle pour voir les classes',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: SchoolData.cycles.length,
                itemBuilder: (context, index) {
                  final cycle = SchoolData.cycles[index];
                  final color = _getCycleColor(cycle);
                  final levels = SchoolData.levelsByCycle[cycle]!;

                  // Compter total classes
                  int totalClasses = 0;
                  for (var level in levels) {
                    totalClasses += SchoolData.getClassesForLevel(level).length;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelsScreen(cycle: cycle),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCycleIcon(cycle),
                            color: color,
                            size: 32,
                          ),
                        ),
                        title: Text(
                          _getCycleTranslated(cycle),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(_getCycleDescription(cycle)),
                            Text(
                              '$totalClasses ${tr('classes').toLowerCase()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          AppTranslations.isArabic
                              ? Icons.arrow_back_ios
                              : Icons.arrow_forward_ios,
                          color: color,
                        ),
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
