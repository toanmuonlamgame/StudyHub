import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import '../../app/app_navigation.dart';
import '../../core/app_info.dart';
import '../../core/app_locale.dart';
import '../../core/text_size_preferences.dart';
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
  static const _supportEmail = String.fromEnvironment('STUDYHUB_SUPPORT_EMAIL');
  static const _privacyUrl = String.fromEnvironment('STUDYHUB_PRIVACY_URL');
  static const _termsUrl = String.fromEnvironment('STUDYHUB_TERMS_URL');
  static const _updatesUrl = String.fromEnvironment('STUDYHUB_UPDATES_URL');
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
    final textSize = TextSizePreferences.maybeOf(context);
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
          if (textSize != null) ...[
            StudyHubSectionHeader(title: context.l10n.appearance),
            const SizedBox(height: 10),
            DropdownButtonFormField<ThemeMode>(
              initialValue: textSize.themeMode,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.appearance),
              items: [
                for (final mode in ThemeMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(switch (mode) {
                      ThemeMode.system => context.l10n.textSizeSystem,
                      ThemeMode.light => context.l10n.lightAppearance,
                      ThemeMode.dark => context.l10n.darkAppearance,
                    }),
                  ),
              ],
              onChanged: (mode) {
                if (mode != null) textSize.onThemeChanged(mode);
              },
            ),
            const SizedBox(height: 24),
            StudyHubSectionHeader(title: context.l10n.textSize),
            const SizedBox(height: 10),
            DropdownButtonFormField<AppTextSize>(
              initialValue: textSize.value,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.textSize),
              items: [
                for (final size in AppTextSize.values)
                  DropdownMenuItem(
                    value: size,
                    child: Text(switch (size) {
                      AppTextSize.system => context.l10n.textSizeSystem,
                      AppTextSize.large => context.l10n.textSizeLarge,
                      AppTextSize.extraLarge => context.l10n.textSizeExtraLarge,
                    }),
                  ),
              ],
              onChanged: (size) {
                if (size != null) textSize.onChanged(size);
              },
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(
                    context,
                    context.l10n.privacySecurity,
                    context.l10n.studyHubPrivacyBody,
                    _privacyUrl,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.rule_outlined),
                  title: Text(context.l10n.studyHubUsageRules),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(
                    context,
                    context.l10n.studyHubUsageRules,
                    context.l10n.studyHubUsageBody,
                    _termsUrl,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.newspaper_outlined),
                  title: Text(context.l10n.studyHubUpdates),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(
                    context,
                    context.l10n.studyHubUpdates,
                    context.l10n.studyHubUpdatesBody,
                    _updatesUrl,
                  ),
                ),
                if (RegExp(
                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                ).hasMatch(_supportEmail)) ...[
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.support_agent_outlined),
                    title: Text(context.l10n.contactSupport),
                    subtitle: Text(_supportEmail),
                    onTap: () => _openLink(
                      context,
                      Uri(
                        scheme: 'mailto',
                        path: _supportEmail,
                        query:
                            'subject=${Uri.encodeComponent(context.l10n.reportIssueEmail)}',
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: context.l10n.copySupportEmail,
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () async {
                        try {
                          await Clipboard.setData(
                            const ClipboardData(text: _supportEmail),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.supportEmailCopied),
                            ),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: SelectableText(_supportEmail)),
                          );
                        }
                      },
                    ),
                  ),
                ],
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

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // The platform may not have an email or browser handler.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.unableToOpenPublicLink)),
    );
  }

  void _showInfo(
    BuildContext context,
    String title,
    String body,
    String publicUrl,
  ) {
    final uri = Uri.tryParse(publicUrl);
    final canOpen =
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SelectableText(body),
                    if (canOpen) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _openLink(context, uri),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(context.l10n.openOfficialPage),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
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
