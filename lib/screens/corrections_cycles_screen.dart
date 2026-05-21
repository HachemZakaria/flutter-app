import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import 'content_levels_screen.dart';

class CorrectionsCyclesScreen extends StatelessWidget {
  const CorrectionsCyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentLevelsEntryScreen(
      moduleType: 'corrections',
      moduleTitle: tr('corrections'),
      moduleColor: Colors.deepPurple,
      moduleIcon: Icons.assignment_rounded,
    );
  }
}
