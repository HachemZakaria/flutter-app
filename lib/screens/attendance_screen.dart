import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;

  const AttendanceScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> _students = [];
  Map<String, Map<String, dynamic>> _attendance = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  String get _dateKey =>
      '${widget.className}_${DateFormat('yyyy-MM-dd').format(_selectedDate)}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadStudents();
    await _loadAttendanceForDate();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    try {
      final students = await FirebaseService.loadStudentsByClass(
        widget.className,
      );
      setState(() => _students = students);
    } catch (e) {
      debugPrint('❌ _loadStudents error: $e');
    }
  }

  Future<void> _loadAttendanceForDate() async {
    try {
      final saved = await FirebaseService.loadAttendanceForDate(_dateKey);

      final tempAttendance = <String, Map<String, dynamic>>{};

      saved.forEach((studentName, record) {
        tempAttendance[studentName] = Map<String, dynamic>.from(record);
      });

      for (final student in _students) {
        final studentName = '${student['prenom']} ${student['nom']}';
        tempAttendance.putIfAbsent(
          studentName,
          () => {'status': 'present', 'justified': false, 'reason': ''},
        );
      }

      setState(() => _attendance = tempAttendance);
    } catch (e) {
      debugPrint('❌ _loadAttendanceForDate error: $e');
    }
  }

  Future<void> _saveAttendance() async {
    try {
      await FirebaseService.saveAttendance(_dateKey, _attendance);
    } catch (e) {
      debugPrint('❌ _saveAttendance error: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadData();
    }
  }

  Future<void> _setStatus(String studentName, String status) async {
    setState(() {
      _attendance[studentName] ??= {
        'status': 'present',
        'justified': false,
        'reason': '',
      };
      _attendance[studentName]!['status'] = status;
      if (status == 'present') {
        _attendance[studentName]!['justified'] = false;
        _attendance[studentName]!['reason'] = '';
      }
    });
    await _saveAttendance();
  }

  Future<void> _editReason(String studentName) async {
    final current = _attendance[studentName]!;
    final controller = TextEditingController(
      text: current['reason']?.toString() ?? '',
    );
    bool justified = current['justified'] == true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(studentName, style: const TextStyle(fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  current['status'] == 'absent' ? tr('absent') : tr('late'),
                  style: TextStyle(
                    color: current['status'] == 'absent'
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: tr('reason'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${tr('justified')} :'),
                    const SizedBox(width: 8),
                    Switch(
                      value: justified,
                      onChanged: (value) {
                        setDialogState(() => justified = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _attendance[studentName]!['justified'] = justified;
                    _attendance[studentName]!['reason'] = controller.text
                        .trim();
                  });
                  await _saveAttendance();
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _color),
                child: Text(
                  tr('save'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markAllPresent() async {
    for (final student in _students) {
      final studentName = '${student['prenom']} ${student['nom']}';
      _attendance[studentName] = {
        'status': 'present',
        'justified': false,
        'reason': '',
      };
    }
    setState(() {});
    await _saveAttendance();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.isArabic
                ? 'تم تعليم جميع التلاميذ كحاضرين'
                : 'Tous les élèves sont marqués présents',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  int get _presentCount =>
      _attendance.values.where((e) => e['status'] == 'present').length;
  int get _absentCount =>
      _attendance.values.where((e) => e['status'] == 'absent').length;
  int get _lateCount =>
      _attendance.values.where((e) => e['status'] == 'late').length;

  Widget _buildStatusButton({
    required String studentName,
    required String status,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final currentStatus = _attendance[studentName]?['status'] ?? 'present';
    final isSelected = currentStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setStatus(studentName, status),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'absent':
        return tr('absent');
      case 'late':
        return tr('late');
      default:
        return tr('present');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            tooltip: tr('date'),
          ),
          IconButton(
            onPressed: _markAllPresent,
            icon: const Icon(Icons.refresh),
            tooltip: tr('present'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? Center(
              child: Text(
                tr('no_students'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: _color.withOpacity(0.05),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.cycle,
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.level,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildStatCard(
                        tr('present'),
                        '$_presentCount',
                        Colors.green,
                        Icons.check_circle,
                      ),
                      _buildStatCard(
                        tr('absent'),
                        '$_absentCount',
                        Colors.red,
                        Icons.cancel,
                      ),
                      _buildStatCard(
                        tr('late'),
                        '$_lateCount',
                        Colors.orange,
                        Icons.access_time,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final studentName =
                          '${student['prenom']} ${student['nom']}';
                      final record =
                          _attendance[studentName] ??
                          {
                            'status': 'present',
                            'justified': false,
                            'reason': '',
                          };
                      final status = record['status'] ?? 'present';
                      final justified = record['justified'] == true;
                      final reason = record['reason']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _color,
                                    radius: 18,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _statusText(status),
                                          style: TextStyle(
                                            color: _statusColor(status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if ((status == 'absent' ||
                                                status == 'late') &&
                                            (reason.isNotEmpty || justified))
                                          Text(
                                            '${justified ? tr('justified') : tr('not_justified')}${reason.isNotEmpty ? " • $reason" : ""}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (status == 'absent' || status == 'late')
                                    IconButton(
                                      onPressed: () => _editReason(studentName),
                                      icon: const Icon(
                                        Icons.edit_note,
                                        color: Colors.blueGrey,
                                      ),
                                      tooltip: tr('reason'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildStatusButton(
                                    studentName: studentName,
                                    status: 'present',
                                    label: tr('present'),
                                    color: Colors.green,
                                    icon: Icons.check_circle,
                                  ),
                                  _buildStatusButton(
                                    studentName: studentName,
                                    status: 'absent',
                                    label: tr('absent'),
                                    color: Colors.red,
                                    icon: Icons.cancel,
                                  ),
                                  _buildStatusButton(
                                    studentName: studentName,
                                    status: 'late',
                                    label: tr('late'),
                                    color: Colors.orange,
                                    icon: Icons.access_time,
                                  ),
                                ],
                              ),
                            ],
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
