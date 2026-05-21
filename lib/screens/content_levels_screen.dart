import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'content_subjects_screen.dart';
import 'branches_screen.dart';

class ContentLevelsEntryScreen extends StatelessWidget {
  final String moduleType;
  final String moduleTitle;
  final Color moduleColor;
  final IconData moduleIcon;

  const ContentLevelsEntryScreen({
    super.key,
    required this.moduleType,
    required this.moduleTitle,
    required this.moduleColor,
    required this.moduleIcon,
  });

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
    // ✅ Exclure le Préparatoire
    final filteredCycles = SchoolData.cycles
        .where((c) => c != 'Préparatoire')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(moduleTitle),
        backgroundColor: moduleColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: filteredCycles.length,
          itemBuilder: (context, index) {
            final cycle = filteredCycles[index];
            final color = Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ContentLevelsListScreen(
                      moduleType: moduleType,
                      moduleTitle: moduleTitle,
                      moduleColor: moduleColor,
                      cycle: cycle,
                    ),
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

class _ContentLevelsListScreen extends StatelessWidget {
  final String moduleType;
  final String moduleTitle;
  final Color moduleColor;
  final String cycle;

  const _ContentLevelsListScreen({
    required this.moduleType,
    required this.moduleTitle,
    required this.moduleColor,
    required this.cycle,
  });

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
        title: Text('$moduleTitle - ${_getCycleTranslated(cycle)}'),
        backgroundColor: moduleColor,
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
                          return ContentSubjectsScreen(
                            moduleType: moduleType,
                            moduleTitle: moduleTitle,
                            moduleColor: moduleColor,
                            cycle: cycle,
                            level: level,
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContentSubjectsScreen(
                        moduleType: moduleType,
                        moduleTitle: moduleTitle,
                        moduleColor: moduleColor,
                        cycle: cycle,
                        level: level,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: moduleColor.withOpacity(0.3)),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: moduleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: moduleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    level,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                    color: moduleColor,
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
