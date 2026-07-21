import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/app_locale.dart';
import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';
import '../auth/auth_scope.dart';
import '../contribution/repositories/contribution_repository.dart';
import '../profile/profile_screen.dart';
import '../saved/screens/saved_question_sets_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.localeSelection,
    required this.onLocaleSelected,
    required this.contributionRepository,
  });

  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection> onLocaleSelected;
  final ContributionRepository contributionRepository;

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.maybeOf(context);
    final user = authController?.user;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTab)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (authController != null) ...[
            StudyHubSectionHeader(title: context.l10n.account),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(user?.displayName ?? context.l10n.profile),
                    subtitle: user == null ? null : Text(user.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(
                          contributionRepository: contributionRepository,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.bookmarks_outlined),
                    title: Text(context.l10n.savedQuestionSets),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SavedQuestionSetsScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(context.l10n.logOut),
                    onTap: authController.logout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          StudyHubSectionHeader(title: context.l10n.languageSection),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                _LanguageTile(
                  label: context.l10n.systemDefault,
                  value: AppLocaleSelection.system,
                  selected: localeSelection,
                  onSelected: onLocaleSelected,
                ),
                _LanguageTile(
                  label: context.l10n.english,
                  value: AppLocaleSelection.english,
                  selected: localeSelection,
                  onSelected: onLocaleSelected,
                ),
                _LanguageTile(
                  label: context.l10n.vietnamese,
                  value: AppLocaleSelection.vietnamese,
                  selected: localeSelection,
                  onSelected: onLocaleSelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StudyHubSectionHeader(title: context.l10n.aboutStudyHub),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.l10n.aboutStudyHubBody),
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(context.l10n.appVersion),
                  trailing: const Text(AppInfo.version),
                ),
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: Text(context.l10n.privacySecurity),
                  subtitle: Text(context.l10n.privacySecurityNote),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final AppLocaleSelection value;
  final AppLocaleSelection selected;
  final ValueChanged<AppLocaleSelection> onSelected;
  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    title: Text(label),
    leading: Icon(
      value == AppLocaleSelection.system ? Icons.language : Icons.translate,
    ),
    trailing: Icon(
      value == selected ? Icons.check_circle : Icons.circle_outlined,
      color: value == selected ? Theme.of(context).colorScheme.primary : null,
    ),
    onTap: () => onSelected(value),
  );
}
