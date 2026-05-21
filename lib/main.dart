import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/app_theme.dart';
import 'data/app_translations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/parent_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Charger la langue sauvegardée
  final prefs = await SharedPreferences.getInstance();
  AppTranslations.currentLanguage = prefs.getString('app_language') ?? 'fr';

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ═══════════════════════════════════════════════════════
  // Méthode statique pour rebuild l'app après changement de langue
  // ═══════════════════════════════════════════════════════
  static void setLanguage(BuildContext context, String lang) async {
    AppTranslations.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);

    final state = context.findAncestorStateOfType<_MyAppState>();
    state?._rebuild();
  }
}

class _MyAppState extends State<MyApp> {
  // ✅ Clé unique qui force le rebuild complet de l'app
  Key _appKey = UniqueKey();

  void _rebuild() {
    setState(() {
      _appKey = UniqueKey(); // ✅ Génère une nouvelle clé → rebuild total
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _appKey, // ✅ Très important pour forcer le rebuild
      debugShowCheckedModeBanner: false,
      title: 'Dar Ennadjah',
      theme: AppTheme.lightTheme,

      // Localizations
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('ar', 'DZ')],
      locale: AppTranslations.isArabic
          ? const Locale('ar', 'DZ')
          : const Locale('fr', 'FR'),

      // Direction RTL automatique pour l'arabe
      builder: (context, child) {
        return Directionality(
          textDirection: AppTranslations.isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final role = prefs.getString('current_role') ?? '';
    final accountData = prefs.getString('current_account');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Map<String, dynamic> account = {};
    if (accountData != null) {
      account = jsonDecode(accountData);
    }

    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 'student':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboardScreen(account: account),
          ),
        );
        break;
      case 'parent':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentDashboardScreen(account: account),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF000051)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dar Ennadjah',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'دار النجاح',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'L\'école qui fait aimer l\'école',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
