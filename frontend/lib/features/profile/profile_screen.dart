import 'package:flutter/material.dart';
import '../auth/screens/change_password_dialog.dart';

import '../../app/app_navigation.dart';
import '../../core/app_design_tokens.dart';
import '../../core/app_locale.dart';
import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';
import '../attempts/attempt_repository_scope.dart';
import '../auth/auth_scope.dart';
import '../auth/models/auth_user.dart';
import '../contribution/repositories/contribution_repository.dart';
import '../learning/repositories/learning_repository.dart';
import '../media/media_repository_scope.dart';
import '../materials/screens/my_study_materials_screen.dart';
import '../saved/bookmark_scope.dart';
import '../settings/settings_screen.dart';
import 'services/avatar_service.dart';
import 'widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
    this.localeSelection = AppLocaleSelection.system,
    this.onLocaleSelected,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;
  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection>? onLocaleSelected;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<({int attempts, int submissions, int saved})>? _stats;
  bool _updatingProfile = false;
  bool _updatingAvatar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stats ??= _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.maybeOf(context)?.user ?? _demoUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          IconButton(
            tooltip: context.l10n.notifications,
            onPressed: _openSettings,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: context.l10n.settingsTab,
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.section,
              ),
              children: [
                _ProfileHeader(
                  updatingAvatar: _updatingAvatar,
                  onChangeAvatar: _changeAvatar,
                  onRemoveAvatar: user.avatarUrl == null ? null : _removeAvatar,
                ),
                const SizedBox(height: AppSpacing.xl),
                FutureBuilder<({int attempts, int submissions, int saved})>(
                  future: _stats,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return StudyHubStateView(
                        icon: Icons.sync_problem_outlined,
                        title: context.l10n.profileStatsError,
                        tone: StudyHubStateTone.error,
                        action: OutlinedButton.icon(
                          onPressed: _reloadStats,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.l10n.tryAgain),
                        ),
                      );
                    }
                    final value = snapshot.data;
                    return Row(
                      children: [
                        Expanded(
                          child: StudyHubMetric(
                            icon: Icons.upload_file_rounded,
                            label: context.l10n.uploaded,
                            value: value?.submissions,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: StudyHubMetric(
                            icon: Icons.task_alt_rounded,
                            label: context.l10n.completed,
                            value: value?.attempts,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: StudyHubMetric(
                            icon: Icons.bookmark_border_rounded,
                            label: context.l10n.saved,
                            value: value?.saved,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                StudyHubSectionHeader(title: context.l10n.personalInformation),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.badge_outlined,
                        title: context.l10n.editProfile,
                        subtitle: user.displayName,
                        onTap: _updatingProfile ? null : _editDisplayName,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.email_outlined,
                        title: context.l10n.email,
                        subtitle: user.email,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                StudyHubSectionHeader(title: context.l10n.yourLearning),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.folder_copy_outlined,
                        title: context.l10n.myExams,
                        onTap: _openMyExams,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.library_books_outlined,
                        title: context.l10n.myStudyMaterials,
                        subtitle: context.l10n.studyMaterialsOwnershipNote,
                        onTap: _openMyStudyMaterials,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.bookmarks_outlined,
                        title: context.l10n.savedExams,
                        onTap: _openMyExams,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.task_alt_rounded,
                        title: context.l10n.completedExams,
                        onTap: _openMyExams,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                StudyHubSectionHeader(title: context.l10n.account),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.notifications_outlined,
                        title: context.l10n.notifications,
                        onTap: _openSettings,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.security_outlined,
                        title: context.l10n.securityAccount,
                        onTap: () {
                          final controller = AuthScope.maybeOf(context);
                          if (controller?.canChangePassword != true) {
                            _openSettings();
                            return;
                          }
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                ChangePasswordDialog(controller: controller!),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.language_rounded,
                        title: context.l10n.languageSection,
                        onTap: _openSettings,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.info_outline_rounded,
                        title: context.l10n.aboutStudyHub,
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(context.l10n.logOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<({int attempts, int submissions, int saved})> _loadStats() async {
    final values = await Future.wait([
      AttemptRepositoryScope.of(context).listExamAttempts(),
      widget.contributionRepository.listSubmissions(),
      BookmarkScope.of(context).listBookmarks(),
    ]);
    return (
      attempts: values[0].length,
      submissions: values[1].length,
      saved: values[2].length,
    );
  }

  void _reloadStats() => setState(() => _stats = _loadStats());

  Future<void> _changeAvatar() async {
    if (_updatingAvatar) return;
    final service = AvatarService(
      mediaRepository: MediaRepositoryScope.of(context),
    );
    final authController = AuthScope.maybeOf(context);
    if (authController == null) {
      _showMessage(context.l10n.authSessionExpired);
      return;
    }
    final displayName = authController.user!.displayName;
    SelectedAvatar? pendingAvatar;
    setState(() => _updatingAvatar = true);
    try {
      final selected = await service.chooseFromGallery();
      pendingAvatar = selected;
      if (selected == null || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.avatarPreview),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Image.memory(selected.bytes, height: 220, fit: BoxFit.cover),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.progressCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.saveChanges),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final asset = await service.upload(selected, altText: displayName);
      final saved = await authController.updateAvatar(asset.mediaUrl);
      if (!saved) throw StateError('Avatar profile update failed.');
    } on AvatarValidationException catch (error) {
      if (mounted) {
        _showMessage(
          error.issue == AvatarValidationIssue.fileTooLarge
              ? context.l10n.fileTooLarge
              : context.l10n.unsupportedFile,
        );
      }
    } catch (_) {
      if (mounted) _showMessage(context.l10n.avatarUpdateFailed);
    } finally {
      if (pendingAvatar != null) await service.discard(pendingAvatar);
      if (mounted) setState(() => _updatingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    if (_updatingAvatar) return;
    final authController = AuthScope.maybeOf(context);
    if (authController == null) return;
    setState(() => _updatingAvatar = true);
    final removed = await authController.removeAvatar();
    if (!removed && mounted) _showMessage(context.l10n.avatarUpdateFailed);
    if (mounted) setState(() => _updatingAvatar = false);
  }

  Future<void> _editDisplayName() async {
    final authController = AuthScope.maybeOf(context);
    if (authController == null) return;
    final controller = TextEditingController(
      text: authController.user!.displayName,
    );
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.editProfile),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: context.l10n.displayName),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(context.l10n.saveChanges),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty || !mounted) return;
    setState(() => _updatingProfile = true);
    final updated = await authController.updateDisplayName(value);
    if (!updated && mounted) _showMessage(context.l10n.profileUpdateFailed);
    if (mounted) setState(() => _updatingProfile = false);
  }

  void _openMyExams() {
    AppNavigationScope.maybeOf(context)?.selectTab(2);
  }

  void _openMyStudyMaterials() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyStudyMaterialsScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
          localeSelection: widget.localeSelection,
          onLocaleSelected: widget.onLocaleSelected ?? (_) {},
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final authController = AuthScope.maybeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirmLogOut),
        content: Text(context.l10n.confirmLogOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && authController != null) {
      await authController.logout();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.updatingAvatar,
    required this.onChangeAvatar,
    this.onRemoveAvatar,
  });

  final bool updatingAvatar;
  final VoidCallback onChangeAvatar;
  final VoidCallback? onRemoveAvatar;

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.maybeOf(context)?.user ?? _demoUser;
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.feature),
        border: Border.all(color: colors.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer,
            colors.surface,
            colors.secondaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(user: user, radius: 44),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: IconButton.filled(
                    tooltip: context.l10n.changeAvatar,
                    onPressed: updatingAvatar ? null : onChangeAvatar,
                    icon: updatingAvatar
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 3),
            Text(user.email, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Chip(
              avatar: Icon(
                user.role == 'admin'
                    ? Icons.admin_panel_settings_outlined
                    : Icons.school_outlined,
              ),
              label: Text(
                user.role == 'admin'
                    ? context.l10n.administrator
                    : context.l10n.learner,
              ),
            ),
            if (onRemoveAvatar != null)
              TextButton.icon(
                onPressed: updatingAvatar ? null : onRemoveAvatar,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(context.l10n.removeAvatar),
              ),
          ],
        ),
      ),
    );
  }
}

final _demoUser = AuthUser(
  id: 'demo',
  email: 'demo@studyhub.local',
  displayName: 'StudyHub Learner',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
);

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
