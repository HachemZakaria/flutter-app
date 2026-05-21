import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  List<Map<String, dynamic>> _absences = [];
  bool _isLoading = true;

  final _studentController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isJustified = false;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  // ─── Charger ─────────────────────────────────────────
  Future<void> _loadAbsences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('absences_data');

    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _absences = decoded.map((e) {
          final item = Map<String, dynamic>.from(e);
          item['date'] = DateTime.parse(item['date'] as String);
          return item;
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─── Sauvegarder ────────────────────────────────────
  Future<void> _saveAbsences() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = _absences.map((item) {
      return {
        'student': item['student'],
        'date': (item['date'] as DateTime).toIso8601String(),
        'reason': item['reason'],
        'justified': item['justified'],
      };
    }).toList();
    await prefs.setString('absences_data', jsonEncode(toSave));
  }

  // ─── Ajouter ────────────────────────────────────────
  Future<void> _addAbsence() async {
    if (_studentController.text.isEmpty) return;

    setState(() {
      _absences.add({
        'student': _studentController.text.trim(),
        'date': _selectedDate,
        'reason': _reasonController.text.trim().isEmpty
            ? 'Non spécifié'
            : _reasonController.text.trim(),
        'justified': _isJustified,
      });
    });

    await _saveAbsences();

    _studentController.clear();
    _reasonController.clear();
    _selectedDate = DateTime.now();
    _isJustified = false;

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ─── Supprimer ──────────────────────────────────────
  void _deleteAbsence(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette absence ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _absences.removeAt(index);
              });
              await _saveAbsences();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Toggle justifié ────────────────────────────────
  Future<void> _toggleJustified(int index) async {
    setState(() {
      _absences[index]['justified'] = !_absences[index]['justified'];
    });
    await _saveAbsences();
  }

  // ─── Choisir date ───────────────────────────────────
  Future<void> _pickDate(StateSetter setDialogState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setDialogState(() {
        _selectedDate = picked;
      });
    }
  }

  // ─── Stats ──────────────────────────────────────────
  int get _totalAbsences => _absences.length;
  int get _justifiedCount =>
      _absences.where((a) => a['justified'] == true).length;
  int get _unjustifiedCount =>
      _absences.where((a) => a['justified'] == false).length;

  // ─── Dialog Ajouter ─────────────────────────────────
  void _showAddDialog() {
    _selectedDate = DateTime.now();
    _isJustified = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ajouter une absence'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _studentController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'élève',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickDate(setDialogState),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Motif (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Justifiée :'),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isJustified,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setDialogState(() {
                          _isJustified = val;
                        });
                      },
                    ),
                    Text(
                      _isJustified ? 'Oui ✅' : 'Non ❌',
                      style: TextStyle(
                        color: _isJustified ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: _addAbsence,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Ajouter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _studentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absences des Élèves'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        '$_totalAbsences',
                        Icons.event_busy,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Justifiées',
                        '$_justifiedCount',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Non just.',
                        '$_unjustifiedCount',
                        Icons.cancel,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _absences.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune absence',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _absences.length,
                          itemBuilder: (context, index) {
                            final item = _absences[index];
                            final isJustified = item['justified'] as bool;
                            final date = item['date'] as DateTime;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isJustified
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isJustified
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isJustified
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isJustified
                                        ? Colors.green
                                        : Colors.red,
                                    size: 28,
                                  ),
                                ),
                                title: Text(
                                  item['student'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(date),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.note,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(item['reason'] as String),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isJustified
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isJustified
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      onPressed: () => _toggleJustified(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => _deleteAbsence(index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
