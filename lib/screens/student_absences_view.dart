import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class StudentAbsencesView extends StatefulWidget {
  final String studentName;
  final String className;

  const StudentAbsencesView({
    super.key,
    required this.studentName,
    required this.className,
  });

  @override
  State<StudentAbsencesView> createState() => _StudentAbsencesViewState();
}

class _StudentAbsencesViewState extends State<StudentAbsencesView> {
  List<Map<String, dynamic>> _absences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    List<Map<String, dynamic>> myAbsences = [];

    try {
      final allData = await FirebaseService.loadAttendanceForClass(
        widget.className,
      );

      allData.forEach((dateKey, records) {
        final dateStr = dateKey.replaceFirst('${widget.className}_', '');
        final attendanceRecords = Map<String, dynamic>.from(records as Map);

        if (attendanceRecords.containsKey(widget.studentName)) {
          final record = Map<String, dynamic>.from(
            attendanceRecords[widget.studentName],
          );
          final status = record['status'] ?? 'present';

          if (status != 'present') {
            myAbsences.add({
              'date': dateStr,
              'status': status,
              'justified': record['justified'] ?? false,
              'reason': record['reason'] ?? '',
            });
          }
        }
      });
    } catch (e) {
      debugPrint('❌ _loadAbsences error: $e');
    }

    myAbsences.sort((a, b) => b['date'].compareTo(a['date']));

    if (mounted) {
      setState(() {
        _absences = myAbsences;
        _isLoading = false;
      });
    }
  }

  int get _totalAbsences =>
      _absences.where((a) => a['status'] == 'absent').length;
  int get _totalLate => _absences.where((a) => a['status'] == 'late').length;
  int get _justifiedCount =>
      _absences.where((a) => a['justified'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_absences')),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard(
                        tr('absent'),
                        '$_totalAbsences',
                        Colors.red,
                        Icons.cancel,
                      ),
                      _statCard(
                        tr('late'),
                        '$_totalLate',
                        Colors.orange,
                        Icons.access_time,
                      ),
                      _statCard(
                        tr('justified'),
                        '$_justifiedCount',
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _absences.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.event_available,
                                size: 60,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tr('no_absences'),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _absences.length,
                          itemBuilder: (context, index) {
                            final absence = _absences[index];
                            final isAbsent = absence['status'] == 'absent';
                            final isJustified = absence['justified'] == true;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isAbsent
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isAbsent
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isAbsent ? Icons.cancel : Icons.access_time,
                                    color: isAbsent
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  isAbsent ? tr('absent') : tr('late'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isAbsent
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('📅 ${absence['date']}'),
                                    if ((absence['reason'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Text('📝 ${absence['reason']}'),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isJustified
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isJustified
                                        ? tr('justified')
                                        : tr('not_justified'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isJustified
                                          ? Colors.green
                                          : Colors.red,
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

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
