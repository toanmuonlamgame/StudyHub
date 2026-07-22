import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
import '../../core/device_permissions/device_permission_service.dart';
import '../notifications/study_reminder_scope.dart';
import '../advertising/advertising_scope.dart';

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
          const SizedBox(height: 24),
          StudyHubSectionHeader(title: context.l10n.studyReminders),
          const SizedBox(height: 10),
          _ReminderSettingsCard(),
          const SizedBox(height: 24),
          StudyHubSectionHeader(title: context.l10n.advertising),
          const SizedBox(height: 10),
          const _AdvertisingSettingsCard(),
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

class _AdvertisingSettingsCard extends StatefulWidget {
  const _AdvertisingSettingsCard();

  @override
  State<_AdvertisingSettingsCard> createState() =>
      _AdvertisingSettingsCardState();
}

class _AdvertisingSettingsCardState extends State<_AdvertisingSettingsCard> {
  bool _rewardLoading = false;

  @override
  Widget build(BuildContext context) {
    final service = AdvertisingScope.of(context);
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final status = service.sessionAdFree
            ? l10n.sessionAdFree
            : service.adsEnabled
            ? service.canRequestAds
                  ? l10n.adsEnabled
                  : l10n.adsWaitingForConsent
            : l10n.adsDisabled;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.ads_click_outlined),
                title: Text(l10n.advertisingStatus),
                subtitle: Text(status),
              ),
              if (service.isTestMode) ...[
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(l10n.testAdvertisingMode),
                  subtitle: Text(l10n.testAdvertisingModeBody),
                ),
              ],
              const Divider(height: 1, indent: 64),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.adPrivacy),
                subtitle: Text(l10n.adPrivacyBody),
              ),
              if (service.shouldShowAds) ...[
                const Divider(height: 1, indent: 64),
                ListTile(
                  leading: const Icon(Icons.ondemand_video_outlined),
                  title: Text(l10n.removeAdsForSession),
                  subtitle: Text(l10n.removeAdsForSessionBody),
                  trailing: _rewardLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton.tonal(
                          onPressed: _watchRewardedAd,
                          child: Text(l10n.watchAd),
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _watchRewardedAd() async {
    if (_rewardLoading) return;
    setState(() => _rewardLoading = true);
    final service = AdvertisingScope.of(context);
    final rewarded = await service.earnSessionAdFreeReward();
    if (!mounted) return;
    setState(() => _rewardLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rewarded ? context.l10n.rewardReceived : context.l10n.adUnavailable,
        ),
      ),
    );
  }
}

class _ReminderSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = StudyReminderScope.of(context);
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final settings = controller.settings;
        final permissionLabel = switch (controller.permissionState) {
          DevicePermissionState.granted => l10n.permissionGranted,
          DevicePermissionState.denied => l10n.permissionDenied,
          DevicePermissionState.permanentlyDenied =>
            l10n.permissionPermanentlyDenied,
          DevicePermissionState.unavailable => l10n.permissionUnavailable,
        };
        return Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.enableReminders),
                subtitle: Text(l10n.studyReminderReason),
                value: settings.enabled,
                onChanged: (value) => controller.setEnabled(
                  value,
                  title: l10n.studyReminderNotificationTitle,
                  body: l10n.studyReminderNotificationBody,
                ),
              ),
              const Divider(height: 1, indent: 64),
              ListTile(
                enabled: settings.enabled,
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l10n.reminderTime),
                trailing: Text(
                  TimeOfDay(
                    hour: settings.hour,
                    minute: settings.minute,
                  ).format(context),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.hour,
                      minute: settings.minute,
                    ),
                  );
                  if (time != null && context.mounted) {
                    await controller.setTime(
                      time.hour,
                      time.minute,
                      title: l10n.studyReminderNotificationTitle,
                      body: l10n.studyReminderNotificationBody,
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 64),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(l10n.notificationPermission),
                subtitle: Text(permissionLabel),
                trailing:
                    controller.permissionState ==
                            DevicePermissionState.denied ||
                        controller.permissionState ==
                            DevicePermissionState.permanentlyDenied
                    ? TextButton(
                        onPressed: controller.openSettings,
                        child: Text(l10n.openSettings),
                      )
                    : null,
              ),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(l10n.notificationScheduleFailed),
                ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.notification_add_outlined),
                  title: Text(l10n.testNotification),
                  onTap:
                      controller.permissionState ==
                          DevicePermissionState.granted
                      ? () => controller.showTest(
                          title: l10n.studyReminderNotificationTitle,
                          body: l10n.studyReminderNotificationBody,
                        )
                      : null,
                ),
            ],
          ),
        );
      },
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
