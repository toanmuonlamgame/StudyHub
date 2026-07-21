import 'package:flutter/material.dart';

import '../../app/app_navigation.dart';
import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';
import '../attempts/attempt_repository_scope.dart';
import '../attempts/screens/exam_attempt_history_screen.dart';
import '../auth/auth_scope.dart';
import '../contribution/repositories/contribution_repository.dart';
import '../contribution/screens/contribution_management_screen.dart';
import '../learning/repositories/learning_repository.dart';
import '../saved/bookmark_scope.dart';
import '../saved/screens/saved_question_sets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<({int attempts, int submissions, int saved})>? _stats;
  bool _updatingProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stats ??= _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user!;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          child: Text(
                            user.displayName.isEmpty
                                ? '?'
                                : user.displayName.characters.first
                                      .toUpperCase(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.displayName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(user.email, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Chip(
                          avatar: const Icon(Icons.verified_user_outlined),
                          label: Text(context.l10n.accountActive),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _updatingProfile ? null : _editDisplayName,
                          icon: _updatingProfile
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.edit_outlined),
                          label: Text(context.l10n.editDisplayName),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StudyHubSectionHeader(title: context.l10n.accountOverview),
                const SizedBox(height: 10),
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
                    final stats = snapshot.data;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final width = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _Metric(
                              width: width,
                              icon: Icons.task_alt_rounded,
                              label: context.l10n.completedAttempts,
                              value: stats?.attempts.toString() ?? '-',
                            ),
                            _Metric(
                              width: width,
                              icon: Icons.bookmark_outline_rounded,
                              label: context.l10n.savedQuestionSets,
                              value: stats?.saved.toString() ?? '-',
                            ),
                            _Metric(
                              width: width,
                              icon: Icons.post_add_outlined,
                              label: context.l10n.submittedQuestionSets,
                              value: stats?.submissions.toString() ?? '-',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                StudyHubSectionHeader(title: context.l10n.yourLearning),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.history_rounded,
                        title: context.l10n.attemptHistory,
                        onTap: _openHistory,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.bookmarks_outlined,
                        title: context.l10n.savedQuestionSets,
                        onTap: _openSaved,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.post_add_outlined,
                        title: context.l10n.myContributions,
                        onTap: _openContributions,
                      ),
                      const Divider(height: 1, indent: 64),
                      _ActionTile(
                        icon: Icons.settings_outlined,
                        title: context.l10n.settingsTab,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
    final attemptsFuture = AttemptRepositoryScope.of(
      context,
    ).listExamAttempts();
    final submissionsFuture = widget.contributionRepository.listSubmissions();
    final savedFuture = BookmarkScope.of(context).listBookmarks();
    final attempts = await attemptsFuture;
    final submissions = await submissionsFuture;
    final saved = await savedFuture;
    return (
      attempts: attempts.length,
      submissions: submissions.length,
      saved: saved.length,
    );
  }

  void _reloadStats() => setState(() => _stats = _loadStats());

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(
      text: AuthScope.of(context).user!.displayName,
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editDisplayName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: context.l10n.displayName),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.saveChanges),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty || !mounted) return;
    setState(() => _updatingProfile = true);
    final success = await AuthScope.of(context).updateDisplayName(value.trim());
    if (!mounted) return;
    setState(() => _updatingProfile = false);
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.profileUpdateFailed)));
    }
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
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
    );
    if (mounted) _reloadStats();
  }

  Future<void> _openSaved() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SavedQuestionSetsScreen(
          learningRepository: widget.learningRepository,
        ),
      ),
    );
    if (mounted) _reloadStats();
  }

  Future<void> _openContributions() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionManagementScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
        ),
      ),
    );
    if (mounted) _reloadStats();
  }

  Future<void> _confirmLogout() async {
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
    if (confirmed == true && mounted) await AuthScope.of(context).logout();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
