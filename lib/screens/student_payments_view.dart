import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import '../services/firebase_service.dart';

class StudentPaymentsView extends StatefulWidget {
  final String studentName;
  final String className;

  const StudentPaymentsView({
    super.key,
    required this.studentName,
    required this.className,
  });

  @override
  State<StudentPaymentsView> createState() => _StudentPaymentsViewState();
}

class _StudentPaymentsViewState extends State<StudentPaymentsView> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  String get _key => '${widget.className}_${widget.studentName}';

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
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final list = await FirebaseService.loadStudentPayments(_key);
      _payments = list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('❌ _loadPayments error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  double get _totalDue => _payments.fold<double>(
    0,
    (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0),
  );

  double get _totalPaid => _payments.fold<double>(
    0,
    (sum, p) => sum + ((p['paid'] as num?)?.toDouble() ?? 0),
  );

  double get _remainder => _totalDue - _totalPaid;

  String get _status {
    if (_totalDue == 0)
      return AppTranslations.isArabic ? 'لا توجد رسوم' : 'Aucun frais';
    if (_totalPaid >= _totalDue) return tr('fully_paid');
    if (_totalPaid > 0) return tr('partially_paid');
    return tr('not_paid');
  }

  Color get _statusColor {
    if (_totalPaid >= _totalDue && _totalDue > 0) return Colors.green;
    if (_totalPaid > 0) return Colors.orange;
    if (_totalDue > 0) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('payments')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            widget.studentName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.className,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _statusColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _statusColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _amountCard(
                              tr('total_due'),
                              '${_totalDue.toStringAsFixed(0)} DA',
                              Colors.blue,
                              Icons.money,
                            ),
                            _amountCard(
                              tr('paid'),
                              '${_totalPaid.toStringAsFixed(0)} DA',
                              Colors.green,
                              Icons.check_circle,
                            ),
                            _amountCard(
                              tr('remaining'),
                              '${_remainder.toStringAsFixed(0)} DA',
                              _remainder > 0 ? Colors.red : Colors.green,
                              _remainder > 0
                                  ? Icons.warning
                                  : Icons.check_circle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_payments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.payments,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppTranslations.isArabic
                                ? 'لا يوجد دفع مسجل'
                                : 'Aucun paiement enregistré',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._payments.map((p) {
                      final amount = (p['amount'] as num?)?.toDouble() ?? 0;
                      final paid = (p['paid'] as num?)?.toDouble() ?? 0;
                      final rest = amount - paid;
                      final isFullyPaid = rest <= 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isFullyPaid
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isFullyPaid
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFullyPaid ? Icons.check_circle : Icons.pending,
                              color: isFullyPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            _getPaymentTypeTranslated(p['type'] ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${tr('amount')}: ${amount.toStringAsFixed(0)} DA',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${tr('paid')}: ${paid.toStringAsFixed(0)} DA',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (rest > 0)
                                Text(
                                  '${tr('remaining')}: ${rest.toStringAsFixed(0)} DA',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                '📅 ${p['date'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _amountCard(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
