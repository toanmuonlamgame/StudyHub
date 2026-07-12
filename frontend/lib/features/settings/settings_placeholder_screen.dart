import 'package:flutter/material.dart';

import '../../core/app_locale.dart';
import '../../core/widgets/studyhub_ui.dart';
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
                    StudyHubSectionHeader(title: l10n.languageSection),
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
                    StudyHubSectionHeader(
                      title: l10n.aboutStudyHub,
                      subtitle: l10n.settingsIntro,
                    ),
                    const SizedBox(height: 12),
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
                            leading: const Icon(Icons.construction_outlined),
                            title: Text(l10n.activeDevelopment),
                            subtitle: Text(l10n.activeDevelopmentDescription),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    StudyHubSectionHeader(title: l10n.learningSafety),
                    const SizedBox(height: 10),
                    Card(
                      child: Column(
                        children: [
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
                    const SizedBox(height: 24),
                    StudyHubSectionHeader(title: l10n.futurePreferences),
                    const SizedBox(height: 10),
                    Card(
                      child: Column(
                        children: [
                          _UpcomingPreferenceTile(
                            icon: Icons.palette_outlined,
                            title: l10n.appearance,
                            subtitle: l10n.futurePreferenceDescription,
                            badge: l10n.comingSoon,
                          ),
                          _Divider(color: theme.colorScheme.outlineVariant),
                          _UpcomingPreferenceTile(
                            icon: Icons.notifications_none_outlined,
                            title: l10n.notifications,
                            subtitle: l10n.futurePreferenceDescription,
                            badge: l10n.comingSoon,
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

class _UpcomingPreferenceTile extends StatelessWidget {
  const _UpcomingPreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      enabled: false,
      label: context.l10n.upcomingFeatureSemantics(title),
      child: ListTile(
        enabled: false,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ComingSoonBadge(label: badge),
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
