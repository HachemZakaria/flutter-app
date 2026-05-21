import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'student_grades_view.dart';
import 'student_absences_view.dart';
import 'student_payments_view.dart';
import 'content_subjects_screen.dart';
import 'announcements_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> account;
  const ParentDashboardScreen({super.key, required this.account});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int selectedChildIndex = 0;

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
    final parentName = widget.account['parentName'] ?? '';
    final userId = widget.account['uid'] ?? '';
    final children = (widget.account['children'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final child = children.isNotEmpty ? children[selectedChildIndex] : null;
    final studentName = child?['studentName'] ?? '';
    final className = child?['className'] ?? '';
    final level = child?['level'] ?? '';
    final cycle = child?['cycle'] ?? '';

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
                                    tr('parent_space'),
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
                                  parentName.isNotEmpty
                                      ? parentName[0].toUpperCase()
                                      : 'P',
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
                                      parentName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${children.length} ${tr('children')}',
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
              delegate: SliverChildListDelegate(
                children.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              AppTranslations.isArabic
                                  ? 'لا يوجد طفل مرتبط بهذا الحساب'
                                  : 'Aucun enfant lié à ce compte',
                              style: const TextStyle(color: AppTheme.textLight),
                            ),
                          ),
                        ),
                      ]
                    : [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('choose_child'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: selectedChildIndex,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.child_care,
                                    color: AppTheme.primary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: List.generate(
                                  children.length,
                                  (index) => DropdownMenuItem(
                                    value: index,
                                    child: Text(
                                      children[index]['studentName'] ?? '',
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null)
                                    setState(() => selectedChildIndex = value);
                                },
                              ),
                              if (child != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFFFFC107,
                                        ),
                                        child: Text(
                                          studentName.isNotEmpty
                                              ? studentName[0].toUpperCase()
                                              : '',
                                          style: const TextStyle(
                                            color: Color(0xFF1A237E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              '$cycle • $level • $className',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            tr('child_follow_up'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                          ),
                        ),
                        if (child != null)
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
                                tr('grades'),
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
                                tr('absences'),
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
                                Icons.payments_rounded,
                                tr('payments'),
                                tr('payments_subtitle'),
                                AppTheme.paymentsColor,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentPaymentsView(
                                      studentName: studentName,
                                      className: className,
                                    ),
                                  ),
                                ),
                              ),
                              _c(
                                context,
                                Icons.menu_book_rounded,
                                tr('courses'),
                                tr('courses_subtitle'),
                                AppTheme.coursesColor,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContentSubjectsScreen(
                                      moduleType: 'courses',
                                      moduleTitle: tr('courses'),
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
                                tr('corrections'),
                                tr('corrections_subtitle'),
                                AppTheme.correctionsColor,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContentSubjectsScreen(
                                      moduleType: 'corrections',
                                      moduleTitle: tr('corrections'),
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
                                'Contact',
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MessagesScreen(),
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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tr('contact_school'),
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
                                    Icons.school,
                                    color: AppTheme.primary,
                                    size: 14,
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
                                    Icons.school,
                                    color: AppTheme.primary,
                                    size: 14,
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
                      ],
              ),
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
