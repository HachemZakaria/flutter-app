import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════
  // COULEURS DAR ENNADJAH
  // ═══════════════════════════════════════════════════════

  // Couleur principale - Bleu marine du logo
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);

  // Couleur secondaire - Jaune/Doré du logo
  static const Color secondary = Color(0xFFFFC107);
  static const Color secondaryLight = Color(0xFFFFF350);
  static const Color secondaryDark = Color(0xFFC79100);

  // Couleurs supplémentaires
  static const Color accent = Color(0xFF3F51B5);
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  // Couleurs status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Couleurs des modules
  static const Color studentColor = Color(0xFF1A237E); // Bleu marine
  static const Color gradesColor = Color(0xFFFF9800); // Orange
  static const Color absencesColor = Color(0xFFE53935); // Rouge
  static const Color paymentsColor = Color(0xFF4CAF50); // Vert
  static const Color coursesColor = Color(0xFF3F51B5); // Bleu
  static const Color correctionsColor = Color(0xFF7B1FA2); // Violet
  static const Color accountsColor = Color(0xFF00897B); // Teal

  // ═══════════════════════════════════════════════════════
  // INFOS ÉCOLE
  // ═══════════════════════════════════════════════════════

  static const String schoolName = 'Dar Ennadjah';
  static const String schoolFullName = 'Groupe Scolaire Dar Ennadjah';
  static const String schoolSlogan = 'L\'école qui fait aimer l\'école';
  static const String schoolLocation = 'Sidi Mabrouk, Constantine';
  static const String phonePrimaire = '+213 555 04 49 65';
  static const String phoneLycee = '+213 555 03 98 95';

  // ═══════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  // ═══════════════════════════════════════════════════════
  // STYLE GLOBAL
  // ═══════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
