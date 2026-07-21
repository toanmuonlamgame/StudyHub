import 'package:flutter/material.dart';

import '../../app/app_navigation.dart';
import '../../core/app_info.dart';
import '../../core/app_locale.dart';
import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';
import '../attempts/attempt_repository_scope.dart';
import '../attempts/screens/exam_attempt_history_screen.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_scope.dart';
import '../contribution/repositories/contribution_repository.dart';
import '../contribution/screens/contribution_management_screen.dart';
import '../learning/repositories/learning_repository.dart';
import '../profile/profile_screen.dart';
import '../saved/screens/saved_question_sets_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.localeSelection,
    required this.onLocaleSelected,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection> onLocaleSelected;
  final LearningRepository learningRepository;
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
                          learningRepository: learningRepository,
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
                        builder: (_) => SavedQuestionSetsScreen(
                          learningRepository: learningRepository,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text(context.l10n.attemptHistory),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ExamAttemptHistoryScreen(
                          repository: AttemptRepositoryScope.of(context),
                          onStartLearning: () {
                            AppNavigationScope.maybeOf(context)?.selectTab(1);
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.post_add_outlined),
                    title: Text(context.l10n.myContributions),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ContributionManagementScreen(
                          learningRepository: learningRepository,
                          contributionRepository: contributionRepository,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(context.l10n.logOut),
                    onTap: () => _confirmLogout(context, authController),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          StudyHubSectionHeader(title: context.l10n.socialSignIn),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              enabled: false,
              leading: const Icon(Icons.g_mobiledata_rounded, size: 30),
              title: Text(context.l10n.googleSignInComingSoon),
              subtitle: Text(context.l10n.socialSignInUnavailable),
              trailing: ComingSoonBadge(label: context.l10n.comingSoon),
            ),
          ),
          const SizedBox(height: 24),
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

  Future<void> _confirmLogout(
    BuildContext context,
    AuthController authController,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmLogOut),
        content: Text(context.l10n.confirmLogOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true) await authController.logout();
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
