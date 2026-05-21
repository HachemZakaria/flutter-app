import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';

class BranchesScreen extends StatelessWidget {
  final String cycle;
  final String level;
  final Widget Function(String cycle, String level, String className)
  classScreenBuilder;

  const BranchesScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.classScreenBuilder,
  });

  Color get _color => Color(SchoolData.cycleColors[cycle] ?? 0xFF9E9E9E);

  IconData _getBranchIcon(String branch) {
    if (branch.contains('Sciences') || branch.contains('Expérimentales')) {
      return Icons.science;
    }
    if (branch.contains('Mathématiques') || branch.contains('Technique')) {
      return Icons.calculate;
    }
    if (branch.contains('Lettres') || branch.contains('Philosophie')) {
      return Icons.auto_stories;
    }
    if (branch.contains('Langues')) {
      return Icons.language;
    }
    if (branch.contains('Gestion') || branch.contains('Économie')) {
      return Icons.business;
    }
    return Icons.school;
  }

  String _getBranchTranslated(String branch) {
    switch (branch) {
      case 'Tronc Commun Sciences':
        return tr('tronc_commun_sciences');
      case 'Tronc Commun Lettres':
        return tr('tronc_commun_lettres');
      case 'Sciences Expérimentales':
        return tr('sciences_experimentales');
      case 'Mathématiques':
        return tr('mathematiques_branch');
      case 'Technique Mathématiques':
        return tr('technique_mathematiques');
      case 'Gestion et Économie':
        return tr('gestion_economie');
      case 'Lettres et Philosophie':
        return tr('lettres_philosophie');
      case 'Langues Étrangères':
        return tr('langues_etrangeres');
      default:
        return branch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = SchoolData.getBranchesForLevel(level);

    return Scaffold(
      appBar: AppBar(
        title: Text('$level - ${tr('branches')}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cycle,
                      style: TextStyle(
                        color: _color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    level,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${branches.length} ${tr('branches').toLowerCase()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              tr('choose_branch'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  final classes = SchoolData.getClassesForBranch(level, branch);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _BranchClassesScreen(
                            cycle: cycle,
                            level: level,
                            branch: branch,
                            classes: classes,
                            color: _color,
                            classScreenBuilder: classScreenBuilder,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _color.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: _color.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getBranchIcon(branch),
                            color: _color,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          _getBranchTranslated(branch),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${classes.length} ${tr('classes').toLowerCase()}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          AppTranslations.isArabic
                              ? Icons.arrow_back_ios
                              : Icons.arrow_forward_ios,
                          color: _color,
                          size: 16,
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

// ═══════════════════════════════════════════════════════
// Classes d'une branche
// ═══════════════════════════════════════════════════════

class _BranchClassesScreen extends StatelessWidget {
  final String cycle;
  final String level;
  final String branch;
  final List<String> classes;
  final Color color;
  final Widget Function(String cycle, String level, String className)
  classScreenBuilder;

  const _BranchClassesScreen({
    required this.cycle,
    required this.level,
    required this.branch,
    required this.classes,
    required this.color,
    required this.classScreenBuilder,
  });

  String _getBranchTranslated(String branch) {
    switch (branch) {
      case 'Tronc Commun Sciences':
        return tr('tronc_commun_sciences');
      case 'Tronc Commun Lettres':
        return tr('tronc_commun_lettres');
      case 'Sciences Expérimentales':
        return tr('sciences_experimentales');
      case 'Mathématiques':
        return tr('mathematiques_branch');
      case 'Technique Mathématiques':
        return tr('technique_mathematiques');
      case 'Gestion et Économie':
        return tr('gestion_economie');
      case 'Lettres et Philosophie':
        return tr('lettres_philosophie');
      case 'Langues Étrangères':
        return tr('langues_etrangeres');
      default:
        return branch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getBranchTranslated(branch)),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getBranchTranslated(branch),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              classScreenBuilder(cycle, level, className),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.1),
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
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.class_, color: color, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              className,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
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
          ],
        ),
      ),
    );
  }
}
