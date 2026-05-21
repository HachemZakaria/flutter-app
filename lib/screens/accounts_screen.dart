import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';
import 'select_student_screen.dart';
import 'select_children_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _searchController.clear();
        _searchQuery = '';
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await FirebaseService.loadAllAccounts();
      setState(() => _accounts = accounts);
    } catch (e) {
      debugPrint('❌ _loadData error: $e');
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _studentAccounts {
    return _accounts.where((a) {
      if (a['role'] != 'student') return false;
      if (_searchQuery.isEmpty) return true;
      final name = (a['studentName'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      final className = (a['className'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          className.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _parentAccounts {
    return _accounts.where((a) {
      if (a['role'] != 'parent') return false;
      if (_searchQuery.isEmpty) return true;
      final name = (a['parentName'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      if (name.contains(query) || email.contains(query)) return true;
      final children = a['children'] as List<dynamic>? ?? [];
      for (var child in children) {
        final childMap = Map<String, dynamic>.from(child);
        final childName = (childMap['studentName'] ?? '')
            .toString()
            .toLowerCase();
        if (childName.contains(query)) return true;
      }
      return false;
    }).toList();
  }

  List<Map<String, dynamic>> get _adminAccounts {
    return _accounts.where((a) {
      if (a['role'] != 'admin') return false;
      if (_searchQuery.isEmpty) return true;
      final name = (a['name'] ?? '').toString().toLowerCase();
      final email = (a['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void _showCreateAdminAccount() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              tr('create_admin_account'),
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    enabled: !isCreating,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: '${tr('email')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('password')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isCreating ? null : () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          _showError(tr('fill_all_fields'));
                          return;
                        }
                        if (!email.contains('@')) {
                          _showError(tr('invalid_email'));
                          return;
                        }
                        if (password.length < 6) {
                          _showError(
                            AppTranslations.isArabic
                                ? 'كلمة المرور: 6 أحرف على الأقل'
                                : 'Mot de passe : 6 caractères minimum',
                          );
                          return;
                        }

                        setDialogState(() => isCreating = true);

                        try {
                          await FirebaseService.signUp(
                            email: email,
                            password: password,
                            role: 'admin',
                            userData: {'name': 'Administrateur'},
                          );
                          await _loadData();
                          if (mounted) {
                            Navigator.pop(context);
                            _showSuccess(
                              AppTranslations.isArabic
                                  ? '✅ تم إنشاء حساب المسؤول'
                                  : '✅ Compte admin créé',
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isCreating = false);
                          if (mounted) _showError(e.toString());
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr('create_account'),
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateStudentAccount() async {
    final existingIds = _accounts
        .where((a) => a['role'] == 'student')
        .map((a) => (a['studentId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toList();

    final student = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectStudentScreen(excludeStudentIds: existingIds),
      ),
    );

    if (student == null || !mounted) return;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              tr('create_student_account'),
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student['prenom']} ${student['nom']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${student['cycle']} • ${student['level']} • ${student['className']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('email')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('password')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isCreating ? null : () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          _showError(tr('fill_all_fields'));
                          return;
                        }

                        setDialogState(() => isCreating = true);

                        try {
                          await FirebaseService.signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            role: 'student',
                            userData: {
                              'studentId': student['studentId'],
                              'studentName':
                                  '${student['prenom']} ${student['nom']}',
                              'className': student['className'],
                              'level': student['level'],
                              'cycle': student['cycle'],
                            },
                          );

                          await _loadData();

                          if (mounted) {
                            Navigator.pop(context);
                            _showSuccess(
                              AppTranslations.isArabic
                                  ? '✅ تم إنشاء الحساب'
                                  : '✅ Compte créé',
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isCreating = false);
                          if (mounted) _showError(e.toString());
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr('add'),
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateParentAccount() async {
    final children = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectChildrenScreen()),
    );

    if (children == null || children.isEmpty || !mounted) return;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final parentNameController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              tr('create_parent_account'),
              style: const TextStyle(fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tr('children')} :',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...children.map((child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${child['prenom']} ${child['nom']} (${child['className']})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: parentNameController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('parent_name')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('email')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    enabled: !isCreating,
                    decoration: InputDecoration(
                      labelText: '${tr('password')} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isCreating ? null : () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        if (parentNameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          _showError(tr('fill_all_fields'));
                          return;
                        }

                        setDialogState(() => isCreating = true);

                        try {
                          final childrenData = children.map((child) {
                            return {
                              'studentId': child['studentId'],
                              'studentName':
                                  '${child['prenom']} ${child['nom']}',
                              'className': child['className'],
                              'level': child['level'],
                              'cycle': child['cycle'],
                            };
                          }).toList();

                          await FirebaseService.signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            role: 'parent',
                            userData: {
                              'parentName': parentNameController.text.trim(),
                              'children': childrenData,
                            },
                          );

                          await _loadData();

                          if (mounted) {
                            Navigator.pop(context);
                            _showSuccess(
                              AppTranslations.isArabic
                                  ? '✅ تم إنشاء الحساب'
                                  : '✅ Compte créé',
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isCreating = false);
                          if (mounted) _showError(e.toString());
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr('add'),
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic ? 'تفاصيل الحساب' : 'Détails du compte',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account['studentName'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account['cycle']} • ${account['level']} • ${account['className']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    tr('email'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  account['email'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  void _showAdminDetails(Map<String, dynamic> account) {
    final adminName = (account['name'] ?? '').toString().trim();
    final adminEmail = (account['email'] ?? '').toString().trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic ? 'تفاصيل المسؤول' : 'Détails admin',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.isArabic ? 'الاسم:' : 'Nom :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(adminName.isEmpty ? '-' : adminName),
            const SizedBox(height: 10),
            Text(
              AppTranslations.isArabic ? 'البريد:' : 'Email :',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(adminEmail.isEmpty ? '-' : adminEmail),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  void _showEditParentAccount(Map<String, dynamic> account) {
    final parentNameController = TextEditingController(
      text: account['parentName'] ?? '',
    );

    final children = account['children'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.family_restroom, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              AppTranslations.isArabic
                  ? 'تعديل حساب الولي'
                  : 'Modifier compte parent',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tr('children')} :',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...children.map((child) {
                      final c = Map<String, dynamic>.from(child);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${c['studentName']} (${c['className']})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: parentNameController,
                decoration: InputDecoration(
                  labelText: tr('parent_name'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (parentNameController.text.isEmpty) {
                _showError(tr('fill_all_fields'));
                return;
              }

              try {
                final firebaseUserId = (account['firebaseUserId'] ?? '')
                    .toString();
                if (firebaseUserId.isEmpty) {
                  _showError('ID manquant');
                  return;
                }

                await FirebaseService.updateAccount(firebaseUserId, {
                  'parentName': parentNameController.text.trim(),
                });

                await _loadData();

                if (mounted) {
                  Navigator.pop(context);
                  _showSuccess(
                    AppTranslations.isArabic ? 'تم التعديل' : 'Compte modifié',
                  );
                }
              } catch (e) {
                _showError(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              tr('save'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('confirm_delete')),
        content: Text(
          '${account['email']} ${AppTranslations.isArabic ? "سيتم حذفه" : "sera supprimé"}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final firebaseUserId = (account['firebaseUserId'] ?? '')
                    .toString();
                if (firebaseUserId.isEmpty) {
                  _showError('ID manquant');
                  return;
                }

                await FirebaseService.deleteAccountDoc(firebaseUserId);
                await _loadData();

                if (mounted) Navigator.pop(context);
              } catch (e) {
                _showError(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              tr('delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final studentCount = _accounts.where((a) => a['role'] == 'student').length;
    final parentCount = _accounts.where((a) => a['role'] == 'parent').length;
    final adminCount = _accounts.where((a) => a['role'] == 'admin').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('accounts')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              icon: const Icon(Icons.school, size: 20),
              text: '${tr('students')} ($studentCount)',
            ),
            Tab(
              icon: const Icon(Icons.family_restroom, size: 20),
              text:
                  '${AppTranslations.isArabic ? "الأولياء" : "Parents"} ($parentCount)',
            ),
            Tab(
              icon: const Icon(Icons.admin_panel_settings, size: 20),
              text:
                  '${AppTranslations.isArabic ? "المسؤولون" : "Admins"} ($adminCount)',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: _showCreateStudentAccount,
                          icon: const Icon(Icons.school, size: 20),
                          label: Text(
                            tr('student_account'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: _showCreateParentAccount,
                          icon: const Icon(Icons.family_restroom, size: 20),
                          label: Text(
                            tr('parent_account'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: _showCreateAdminAccount,
                          icon: const Icon(
                            Icons.admin_panel_settings,
                            size: 20,
                          ),
                          label: Text(
                            AppTranslations.isArabic ? 'مسؤول' : 'Compte admin',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: tr('search'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentsList(),
                      _buildParentsList(),
                      _buildAdminsList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentsList() {
    final students = _studentAccounts;

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppTranslations.isArabic
                  ? 'لا يوجد حساب تلميذ'
                  : 'Aucun compte élève',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final account = students[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.15),
              child: const Icon(Icons.school, color: Colors.blue),
            ),
            title: Text(
              account['studentName'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['email'] ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${account['cycle']} • ${account['level']} • ${account['className']}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showStudentDetails(account),
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: AppTranslations.isArabic
                      ? 'عرض التفاصيل'
                      : 'Voir détails',
                ),
                IconButton(
                  onPressed: () => _deleteAccount(account),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: tr('delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentsList() {
    final parents = _parentAccounts;

    if (parents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppTranslations.isArabic
                  ? 'لا يوجد حساب ولي'
                  : 'Aucun compte parent',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: parents.length,
      itemBuilder: (context, index) {
        final account = parents[index];
        final children = account['children'] as List<dynamic>? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.15),
                      child: const Icon(
                        Icons.family_restroom,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account['parentName'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            account['email'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEditParentAccount(account),
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: tr('edit'),
                    ),
                    IconButton(
                      onPressed: () => _deleteAccount(account),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: tr('delete'),
                    ),
                  ],
                ),
                if (children.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${children.length} ${tr('children')} :',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...children.map((child) {
                          final c = Map<String, dynamic>.from(child);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• ${c['studentName']} (${c['className']})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminsList() {
    final admins = _adminAccounts;

    if (admins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.isArabic
                  ? 'لا يوجد حساب مسؤول'
                  : 'Aucun compte admin',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final account = admins[index];
        final adminName = (account['name'] ?? '').toString().trim();
        final adminEmail = (account['email'] ?? '').toString().trim();

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.15),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.deepPurple,
              ),
            ),
            title: Text(
              adminName.isEmpty
                  ? (AppTranslations.isArabic ? 'مسؤول' : 'Administrateur')
                  : adminName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              adminEmail.isEmpty ? '-' : adminEmail,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showAdminDetails(account),
                  icon: const Icon(Icons.visibility, color: Colors.deepPurple),
                  tooltip: AppTranslations.isArabic
                      ? 'عرض التفاصيل'
                      : 'Voir détails',
                ),
                IconButton(
                  onPressed: () => _deleteAccount(account),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: tr('delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
