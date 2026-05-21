import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'student_grades_view.dart';
import 'student_absences_view.dart';
import 'content_subjects_screen.dart';
import 'announcements_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> account;
  const StudentDashboardScreen({super.key, required this.account});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
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
              await prefs.remove('current_role');
              await prefs.remove('current_account');
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
    final studentName = widget.account['studentName'] ?? '';
    final className = widget.account['className'] ?? '';
    final level = widget.account['level'] ?? '';
    final cycle = widget.account['cycle'] ?? '';
    final userId = widget.account['uid'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primary,
            actions: [
              // ✅ Cloche avec rafraîchissement
              StatefulBuilder(
                builder: (context, setClochState) {
                  return FutureBuilder<int>(
                    future: FirebaseService.getUnreadNotificationsCount(userId),
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
                              width: 50,
                              height: 50,
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr('app_name'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    tr('student_space'),
                                    style: const TextStyle(
                                      color: Color(0xFFFFC107),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFFFC107),
                                child: Text(
                                  studentName.isNotEmpty
                                      ? studentName[0].toUpperCase()
                                      : 'E',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tr('welcome')} 👋',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      studentName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$cycle • $className',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
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
                    tr('my_space'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    tr('access_info'),
                    style: const TextStyle(
                      fontSize: 13,
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
                    _c(
                      context,
                      Icons.grade_rounded,
                      tr('my_grades'),
                      tr('grades_subtitle'),
                      AppTheme.gradesColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentGradesView(
                            studentName: studentName,
                            className: className,
                            level: level,
                            cycle: cycle,
                          ),
                        ),
                      ),
                    ),
                    _c(
                      context,
                      Icons.event_busy_rounded,
                      tr('my_absences'),
                      tr('absences_subtitle'),
                      AppTheme.absencesColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentAbsencesView(
                            studentName: studentName,
                            className: className,
                          ),
                        ),
                      ),
                    ),
                    _c(
                      context,
                      Icons.menu_book_rounded,
                      tr('my_courses'),
                      tr('courses_subtitle'),
                      AppTheme.coursesColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentSubjectsScreen(
                            moduleType: 'courses',
                            moduleTitle: tr('my_courses'),
                            moduleColor: AppTheme.coursesColor,
                            cycle: cycle,
                            level: level,
                            isReadOnly: true,
                          ),
                        ),
                      ),
                    ),
                    _c(
                      context,
                      Icons.assignment_rounded,
                      tr('my_corrections'),
                      tr('corrections_subtitle'),
                      AppTheme.correctionsColor,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentSubjectsScreen(
                            moduleType: 'corrections',
                            moduleTitle: tr('my_corrections'),
                            moduleColor: AppTheme.correctionsColor,
                            cycle: cycle,
                            level: level,
                            isReadOnly: true,
                          ),
                        ),
                      ),
                    ),
                    _c(
                      context,
                      Icons.campaign_rounded,
                      'Annonces',
                      AppTranslations.isArabic ? 'المدرسة' : 'École',
                      Colors.purple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementsScreen(),
                        ),
                      ),
                    ),
                    _c(
                      context,
                      Icons.message_rounded,
                      'Messages',
                      AppTranslations.isArabic ? 'قراءة فقط' : 'Lecture seule',
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MessagesScreen(isReadOnly: true),
                        ),
                      ),
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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr('good_luck_studies'),
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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

  Widget _c(
    BuildContext c,
    IconData i,
    String t,
    String s,
    Color co,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
