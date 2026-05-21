import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'grades_levels_screen.dart';

class GradesCyclesScreen extends StatelessWidget {
  const GradesCyclesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('grades')} - ${tr('choose_cycle')}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: SchoolData.cycles.length,
          itemBuilder: (context, index) {
            final cycle = SchoolData.cycles[index];
            final color = _getCycleColor(cycle);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GradesLevelsScreen(cycle: cycle),
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
                    child: Icon(_getCycleIcon(cycle), color: color, size: 32),
                  ),
                  title: Text(
                    _getCycleTranslated(cycle),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
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
    );
  }
}
