import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';
import 'student_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isCreatingAdmin = false;

  Future<void> _checkAdminExists() async {
    setState(() {
      _isCreatingAdmin = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkAdminExists();
  }

  Future<void> _createAdminAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = tr('fill_all_fields'));
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMessage = tr('invalid_email'));
      return;
    }
    if (password.length < 6) {
      setState(
        () => _errorMessage = AppTranslations.isArabic
            ? 'كلمة المرور: 6 أحرف على الأقل'
            : 'Mot de passe : 6 caractères minimum',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseService.signUp(
        email: email,
        password: password,
        role: 'admin',
        userData: {'name': 'Administrateur'},
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_created', true);

      setState(() {
        _isCreatingAdmin = false;
        _isLoading = false;
      });

      _emailController.clear();
      _passwordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppTranslations.isArabic
                  ? '✅ تم إنشاء حساب المسؤول! قم بتسجيل الدخول.'
                  : '✅ Compte admin créé ! Connectez-vous.',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = tr('fill_all_fields'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await FirebaseService.signIn(
        email: email,
        password: password,
      );

      if (userData != null && mounted) {
        final role = userData['role'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('current_role', role);
        await prefs.setString('current_account', jsonEncode(userData));

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboardScreen(account: userData),
            ),
          );
        } else if (role == 'parent') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ParentDashboardScreen(account: userData),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════
  // MOT DE PASSE OUBLIÉ
  // ═══════════════════════════════════════════════════════

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.lock_reset, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  tr('forgot_password'),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTranslations.isArabic
                      ? 'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور'
                      : 'Entrez votre email et nous vous enverrons un lien pour réinitialiser votre mot de passe',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  enabled: !isSending,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: tr('email'),
                    hintText: 'votre@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('invalid_email')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSending = true);

                        try {
                          await FirebaseService.sendPasswordResetEmail(email);

                          if (mounted) {
                            Navigator.pop(context);
                            _showSuccessDialog();
                          }
                        } catch (e) {
                          setDialogState(() => isSending = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppTranslations.isArabic ? 'إرسال' : 'Envoyer',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic ? 'تم الإرسال' : 'Email envoyé',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          AppTranslations.isArabic
              ? '✅ تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.\n\nتحقق من صندوق الوارد (وأيضاً الرسائل غير المرغوب فيها).'
              : '✅ Un email avec un lien de réinitialisation a été envoyé.\n\nVérifiez votre boîte de réception (et les spams).',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF534BAE), Color(0xFFF8F9FF)],
            stops: [0.0, 0.4, 0.4],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        tr('app_name'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),

                      Text(
                        tr('school_slogan'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isCreatingAdmin
                                  ? tr('create_admin_account')
                                  : tr('login'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),

                            if (!_isCreatingAdmin)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  tr('admin_student_parent'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: tr('email'),
                                hintText: 'votre@email.com',
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: AppTheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: tr('password'),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: AppTheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: AppTheme.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppTheme.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_isCreatingAdmin
                                          ? _createAdminAccount
                                          : _login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _isCreatingAdmin
                                            ? tr('create_account')
                                            : tr('sign_in'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            // ✅ Bouton "Mot de passe oublié ?"
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _showForgotPasswordDialog,
                              icon: const Icon(
                                Icons.lock_reset,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              label: Text(
                                tr('forgot_password'),
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        AppTranslations.isArabic
                            ? 'سيدي مبروك • قسنطينة'
                            : 'Sidi Mabrouk • Constantine',
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        '© 2025 Dar Ennadjah',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
