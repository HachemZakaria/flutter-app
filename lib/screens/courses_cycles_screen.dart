import 'package:flutter/material.dart';
import '../data/app_translations.dart';
import 'content_levels_screen.dart';

class CoursesCyclesScreen extends StatelessWidget {
  const CoursesCyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentLevelsEntryScreen(
      moduleType: 'courses',
      moduleTitle: tr('courses'),
      moduleColor: Colors.indigo,
      moduleIcon: Icons.menu_book_rounded,
    );
  }
}
