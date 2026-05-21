import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class SelectStudentScreen extends StatefulWidget {
  final List<String> excludeStudentIds;

  const SelectStudentScreen({super.key, this.excludeStudentIds = const []});

  @override
  State<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends State<SelectStudentScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;

  String? _selectedCycle;
  String? _selectedLevel;
  String? _selectedBranch;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final all = await FirebaseService.loadAllStudents();
      _allStudents = all
          .where(
            (s) =>
                s['studentId'] != null &&
                !widget.excludeStudentIds.contains(s['studentId']),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ _loadStudents error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  bool get _levelHasBranches {
    if (_selectedLevel == null) return false;
    return SchoolData.hasBranches(_selectedLevel!);
  }

  List<String> get _availableClasses {
    if (_selectedLevel == null) return [];

    if (_levelHasBranches) {
      if (_selectedBranch == null) return [];
      return SchoolData.getClassesForBranch(_selectedLevel!, _selectedBranch!);
    }

    return SchoolData.getClassesForLevel(_selectedLevel!);
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_selectedCycle == null ||
        _selectedLevel == null ||
        _selectedClass == null) {
      return [];
    }

    return _allStudents.where((s) {
      if (s['cycle'] != _selectedCycle) return false;
      if (s['level'] != _selectedLevel) return false;
      if (s['className'] != _selectedClass) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('select_student')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.withOpacity(0.05),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCycle,
                        decoration: InputDecoration(
                          labelText: tr('cycle'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.school),
                        ),
                        items: SchoolData.cycles.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCycle = value;
                            _selectedLevel = null;
                            _selectedBranch = null;
                            _selectedClass = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_selectedCycle != null)
                        DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: InputDecoration(
                            labelText: tr('level'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.class_),
                          ),
                          items: SchoolData.levelsByCycle[_selectedCycle]!.map((
                            l,
                          ) {
                            return DropdownMenuItem(value: l, child: Text(l));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value;
                              _selectedBranch = null;
                              _selectedClass = null;
                            });
                          },
                        ),
                      const SizedBox(height: 12),
                      if (_levelHasBranches)
                        DropdownButtonFormField<String>(
                          value: _selectedBranch,
                          decoration: InputDecoration(
                            labelText: tr('branch'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.account_tree),
                          ),
                          items: SchoolData.getBranchesForLevel(_selectedLevel!)
                              .map((branch) {
                                return DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranch = value;
                              _selectedClass = null;
                            });
                          },
                        ),
                      if (_levelHasBranches) const SizedBox(height: 12),
                      if (_selectedLevel != null &&
                          (!_levelHasBranches || _selectedBranch != null))
                        DropdownButtonFormField<String>(
                          value: _selectedClass,
                          decoration: InputDecoration(
                            labelText: tr('class_'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.groups),
                          ),
                          items: _availableClasses.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredStudents.length} ${tr('students_count')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              AppTranslations.isArabic
                                  ? 'اختر المرحلة والسنة والقسم'
                                  : 'Sélectionnez le cycle, l\'année et la classe',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context, student);
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    (student['prenom'] as String)
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${student['prenom']} ${student['nom']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${student['cycle']} • ${student['level']} • ${student['className']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Icon(
                                  AppTranslations.isArabic
                                      ? Icons.arrow_back_ios
                                      : Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
