import 'package:flutter/material.dart';

import '../../core/app_locale.dart';
import '../../l10n/app_localizations_x.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({
    super.key,
    required this.localeSelection,
    required this.onLocaleSelected,
  });

  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection> onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTab)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.languageSection,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _LanguageOptionTile(
                            label: l10n.systemDefault,
                            value: AppLocaleSelection.system,
                            selectedValue: localeSelection,
                            onSelected: onLocaleSelected,
                          ),
                          _Divider(color: theme.colorScheme.outlineVariant),
                          _LanguageOptionTile(
                            label: l10n.english,
                            value: AppLocaleSelection.english,
                            selectedValue: localeSelection,
                            onSelected: onLocaleSelected,
                          ),
                          _Divider(color: theme.colorScheme.outlineVariant),
                          _LanguageOptionTile(
                            label: l10n.vietnamese,
                            value: AppLocaleSelection.vietnamese,
                            selectedValue: localeSelection,
                            onSelected: onLocaleSelected,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.aboutStudyHub,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsIntro,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.school_outlined),
                            title: Text(l10n.mobileLearningPlatform),
                            subtitle: Text(
                              l10n.mobileLearningPlatformDescription,
                            ),
                          ),
                          _Divider(color: theme.colorScheme.outlineVariant),
                          ListTile(
                            leading: const Icon(Icons.visibility_off_outlined),
                            title: Text(l10n.learningSafety),
                            subtitle: Text(l10n.learningSafetyDescription),
                          ),
                          _Divider(color: theme.colorScheme.outlineVariant),
                          ListTile(
                            leading: const Icon(Icons.key_off_outlined),
                            title: Text(l10n.dataSafety),
                            subtitle: Text(l10n.dataSafetyDescription),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.construction_outlined,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.activeDevelopment,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.activeDevelopmentDescription),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final AppLocaleSelection value;
  final AppLocaleSelection selectedValue;
  final ValueChanged<AppLocaleSelection> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      selected: selected,
      label: selected ? l10n.selectedLanguageSemantics(label) : label,
      child: ListTile(
        minTileHeight: 56,
        onTap: () => onSelected(value),
        leading: Icon(
          value == AppLocaleSelection.system
              ? Icons.language_outlined
              : Icons.translate_outlined,
        ),
        title: Text(label),
        trailing: selected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.circle_outlined),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 64, color: color);
  }
}
