import 'package:flutter/material.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class SelectChildrenScreen extends StatefulWidget {
  final List<Map<String, dynamic>> alreadySelected;

  const SelectChildrenScreen({super.key, this.alreadySelected = const []});

  @override
  State<SelectChildrenScreen> createState() => _SelectChildrenScreenState();
}

class _SelectChildrenScreenState extends State<SelectChildrenScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _selectedChildren = [];
  bool _isLoading = true;

  String? _selectedCycle;
  String? _selectedLevel;
  String? _selectedBranch;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _selectedChildren = List.from(widget.alreadySelected);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final all = await FirebaseService.loadAllStudents();
      _allStudents = all.where((s) => s['studentId'] != null).toList();
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

  bool _isSelected(Map<String, dynamic> student) {
    return _selectedChildren.any((c) => c['studentId'] == student['studentId']);
  }

  void _toggleStudent(Map<String, dynamic> student) {
    setState(() {
      if (_isSelected(student)) {
        _selectedChildren.removeWhere(
          (c) => c['studentId'] == student['studentId'],
        );
      } else {
        _selectedChildren.add(student);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('select_children')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _selectedChildren.isEmpty
                ? null
                : () {
                    Navigator.pop(context, _selectedChildren);
                  },
            icon: Icon(
              Icons.check,
              color: _selectedChildren.isEmpty ? Colors.white38 : Colors.white,
            ),
            label: Text(
              '${tr('validate')} (${_selectedChildren.length})',
              style: TextStyle(
                color: _selectedChildren.isEmpty
                    ? Colors.white38
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.green.withOpacity(0.05),
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
                if (_selectedChildren.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.green.withOpacity(0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedChildren.length} ${tr('children')} :',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _selectedChildren.map((child) {
                            return Chip(
                              label: Text(
                                '${child['prenom']} ${child['nom']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _selectedChildren.removeWhere(
                                    (c) => c['studentId'] == child['studentId'],
                                  );
                                });
                              },
                            );
                          }).toList(),
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
                            final isChecked = _isSelected(student);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isChecked
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.transparent,
                                ),
                              ),
                              color: isChecked
                                  ? Colors.green.withOpacity(0.05)
                                  : null,
                              child: CheckboxListTile(
                                value: isChecked,
                                onChanged: (_) => _toggleStudent(student),
                                title: Text(
                                  '${student['prenom']} ${student['nom']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${student['className']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: isChecked
                                      ? Colors.green
                                      : Colors.grey.shade300,
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
