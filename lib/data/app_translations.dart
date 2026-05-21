class AppTranslations {
  static String currentLanguage = 'fr';

  static const Map<String, Map<String, String>> _translations = {
    // ═══════════════════════════════════════════════════
    // GÉNÉRAL
    // ═══════════════════════════════════════════════════
    'app_name': {'fr': 'Dar Ennadjah', 'ar': 'دار النجاح'},
    'school_slogan': {
      'fr': 'L\'école qui fait aimer l\'école',
      'ar': 'المدرسة التي تجعلك تحب المدرسة',
    },
    'welcome': {'fr': 'Bienvenue', 'ar': 'مرحباً'},
    'language': {'fr': 'Langue', 'ar': 'اللغة'},
    'french': {'fr': 'Français', 'ar': 'الفرنسية'},
    'arabic': {'fr': 'العربية', 'ar': 'العربية'},
    'settings': {'fr': 'Paramètres', 'ar': 'الإعدادات'},

    // ═══════════════════════════════════════════════════
    // LOGIN
    // ═══════════════════════════════════════════════════
    'login': {'fr': 'Connexion', 'ar': 'تسجيل الدخول'},
    'logout': {'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'email': {'fr': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'fr': 'Mot de passe', 'ar': 'كلمة المرور'},
    'forgot_password': {
      'fr': 'Mot de passe oublié ?',
      'ar': 'نسيت كلمة المرور ؟',
    },
    'create_admin_account': {
      'fr': 'Créer compte administrateur',
      'ar': 'إنشاء حساب المسؤول',
    },
    'create_account': {'fr': 'Créer le compte', 'ar': 'إنشاء الحساب'},
    'sign_in': {'fr': 'Se connecter', 'ar': 'تسجيل الدخول'},
    'admin_student_parent': {
      'fr': 'Admin • Élève • Parent',
      'ar': 'مسؤول • تلميذ • ولي',
    },
    'logout_confirm': {
      'fr': 'Voulez-vous vous déconnecter ?',
      'ar': 'هل تريد تسجيل الخروج ؟',
    },

    // ═══════════════════════════════════════════════════
    // DASHBOARD
    // ═══════════════════════════════════════════════════
    'dashboard': {'fr': 'Tableau de bord', 'ar': 'لوحة التحكم'},
    'admin_space': {'fr': 'Espace Administrateur', 'ar': 'فضاء المسؤول'},
    'student_space': {'fr': 'Espace Élève', 'ar': 'فضاء التلميذ'},
    'parent_space': {'fr': 'Espace Parent', 'ar': 'فضاء الولي'},
    'manage_school': {
      'fr': 'Gérez votre établissement scolaire',
      'ar': 'قم بإدارة مؤسستك المدرسية',
    },
    'my_space': {'fr': 'Mon espace', 'ar': 'فضائي'},
    'access_info': {
      'fr': 'Accédez à vos informations scolaires',
      'ar': 'الوصول إلى معلوماتك المدرسية',
    },
    'child_follow_up': {'fr': 'Suivi de l\'élève', 'ar': 'متابعةالتلميذ'},

    // ═══════════════════════════════════════════════════
    // MODULES
    // ═══════════════════════════════════════════════════
    'students': {'fr': 'Élèves', 'ar': 'التلاميذ'},
    'students_management': {'fr': 'Gestion des élèves', 'ar': 'إدارة التلاميذ'},
    'grades': {'fr': 'Notes', 'ar': 'العلامات'},
    'my_grades': {'fr': 'Mes Notes', 'ar': 'علاماتي'},
    'grades_subtitle': {'fr': 'Saisie & moyennes', 'ar': 'الإدخال والمعدلات'},
    'absences': {'fr': 'Absences', 'ar': 'الغيابات'},
    'my_absences': {'fr': 'Mes Absences', 'ar': 'غياباتي'},
    'absences_subtitle': {'fr': 'Suivi journalier', 'ar': 'المتابعة اليومية'},
    'payments': {'fr': 'Paiements', 'ar': 'المدفوعات'},
    'payments_subtitle': {'fr': 'Frais scolaires', 'ar': 'المصاريف المدرسية'},
    'courses': {'fr': 'Cours', 'ar': 'الدروس'},
    'my_courses': {'fr': 'Mes Cours', 'ar': 'دروسي'},
    'courses_subtitle': {'fr': 'Documents PDF', 'ar': 'وثائق PDF'},
    'corrections': {'fr': 'Corrigés', 'ar': 'التصحيحات'},
    'my_corrections': {'fr': 'Mes Corrigés', 'ar': 'تصحيحاتي'},
    'corrections_subtitle': {
      'fr': 'Examens corrigés',
      'ar': 'تصحيح الامتحانات',
    },
    'accounts': {'fr': 'Comptes', 'ar': 'الحسابات'},
    'accounts_subtitle': {'fr': 'Élèves & parents', 'ar': 'التلاميذ والأولياء'},

    // ═══════════════════════════════════════════════════
    // CYCLES
    // ═══════════════════════════════════════════════════
    'cycle': {'fr': 'Cycle', 'ar': 'المرحلة'},
    'preparatoire': {'fr': 'Préparatoire', 'ar': 'التحضيري'},
    'primaire': {'fr': 'Primaire', 'ar': 'الابتدائي'},
    'cem': {'fr': 'CEM', 'ar': 'المتوسط'},
    'lycee': {'fr': 'Lycée', 'ar': 'الثانوي'},
    'level': {'fr': 'Année', 'ar': 'السنة'},
    'class_': {'fr': 'Classe', 'ar': 'القسم'},
    'classes': {'fr': 'Classes', 'ar': 'الأقسام'},
    'branch': {'fr': 'Filière', 'ar': 'الشعبة'},
    'branches': {'fr': 'Filières', 'ar': 'الشعب'},
    'choose_cycle': {'fr': 'Choisissez un cycle', 'ar': 'اختر مرحلة'},
    'choose_level': {'fr': 'Choisissez une année', 'ar': 'اختر سنة'},
    'choose_class': {'fr': 'Choisissez une classe', 'ar': 'اختر قسماً'},
    'choose_branch': {'fr': 'Choisissez une filière', 'ar': 'اختر شعبة'},

    // ═══════════════════════════════════════════════════
    // BRANCHES LYCÉE
    // ═══════════════════════════════════════════════════
    'tronc_commun_sciences': {
      'fr': 'Tronc Commun Sciences',
      'ar': 'جذع مشترك علوم',
    },
    'tronc_commun_lettres': {
      'fr': 'Tronc Commun Lettres',
      'ar': 'جذع مشترك آداب',
    },
    'sciences_experimentales': {
      'fr': 'Sciences Expérimentales',
      'ar': 'علوم تجريبية',
    },
    'mathematiques_branch': {'fr': 'Mathématiques', 'ar': 'رياضيات'},
    'technique_mathematiques': {
      'fr': 'Technique Mathématiques',
      'ar': 'تقني رياضي',
    },
    'gestion_economie': {'fr': 'Gestion et Économie', 'ar': 'تسيير واقتصاد'},
    'lettres_philosophie': {
      'fr': 'Lettres et Philosophie',
      'ar': 'آداب وفلسفة',
    },
    'langues_etrangeres': {'fr': 'Langues Étrangères', 'ar': 'لغات أجنبية'},

    // ═══════════════════════════════════════════════════
    // BOUTONS
    // ═══════════════════════════════════════════════════
    'add': {'fr': 'Ajouter', 'ar': 'إضافة'},
    'edit': {'fr': 'Modifier', 'ar': 'تعديل'},
    'delete': {'fr': 'Supprimer', 'ar': 'حذف'},
    'save': {'fr': 'Enregistrer', 'ar': 'حفظ'},
    'cancel': {'fr': 'Annuler', 'ar': 'إلغاء'},
    'confirm': {'fr': 'Confirmer', 'ar': 'تأكيد'},
    'close': {'fr': 'Fermer', 'ar': 'إغلاق'},
    'search': {'fr': 'Rechercher', 'ar': 'بحث'},
    'validate': {'fr': 'Valider', 'ar': 'تأكيد'},
    'next': {'fr': 'Suivant', 'ar': 'التالي'},
    'back': {'fr': 'Retour', 'ar': 'رجوع'},
    'select': {'fr': 'Sélectionner', 'ar': 'اختيار'},
    'import': {'fr': 'Importer', 'ar': 'استيراد'},
    'export': {'fr': 'Exporter', 'ar': 'تصدير'},
    'print': {'fr': 'Imprimer', 'ar': 'طباعة'},
    'download': {'fr': 'Télécharger', 'ar': 'تحميل'},

    // ═══════════════════════════════════════════════════
    // ÉLÈVE
    // ═══════════════════════════════════════════════════
    'student_name': {'fr': 'Nom de l\'élève', 'ar': 'اسم التلميذ'},
    'first_name': {'fr': 'Prénom', 'ar': 'الاسم'},
    'last_name': {'fr': 'Nom', 'ar': 'اللقب'},
    'birth_date': {'fr': 'Date de naissance', 'ar': 'تاريخ الميلاد'},
    'birth_place': {'fr': 'Lieu de naissance', 'ar': 'مكان الميلاد'},
    'add_student': {'fr': 'Ajouter un élève', 'ar': 'إضافة تلميذ'},
    'edit_student': {'fr': 'Modifier l\'élève', 'ar': 'تعديل التلميذ'},
    'delete_student': {'fr': 'Supprimer l\'élève', 'ar': 'حذف التلميذ'},
    'no_students': {'fr': 'Aucun élève', 'ar': 'لا يوجد تلاميذ'},
    'students_count': {'fr': 'élève(s)', 'ar': 'تلميذ(تلاميذ)'},
    'import_csv': {'fr': 'Importer liste CSV', 'ar': 'استيراد قائمة CSV'},
    'export_pdf': {'fr': 'Exporter PDF', 'ar': 'تصدير PDF'},
    'empty_class': {'fr': 'Vider la classe', 'ar': 'تفريغ القسم'},

    // ═══════════════════════════════════════════════════
    // NOTES
    // ═══════════════════════════════════════════════════
    'subject': {'fr': 'Matière', 'ar': 'المادة'},
    'subjects': {'fr': 'Matières', 'ar': 'المواد'},
    'trimester': {'fr': 'Trimestre', 'ar': 'الفصل'},
    'trimester_1': {'fr': 'Trimestre 1', 'ar': 'الفصل الأول'},
    'trimester_2': {'fr': 'Trimestre 2', 'ar': 'الفصل الثاني'},
    'trimester_3': {'fr': 'Trimestre 3', 'ar': 'الفصل الثالث'},
    'devoir_1': {'fr': 'Devoir 1', 'ar': 'الفرض الأول'},
    'devoir_2': {'fr': 'Devoir 2', 'ar': 'الفرض الثاني'},
    'exam': {'fr': 'Examen', 'ar': 'الاختبار'},
    'average': {'fr': 'Moyenne', 'ar': 'المعدل'},
    'general_average': {'fr': 'Moyenne Générale', 'ar': 'المعدل العام'},
    'rank': {'fr': 'Rang', 'ar': 'الترتيب'},
    'mention': {'fr': 'Mention', 'ar': 'الملاحظة'},
    'very_good': {'fr': 'Très Bien', 'ar': 'جيد جداً'},
    'good': {'fr': 'Bien', 'ar': 'جيد'},
    'fairly_good': {'fr': 'Assez Bien', 'ar': 'حسن'},
    'pass': {'fr': 'Passable', 'ar': 'مقبول'},
    'insufficient': {'fr': 'Insuffisant', 'ar': 'ضعيف'},
    'enter_grade': {'fr': 'Saisir la note', 'ar': 'إدخال العلامة'},
    'note_out_of': {'fr': 'Note /20', 'ar': 'العلامة /20'},

    // ═══════════════════════════════════════════════════
    // BULLETINS
    // ═══════════════════════════════════════════════════
    'bulletins': {'fr': 'Bulletins', 'ar': 'كشوف النقاط'},
    'bulletin': {'fr': 'Bulletin', 'ar': 'كشف النقاط'},
    'bulletin_pdf': {'fr': 'Bulletin PDF', 'ar': 'كشف النقاط PDF'},
    'admitted': {'fr': 'Admis(e)', 'ar': 'ناجح'},
    'not_admitted': {'fr': 'Non Admis(e)', 'ar': 'راسب'},
    'appreciation': {'fr': 'Appréciation', 'ar': 'الملاحظة'},

    // ═══════════════════════════════════════════════════
    // ABSENCES
    // ═══════════════════════════════════════════════════
    'present': {'fr': 'Présent', 'ar': 'حاضر'},
    'absent': {'fr': 'Absent', 'ar': 'غائب'},
    'late': {'fr': 'Retard', 'ar': 'متأخر'},
    'justified': {'fr': 'Justifiée', 'ar': 'مبرر'},
    'not_justified': {'fr': 'Non justifiée', 'ar': 'غير مبرر'},
    'reason': {'fr': 'Motif', 'ar': 'السبب'},
    'date': {'fr': 'Date', 'ar': 'التاريخ'},
    'no_absences': {'fr': 'Aucune absence !', 'ar': 'لا غيابات !'},

    // ═══════════════════════════════════════════════════
    // PAIEMENTS
    // ═══════════════════════════════════════════════════
    'payment_type': {'fr': 'Type de paiement', 'ar': 'نوع الدفع'},
    'amount': {'fr': 'Montant', 'ar': 'المبلغ'},
    'paid': {'fr': 'Payé', 'ar': 'مدفوع'},
    'remaining': {'fr': 'Reste', 'ar': 'المتبقي'},
    'total_due': {'fr': 'Total dû', 'ar': 'الإجمالي المستحق'},
    'fully_paid': {'fr': 'Tout payé', 'ar': 'مدفوع بالكامل'},
    'partially_paid': {'fr': 'Partiellement payé', 'ar': 'مدفوع جزئياً'},
    'not_paid': {'fr': 'Non payé', 'ar': 'غير مدفوع'},
    'inscription': {'fr': 'Inscription', 'ar': 'التسجيل'},
    'monthly_fee': {'fr': 'Mensualité', 'ar': 'القسط الشهري'},
    'transport': {'fr': 'Transport', 'ar': 'النقل'},
    'cantine': {'fr': 'Cantine', 'ar': 'المطعم'},
    'receipt': {'fr': 'Reçu', 'ar': 'الإيصال'},

    // ═══════════════════════════════════════════════════
    // COURS / CORRIGÉS
    // ═══════════════════════════════════════════════════
    'title': {'fr': 'Titre', 'ar': 'العنوان'},
    'description': {'fr': 'Description', 'ar': 'الوصف'},
    'add_course': {'fr': 'Ajouter un cours', 'ar': 'إضافة درس'},
    'add_correction': {'fr': 'Ajouter un corrigé', 'ar': 'إضافة تصحيح'},
    'attach_file': {'fr': 'Joindre un fichier', 'ar': 'إرفاق ملف'},
    'no_courses': {'fr': 'Aucun cours', 'ar': 'لا توجد دروس'},
    'no_corrections': {'fr': 'Aucun corrigé', 'ar': 'لا توجد تصحيحات'},

    // ═══════════════════════════════════════════════════
    // COMPTES
    // ═══════════════════════════════════════════════════
    'student_account': {'fr': 'Compte Élève', 'ar': 'حساب التلميذ'},
    'parent_account': {'fr': 'Compte Parent', 'ar': 'حساب الولي'},
    'parent_name': {'fr': 'Nom du parent', 'ar': 'اسم الولي'},
    'children': {'fr': 'Enfants', 'ar': 'الأبناء'},
    'select_student': {'fr': 'Sélectionner un élève', 'ar': 'اختيار تلميذ'},
    'select_children': {
      'fr': 'Sélectionner les enfants',
      'ar': 'اختيار الأبناء',
    },
    'choose_child': {'fr': 'Choisir un enfant', 'ar': 'اختيار طفل'},
    'create_student_account': {
      'fr': 'Créer le compte élève',
      'ar': 'إنشاء حساب التلميذ',
    },
    'create_parent_account': {
      'fr': 'Créer le compte parent',
      'ar': 'إنشاء حساب الولي',
    },

    // ═══════════════════════════════════════════════════
    // MATIÈRES
    // ═══════════════════════════════════════════════════
    'arabe': {'fr': 'Arabe', 'ar': 'العربية'},
    'francais': {'fr': 'Français', 'ar': 'الفرنسية'},
    'anglais': {'fr': 'Anglais', 'ar': 'الإنجليزية'},
    'maths': {'fr': 'Mathématiques', 'ar': 'الرياضيات'},
    'sciences_physiques': {
      'fr': 'Sciences physiques',
      'ar': 'العلوم الفيزيائية',
    },
    'sciences_naturelles': {
      'fr': 'Sciences naturelles',
      'ar': 'العلوم الطبيعية',
    },
    'philosophie': {'fr': 'Philosophie', 'ar': 'الفلسفة'},
    'histoire': {'fr': 'Histoire', 'ar': 'التاريخ'},
    'geographie': {'fr': 'Géographie', 'ar': 'الجغرافيا'},
    'islamique': {'fr': 'Éducation islamique', 'ar': 'التربية الإسلامية'},
    'civique': {'fr': 'Éducation civique', 'ar': 'التربية المدنية'},
    'informatique': {'fr': 'Informatique', 'ar': 'الإعلام الآلي'},
    'sport': {'fr': 'Éducation physique', 'ar': 'التربية البدنية'},
    'eveil_scientifique': {'fr': 'Éveil scientifique', 'ar': 'التفتح العلمي'},
    'dessin': {'fr': 'Dessin', 'ar': 'الرسم'},
    'histoire_geo': {'fr': 'Histoire-Géographie', 'ar': 'التاريخ والجغرافيا'},
    'education_scientifique': {
      'fr': 'Éducation scientifique',
      'ar': 'التربية العلمية',
    },
    'education_artistique': {
      'fr': 'Éducation artistique',
      'ar': 'التربية الفنية',
    },

    // ═══════════════════════════════════════════════════
    // MESSAGES
    // ═══════════════════════════════════════════════════
    'fill_all_fields': {
      'fr': 'Remplissez tous les champs',
      'ar': 'املأ جميع الحقول',
    },
    'invalid_email': {'fr': 'Email invalide', 'ar': 'بريد إلكتروني غير صالح'},
    'wrong_credentials': {
      'fr': 'Email ou mot de passe incorrect',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    },
    'email_exists': {
      'fr': 'Cet email existe déjà',
      'ar': 'هذا البريد الإلكتروني موجود مسبقاً',
    },
    'success': {'fr': 'Succès', 'ar': 'نجاح'},
    'error': {'fr': 'Erreur', 'ar': 'خطأ'},
    'warning': {'fr': 'Attention', 'ar': 'تنبيه'},
    'confirm_delete': {'fr': 'Confirmer la suppression', 'ar': 'تأكيد الحذف'},

    // ═══════════════════════════════════════════════════
    // ÉCOLE INFOS
    // ═══════════════════════════════════════════════════
    'contact_school': {'fr': 'Contactez l\'école', 'ar': 'اتصل بالمدرسة'},
    'preschool_primary': {
      'fr': 'Préscolaire-Primaire',
      'ar': 'التحضيري-الابتدائي',
    },
    'middle_high_school': {'fr': 'Collège-Lycée', 'ar': 'المتوسط-الثانوي'},
    'good_luck_studies': {
      'fr': 'Bon courage dans tes études !',
      'ar': 'حظاً موفقاً في دراستك !',
    },
  };

  // ═══════════════════════════════════════════════════════
  // OBTENIR LA TRADUCTION
  // ═══════════════════════════════════════════════════════

  static String get(String key) {
    if (!_translations.containsKey(key)) {
      return key; // Retourne la clé si non trouvée
    }
    return _translations[key]?[currentLanguage] ?? key;
  }

  // Vérifier si la langue est arabe
  static bool get isArabic => currentLanguage == 'ar';

  // Changer de langue
  static void setLanguage(String lang) {
    currentLanguage = lang;
  }
}

// Raccourci pour utilisation rapide
String tr(String key) => AppTranslations.get(key);
