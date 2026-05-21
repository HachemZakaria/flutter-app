import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/school_data.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final String cycle;
  final String level;
  final String className;

  const StudentPaymentsScreen({
    super.key,
    required this.cycle,
    required this.level,
    required this.className,
  });

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic> _allPayments = {};
  bool _isLoading = true;

  final _amountController = TextEditingController();
  final _paidController = TextEditingController();
  String _selectedType = 'Inscription';

  final List<String> _paymentTypes = [
    'Inscription',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Transport',
    'Cantine',
    'Autre',
  ];

  Color get _color => Color(SchoolData.cycleColors[widget.cycle] ?? 0xFF9E9E9E);

  String _getPaymentTypeTranslated(String type) {
    if (!AppTranslations.isArabic) return type;

    switch (type) {
      case 'Inscription':
        return 'التسجيل';
      case 'Septembre':
        return 'سبتمبر';
      case 'Octobre':
        return 'أكتوبر';
      case 'Novembre':
        return 'نوفمبر';
      case 'Décembre':
        return 'ديسمبر';
      case 'Janvier':
        return 'جانفي';
      case 'Février':
        return 'فيفري';
      case 'Mars':
        return 'مارس';
      case 'Avril':
        return 'أفريل';
      case 'Mai':
        return 'ماي';
      case 'Juin':
        return 'جوان';
      case 'Transport':
        return tr('transport');
      case 'Cantine':
        return tr('cantine');
      case 'Autre':
        return 'أخرى';
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final students = await FirebaseService.loadStudentsByClass(
        widget.className,
      );
      final payments = await FirebaseService.loadPaymentsForClass(
        widget.className,
      );
      setState(() {
        _students = students;
        _allPayments = payments;
      });
    } catch (e) {
      debugPrint('❌ _loadData error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePayments(String studentName) async {
    try {
      final key = _getKey(studentName);
      final list = (_allPayments[key] as List?) ?? [];
      await FirebaseService.saveStudentPayments(key, list);
    } catch (e) {
      debugPrint('❌ _savePayments error: $e');
    }
  }

  String _getKey(String studentName) {
    return '${widget.className}_$studentName';
  }

  List<Map<String, dynamic>> _getPayments(String studentName) {
    final key = _getKey(studentName);
    if (_allPayments[key] == null) return [];
    return (_allPayments[key] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  double _getTotalDue(String studentName) {
    final payments = _getPayments(studentName);
    return payments.fold<double>(
      0,
      (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0),
    );
  }

  double _getTotalPaid(String studentName) {
    final payments = _getPayments(studentName);
    return payments.fold<double>(
      0,
      (sum, p) => sum + ((p['paid'] as num?)?.toDouble() ?? 0),
    );
  }

  double _getRemainder(String studentName) {
    return _getTotalDue(studentName) - _getTotalPaid(studentName);
  }

  String _getStatus(String studentName) {
    final due = _getTotalDue(studentName);
    final paid = _getTotalPaid(studentName);
    if (due == 0) {
      return AppTranslations.isArabic ? 'لا توجد رسوم' : 'Aucun frais';
    }
    if (paid >= due) return tr('fully_paid');
    if (paid > 0) return tr('partially_paid');
    return tr('not_paid');
  }

  Color _getStatusColor(String status) {
    if (status == tr('fully_paid')) return Colors.green;
    if (status == tr('partially_paid')) return Colors.orange;
    if (status == tr('not_paid')) return Colors.red;
    return Colors.grey;
  }

  void _showAddPaymentDialog(String studentName) {
    _amountController.clear();
    _paidController.clear();
    _selectedType = 'Inscription';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              '${tr('payments')} - $studentName',
              style: const TextStyle(fontSize: 14),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: tr('payment_type'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _paymentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getPaymentTypeTranslated(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${tr('amount')} (DA)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _paidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${tr('paid')} (DA)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.payments),
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
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  final paid = double.tryParse(_paidController.text) ?? 0;

                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.isArabic
                              ? 'مبلغ غير صحيح'
                              : 'Montant invalide',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final key = _getKey(studentName);
                  _allPayments[key] ??= [];
                  (_allPayments[key] as List).add({
                    'type': _selectedType,
                    'amount': amount,
                    'paid': paid,
                    'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  });

                  await _savePayments(studentName);
                  if (mounted) {
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  void _showPaymentDetails(String studentName) {
    final payments = _getPayments(studentName);
    final totalDue = _getTotalDue(studentName);
    final totalPaid = _getTotalPaid(studentName);
    final remainder = _getRemainder(studentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(studentName, style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        tr('total_due'),
                        '${totalDue.toStringAsFixed(0)} DA',
                      ),
                      _summaryRow(
                        tr('paid'),
                        '${totalPaid.toStringAsFixed(0)} DA',
                        color: Colors.green,
                      ),
                      _summaryRow(
                        tr('remaining'),
                        '${remainder.toStringAsFixed(0)} DA',
                        color: remainder > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (payments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppTranslations.isArabic
                          ? 'لا يوجد دفع مسجل'
                          : 'Aucun paiement enregistré',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...payments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;
                    final pAmount = (p['amount'] as num?)?.toDouble() ?? 0;
                    final pPaid = (p['paid'] as num?)?.toDouble() ?? 0;
                    final pRest = pAmount - pPaid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            pRest <= 0 ? Icons.check_circle : Icons.pending,
                            color: pRest <= 0 ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getPaymentTypeTranslated(p['type'] ?? ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${pPaid.toStringAsFixed(0)} / ${pAmount.toStringAsFixed(0)} DA',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            p['date'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              (_allPayments[_getKey(studentName)] as List)
                                  .removeAt(index);
                              await _savePayments(studentName);
                              if (mounted) {
                                setState(() {});
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generateReceipt(studentName);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: Text('${tr('receipt')} PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReceipt(String studentName) async {
    final payments = _getPayments(studentName);
    final totalDue = _getTotalDue(studentName);
    final totalPaid = _getTotalPaid(studentName);
    final remainder = _getRemainder(studentName);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DAR ENNADJAH',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'REÇU DE PAIEMENT',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Élève : $studentName',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Classe : ${widget.className}'),
                      pw.Text('${widget.cycle} - ${widget.level}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _receiptCell('Type', isHeader: true),
                      _receiptCell('Montant', isHeader: true),
                      _receiptCell('Payé', isHeader: true),
                      _receiptCell('Reste', isHeader: true),
                      _receiptCell('Date', isHeader: true),
                    ],
                  ),
                  ...payments.map((p) {
                    final amount = (p['amount'] as num?)?.toDouble() ?? 0;
                    final paid = (p['paid'] as num?)?.toDouble() ?? 0;
                    return pw.TableRow(
                      children: [
                        _receiptCell(p['type'] ?? ''),
                        _receiptCell('${amount.toStringAsFixed(0)} DA'),
                        _receiptCell('${paid.toStringAsFixed(0)} DA'),
                        _receiptCell(
                          '${(amount - paid).toStringAsFixed(0)} DA',
                        ),
                        _receiptCell(p['date'] ?? ''),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total dû :'),
                        pw.Text(
                          '${totalDue.toStringAsFixed(0)} DA',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total payé :'),
                        pw.Text(
                          '${totalPaid.toStringAsFixed(0)} DA',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Reste à payer :',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${remainder.toStringAsFixed(0)} DA',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Signature du parent'),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Cachet de l\'établissement'),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Recu_$studentName',
    );
  }

  pw.Widget _receiptCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${tr('payments')} - ${widget.className}'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
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
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentName = '${student['prenom']} ${student['nom']}';
                final status = _getStatus(studentName);
                final statusColor = _getStatusColor(status);
                final remainder = _getRemainder(studentName);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => _showPaymentDetails(studentName),
                    leading: CircleAvatar(
                      backgroundColor: _color,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            if (remainder > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${tr('remaining')}: ${remainder.toStringAsFixed(0)} DA',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _showAddPaymentDialog(studentName),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 28,
                      ),
                      tooltip: tr('add'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
