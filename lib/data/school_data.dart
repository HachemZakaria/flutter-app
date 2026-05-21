class SchoolData {
  static const List<String> cycles = [
    'Préparatoire',
    'Primaire',
    'CEM',
    'Lycée',
  ];

  static const Map<String, int> cycleColors = {
    'Préparatoire': 0xFFFFC107,
    'Primaire': 0xFF4CAF50,
    'CEM': 0xFF2196F3,
    'Lycée': 0xFFF44336,
  };

  static const Map<String, List<String>> levelsByCycle = {
    'Préparatoire': ['Préparatoire'],
    'Primaire': ['1ère AP', '2ème AP', '3ème AP', '4ème AP', '5ème AP'],
    'CEM': ['1ère AM', '2ème AM', '3ème AM', '4ème AM'],
    'Lycée': ['1ère AS', '2ème AS', '3ème AS'],
  };

  static const Map<String, List<String>> lyceeBranches = {
    '1ère AS': ['Tronc Commun Sciences', 'Tronc Commun Lettres'],
    '2ème AS': [
      'Sciences Expérimentales',
      'Mathématiques',
      'Technique Mathématiques',
      'Gestion et Économie',
      'Lettres et Philosophie',
      'Langues Étrangères',
    ],
    '3ème AS': [
      'Sciences Expérimentales',
      'Mathématiques',
      'Technique Mathématiques',
      'Gestion et Économie',
      'Lettres et Philosophie',
      'Langues Étrangères',
    ],
  };

  static const int _defaultClassesPerBranch = 3;
  static const int _defaultClassesPerLevel = 3;

  static bool hasBranches(String level) => lyceeBranches.containsKey(level);
  static List<String> getBranchesForLevel(String level) =>
      lyceeBranches[level] ?? [];

  static List<String> getClassesForLevel(String level) {
    if (hasBranches(level)) return [];
    int count = _defaultClassesPerLevel;
    if (level == 'Préparatoire') count = 2;
    final letters = ['A', 'B', 'C', 'D', 'E'];
    return List.generate(count, (i) => '$level ${letters[i]}');
  }

  static List<String> getClassesForBranch(String level, String branch) {
    String shortBranch = _getShortBranchName(branch);
    String shortLevel = _getShortLevelName(level);
    final letters = ['A', 'B', 'C'];
    return List.generate(
      _defaultClassesPerBranch,
      (i) => '$shortLevel $shortBranch ${letters[i]}',
    );
  }

  static String _getShortLevelName(String level) {
    switch (level) {
      case '1ère AS':
        return '1AS';
      case '2ème AS':
        return '2AS';
      case '3ème AS':
        return '3AS';
      default:
        return level;
    }
  }

  static String _getShortBranchName(String branch) {
    switch (branch) {
      case 'Tronc Commun Sciences':
        return 'TC Sci';
      case 'Tronc Commun Lettres':
        return 'TC Let';
      case 'Sciences Expérimentales':
        return 'Sc Exp';
      case 'Mathématiques':
        return 'Maths';
      case 'Technique Mathématiques':
        return 'Tech Math';
      case 'Gestion et Économie':
        return 'Gest Eco';
      case 'Lettres et Philosophie':
        return 'Let Phil';
      case 'Langues Étrangères':
        return 'Langues';
      default:
        return branch;
    }
  }

  static String getCycleForLevel(String level) {
    for (var cycle in cycles) {
      if (levelsByCycle[cycle]!.contains(level)) return cycle;
    }
    return 'Primaire';
  }

  static double getMaxNote(String level) {
    final cycle = getCycleForLevel(level);
    if (cycle == 'Primaire') return 10;
    return 20;
  }

  static bool isPreparatoire(String level) => level == 'Préparatoire';

  // ═══════════════════════════════════════════════════════
  // MATIÈRES
  // ═══════════════════════════════════════════════════════

  static const Map<String, List<String>> subjectsByCycle = {
    'Préparatoire': [
      'Langage et Communication',
      'Éveil Scientifique et Mathématique',
      'Éducation Artistique et Esthétique',
      'Activités Psychomotrices',
      'Éducation Islamique et Sociale',
    ],
    'Primaire': [
      'Arabe',
      'Français',
      'Mathématiques',
      'Éducation islamique',
      'Éducation civique',
      'Éducation scientifique',
      'Éducation artistique',
    ],
    'CEM': [
      'Arabe',
      'Français',
      'Anglais',
      'Mathématiques',
      'Sciences physiques',
      'Sciences naturelles',
      'Éducation islamique',
      'Éducation civique',
      'Histoire-Géographie',
      'Informatique',
      'Éducation artistique',
    ],
    'Lycée': [
      'Arabe',
      'Français',
      'Anglais',
      'Mathématiques',
      'Sciences physiques',
      'Sciences naturelles',
      'Philosophie',
      'Histoire-Géographie',
      'Éducation islamique',
      'Informatique',
    ],
  };

  static List<String> getSubjectsForLevel(String level) {
    final cycle = getCycleForLevel(level);
    if (level == '1ère AP' || level == '2ème AP') {
      return subjectsByCycle['Primaire']!;
    }
    if (level == '3ème AP' || level == '4ème AP' || level == '5ème AP') {
      return [
        'Arabe',
        'Français',
        'Mathématiques',
        'Éducation islamique',
        'Éducation civique',
        'Histoire-Géographie',
        'Éducation scientifique',
        'Éducation artistique',
      ];
    }
    return subjectsByCycle[cycle] ?? [];
  }

  // ═══════════════════════════════════════════════════════
  // ✅ COMPÉTENCES PRÉPARATOIRE
  // ═══════════════════════════════════════════════════════

  static const Map<String, List<String>> preparatoireCompetences = {
    'Langage et Communication': [
      'التعبير الشفوي (Expression orale arabe)',
      'فهم المسموع (Compréhension orale arabe)',
      'التهيئة للقراءة (Pré-lecture arabe)',
      'التهيئة للكتابة (Pré-écriture arabe)',
      'Expression orale français',
      'Compréhension orale français',
      'Pré-lecture français',
      'Pré-écriture français',
    ],
    'Éveil Scientifique et Mathématique': [
      'Reconnaître les nombres',
      'Compter et dénombrer',
      'Tri et classement',
      'Formes géométriques',
      'Se repérer dans l\'espace',
      'Découvrir le vivant',
      'Découvrir la matière',
      'Observer et expérimenter',
    ],
    'Éducation Artistique et Esthétique': [
      'Dessin et coloriage',
      'Découpage et collage',
      'Modelage',
      'Chant et comptines',
      'Créativité',
    ],
    'Activités Psychomotrices': [
      'Motricité globale',
      'Motricité fine',
      'Coordination',
      'Équilibre',
      'Participation aux jeux',
      'Respect des règles',
    ],
    'Éducation Islamique et Sociale': [
      'Récitation de sourates courtes',
      'Bonnes manières et comportement',
      'Respect des autres',
      'Propreté et hygiène',
      'Valeurs islamiques de base',
    ],
  };

  static List<String> getCompetencesForSubject(String subject) {
    return preparatoireCompetences[subject] ?? [];
  }

  // ═══════════════════════════════════════════════════════
  // NIVEAUX D'ÉVALUATION
  // ═══════════════════════════════════════════════════════

  static const List<String> evaluationLevels = ['A', 'ECA', 'NA'];

  static String getEvaluationLabel(String code) {
    switch (code) {
      case 'A':
        return 'Acquis';
      case 'ECA':
        return 'En cours';
      case 'NA':
        return 'Non acquis';
      default:
        return code;
    }
  }

  static String getEvaluationLabelAr(String code) {
    switch (code) {
      case 'A':
        return 'مكتسب';
      case 'ECA':
        return 'في طور الاكتساب';
      case 'NA':
        return 'غير مكتسب';
      default:
        return code;
    }
  }

  static int getEvaluationColor(String code) {
    switch (code) {
      case 'A':
        return 0xFF4CAF50;
      case 'ECA':
        return 0xFFFFC107;
      case 'NA':
        return 0xFFF44336;
      default:
        return 0xFF9E9E9E;
    }
  }
}
