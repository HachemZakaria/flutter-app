import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import 'content_items_screen.dart';

class ContentTrimestresScreen extends StatelessWidget {
  final String moduleType;
  final String moduleTitle;
  final Color moduleColor;
  final String cycle;
  final String level;
  final String subject;
  final bool isReadOnly;

  const ContentTrimestresScreen({
    super.key,
    required this.moduleType,
    required this.moduleTitle,
    required this.moduleColor,
    required this.cycle,
    required this.level,
    required this.subject,
    this.isReadOnly = false,
  });

  String _getTrimestreTranslated(String trim) {
    switch (trim) {
      case 'Trimestre 1':
        return tr('trimester_1');
      case 'Trimestre 2':
        return tr('trimester_2');
      case 'Trimestre 3':
        return tr('trimester_3');
      default:
        return trim;
    }
  }

  @override
  Widget build(BuildContext context) {
    const trimestres = ['Trimestre 1', 'Trimestre 2', 'Trimestre 3'];

    return Scaffold(
      appBar: AppBar(
        title: Text('$moduleTitle - $subject'),
        backgroundColor: moduleColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: trimestres.length,
          itemBuilder: (context, index) {
            final trimestre = trimestres[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContentItemsScreen(
                      moduleType: moduleType,
                      moduleTitle: moduleTitle,
                      moduleColor: moduleColor,
                      cycle: cycle,
                      level: level,
                      subject: subject,
                      trimestre: trimestre,
                      isReadOnly: isReadOnly,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: moduleColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: moduleColor.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: moduleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.calendar_view_month, color: moduleColor),
                  ),
                  title: Text(
                    _getTrimestreTranslated(trimestre),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(
                    AppTranslations.isArabic
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: moduleColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
