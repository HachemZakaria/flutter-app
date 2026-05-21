import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import 'grades_students_screen.dart';
import 'averages_screen.dart';
import 'bulletins_screen.dart';

class GradesSubjectsScreen extends StatelessWidget {
  final String cycle;
  final String level;
  final String className;

  const GradesSubjectsScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  Color get _color => Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);

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
      case 'Histoire-Géographie':
        return Icons.history_edu;
      case 'Géographie':
        return Icons.map;
      case 'Éducation islamique':
      case 'Éducation islamique et Sociale':
        return Icons.auto_stories;
      case 'Éducation civique':
        return Icons.balance;
      case 'Informatique':
        return Icons.computer;
      case 'Éducation physique':
      case 'Activités Psychomotrices':
        return Icons.sports_soccer;
      case 'Philosophie':
        return Icons.psychology;
      case 'Langage et Communication':
        return Icons.record_voice_over;
      case 'Éveil Scientifique et Mathématique':
        return Icons.science;
      case 'Éducation Artistique et Esthétique':
        return Icons.palette;
      case 'Éveil scientifique':
        return Icons.science;
      case 'Dessin':
      case 'Éducation artistique':
        return Icons.palette;
      case 'Éducation scientifique':
        return Icons.biotech;
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
      case 'Histoire-Géographie':
        return tr('histoire_geo');
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
      case 'Éducation scientifique':
        return tr('education_scientifique');
      case 'Éducation artistique':
        return tr('education_artistique');
      case 'Langage et Communication':
        return AppTranslations.isArabic
            ? 'اللغة والتواصل'
            : 'Langage et Communication';
      case 'Éveil Scientifique et Mathématique':
        return AppTranslations.isArabic
            ? 'الإيقاظ العلمي والرياضي'
            : 'Éveil Scientifique et Mathématique';
      case 'Éducation Artistique et Esthétique':
        return AppTranslations.isArabic
            ? 'التربية الفنية والجمالية'
            : 'Éducation Artistique et Esthétique';
      case 'Activités Psychomotrices':
        return AppTranslations.isArabic
            ? 'الأنشطة النفسحركية'
            : 'Activités Psychomotrices';
      case 'Éducation Islamique et Sociale':
        return AppTranslations.isArabic
            ? 'التربية الإسلامية والاجتماعية'
            : 'Éducation Islamique et Sociale';
      default:
        return subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = SchoolData.getSubjectsForLevel(level);
    final isPrep = SchoolData.isPreparatoire(level);

    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ✅ Pas de moyennes/bulletins pour le Préparatoire
            if (!isPrep) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AveragesScreen(
                        cycle: cycle,
                        level: level,
                        className: className,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart),
                label: Text(tr('general_average')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BulletinsScreen(
                        cycle: cycle,
                        level: level,
                        className: className,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(tr('bulletin_pdf')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Info pour le Préparatoire
            if (isPrep)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppTranslations.isArabic
                            ? 'التقييم بالكفاءات (مكتسب / في طور الاكتساب / غير مكتسب)'
                            : 'Évaluation par compétences (Acquis / En cours / Non acquis)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Liste des matières
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: subjects.map((subject) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GradesStudentsScreen(
                          cycle: cycle,
                          level: level,
                          className: className,
                          subject: subject,
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
                            color: _color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getSubjectIcon(subject),
                            color: _color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _getSubjectTranslated(subject),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _color,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
