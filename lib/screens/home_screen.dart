import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'cycles_screen.dart';
import 'grades_cycles_screen.dart';
import 'absences_cycles_screen.dart';
import 'payments_cycles_screen.dart';
import 'courses_cycles_screen.dart';
import 'corrections_cycles_screen.dart';
import 'accounts_screen.dart';
import 'announcements_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final accountStr = prefs.getString('current_account');
    if (accountStr != null) {
      final account = jsonDecode(accountStr);
      return account['uid'] ?? 'admin';
    }
    return 'admin';
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('logout')),
        content: Text(tr('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(
              tr('logout'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primary,
            actions: [
              FutureBuilder<String>(
                future: _getCurrentUserId(),
                builder: (context, userSnapshot) {
                  final userId = userSnapshot.data ?? 'admin';
                  return StatefulBuilder(
                    builder: (context, setClochState) {
                      return FutureBuilder<int>(
                        future: FirebaseService.getUnreadNotificationsCount(
                          userId,
                        ),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Stack(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NotificationsScreen(userId: userId),
                                    ),
                                  );
                                  setClochState(() {});
                                },
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
              IconButton(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF534BAE)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr('app_name'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    tr('school_slogan'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.admin_panel_settings,
                                color: Color(0xFFFFC107),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tr('admin_space'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    tr('dashboard'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    tr('manage_school'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    _m(
                      context,
                      Icons.people_rounded,
                      tr('students'),
                      tr('students_management'),
                      AppTheme.studentColor,
                      const CyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.grade_rounded,
                      tr('grades'),
                      tr('grades_subtitle'),
                      AppTheme.gradesColor,
                      const GradesCyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.event_busy_rounded,
                      tr('absences'),
                      tr('absences_subtitle'),
                      AppTheme.absencesColor,
                      const AbsencesCyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.payments_rounded,
                      tr('payments'),
                      tr('payments_subtitle'),
                      AppTheme.paymentsColor,
                      const PaymentsCyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.menu_book_rounded,
                      tr('courses'),
                      tr('courses_subtitle'),
                      AppTheme.coursesColor,
                      const CoursesCyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.assignment_rounded,
                      tr('corrections'),
                      tr('corrections_subtitle'),
                      AppTheme.correctionsColor,
                      const CorrectionsCyclesScreen(),
                    ),
                    _m(
                      context,
                      Icons.manage_accounts_rounded,
                      tr('accounts'),
                      tr('accounts_subtitle'),
                      AppTheme.accountsColor,
                      const AccountsScreen(),
                    ),
                    _m(
                      context,
                      Icons.campaign_rounded,
                      'Annonces',
                      'Communiquer',
                      Colors.purple,
                      const AnnouncementsScreen(isAdmin: true),
                    ),
                    _m(
                      context,
                      Icons.message_rounded,
                      'Messages',
                      'Parents/Élèves',
                      Colors.blue,
                      const MessagesScreen(isAdmin: true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTranslations.isArabic
                                ? 'سيدي مبروك ، قسنطينة'
                                : 'Sidi Mabrouk, Constantine',
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: AppTheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tr('preschool_primary')} : ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const Text(
                            '+213 555 04 49 65',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: AppTheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tr('middle_high_school')} : ',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const Text(
                            '+213 555 03 98 95',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _m(
    BuildContext c,
    IconData i,
    String t,
    String s,
    Color co,
    Widget sc,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => sc)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: co.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: co.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(i, color: co, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: co,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
