import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'content_trimestres_screen.dart';

class ContentSubjectsScreen extends StatelessWidget {
  final String moduleType;
  final String moduleTitle;
  final Color moduleColor;
  final String cycle;
  final String level;
  final bool isReadOnly;

  const ContentSubjectsScreen({
    super.key,
    required this.moduleType,
    required this.moduleTitle,
    required this.moduleColor,
    required this.cycle,
    required this.level,
    this.isReadOnly = false,
  });

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Arabe':
        return Icons.translate;
      case 'Français':
      case 'Anglais':
        return Icons.language;
      case 'Mathématiques':
        return Icons.calculate;
      case 'Sciences physiques':
        return Icons.science;
      case 'Sciences naturelles':
        return Icons.eco;
      case 'Histoire':
        return Icons.history_edu;
      case 'Géographie':
        return Icons.map;
      case 'Informatique':
        return Icons.computer;
      case 'Éducation physique':
        return Icons.sports_soccer;
      case 'Philosophie':
        return Icons.psychology;
      default:
        return Icons.book;
    }
  }

  String _getSubjectTranslated(String subject) {
    switch (subject) {
      case 'Arabe':
        return tr('arabe');
      case 'Français':
        return tr('francais');
      case 'Anglais':
        return tr('anglais');
      case 'Mathématiques':
        return tr('maths');
      case 'Sciences physiques':
        return tr('sciences_physiques');
      case 'Sciences naturelles':
        return tr('sciences_naturelles');
      case 'Philosophie':
        return tr('philosophie');
      case 'Histoire':
        return tr('histoire');
      case 'Géographie':
        return tr('geographie');
      case 'Éducation islamique':
        return tr('islamique');
      case 'Éducation civique':
        return tr('civique');
      case 'Informatique':
        return tr('informatique');
      case 'Éducation physique':
        return tr('sport');
      case 'Éveil scientifique':
        return tr('eveil_scientifique');
      case 'Dessin':
        return tr('dessin');
      case 'Histoire-Géographie':
        return tr('histoire_geo');
      case 'Éducation scientifique':
        return tr('education_scientifique');
      case 'Éducation artistique':
        return tr('education_artistique');
      default:
        return subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = SchoolData.getSubjectsForLevel(level);

    return Scaffold(
      appBar: AppBar(
        title: Text('$moduleTitle - $level'),
        backgroundColor: moduleColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: subjects.map((subject) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContentTrimestresScreen(
                      moduleType: moduleType,
                      moduleTitle: moduleTitle,
                      moduleColor: moduleColor,
                      cycle: cycle,
                      level: level,
                      subject: subject,
                      isReadOnly: isReadOnly,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: moduleColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: moduleColor.withOpacity(0.1),
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
                        color: moduleColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: moduleColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _getSubjectTranslated(subject),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: moduleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
