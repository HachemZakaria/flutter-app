import 'package:flutter/material.dart';
import '../data/app_theme.dart';
import '../data/app_translations.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _changeLanguage(String lang) {
    MyApp.setLanguage(context, lang);
    setState(() {}); // ✅ Rafraîchir l'écran settings immédiatement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(tr('settings')),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.language,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('language'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Français
                  ListTile(
                    leading: const Text('🇫🇷', style: TextStyle(fontSize: 28)),
                    title: Text(
                      tr('french'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: AppTranslations.currentLanguage == 'fr'
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: AppTheme.textLight,
                          ),
                    onTap: () => _changeLanguage('fr'),
                  ),

                  const Divider(height: 1),

                  // Arabe
                  ListTile(
                    leading: const Text('🇩🇿', style: TextStyle(fontSize: 28)),
                    title: Text(
                      tr('arabic'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: AppTranslations.currentLanguage == 'ar'
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: AppTheme.textLight,
                          ),
                    onTap: () => _changeLanguage('ar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppTranslations.isArabic
                          ? '✓ تتم الترجمة فوراً'
                          : '✓ La traduction est instantanée',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
