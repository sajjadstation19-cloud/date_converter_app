// lib/widgets/settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_converter_app/l10n/app_localizations.dart';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    String currentLang() {
      final l = localeProv.locale?.languageCode;
      if (l == 'ar') return 'ar';
      if (l == 'en') return 'en';
      return 'system';
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: .22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header + close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.settings,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    tooltip: t.close,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: .35),
              ),
              const SizedBox(height: 12),

              // Language
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.language,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(t.system)),
                  ButtonSegment(value: 'ar', label: Text(t.languageArabic)),
                  ButtonSegment(value: 'en', label: Text(t.languageEnglish)),
                ],
                selected: {currentLang()},
                onSelectionChanged: (sel) {
                  final v = sel.first;
                  Feedback.forTap(context);
                  if (v == 'system') {
                    localeProv.setLocale(null); // لغة النظام
                  } else {
                    localeProv.setLocale(Locale(v));
                  }
                },
              ),

              const SizedBox(height: 20),
              Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: .25),
              ),
              const SizedBox(height: 12),

              // Theme
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_6, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.theme,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(t.themeSystem)),
                  ButtonSegment(value: 'light', label: Text(t.themeLight)),
                  ButtonSegment(value: 'dark', label: Text(t.themeDark)),
                ],
                selected: {
                  switch (themeProv.themeMode) {
                    ThemeMode.light => 'light',
                    ThemeMode.dark => 'dark',
                    _ => 'system',
                  },
                },
                onSelectionChanged: (sel) {
                  final v = sel.first;
                  Feedback.forTap(context);
                  switch (v) {
                    case 'light':
                      themeProv.setThemeMode(ThemeMode.light);
                      break;
                    case 'dark':
                      themeProv.setThemeMode(ThemeMode.dark);
                      break;
                    default:
                      themeProv.setThemeMode(ThemeMode.system);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
