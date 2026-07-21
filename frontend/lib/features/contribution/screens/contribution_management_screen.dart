import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/contribution_submission.dart';
import '../repositories/contribution_repository.dart';
import 'contribution_detail_screen.dart';
import 'contribution_editor_screen.dart';

class ContributionManagementScreen extends StatefulWidget {
  const ContributionManagementScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;

  @override
  State<ContributionManagementScreen> createState() =>
      _ContributionManagementScreenState();
}

class _ContributionManagementScreenState
    extends State<ContributionManagementScreen> {
  late Future<List<ContributionSubmission>> _submissions;
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.myContributions)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      icon: const Icon(Icons.add_rounded),
      label: Text(context.l10n.contributionCreateDraft),
    ),
    body: FutureBuilder<List<ContributionSubmission>>(
      future: _submissions,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return StudyHubStateView(
            icon: Icons.cloud_off_outlined,
            title: context.l10n.contributionLoadError,
            message: context.l10n.checkConnectionBody,
            tone: StudyHubStateTone.error,
            action: FilledButton.icon(
              onPressed: () => setState(_reload),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.tryAgain),
            ),
          );
        }
        final submissions = snapshot.data ?? const [];
        if (submissions.isEmpty) {
          return StudyHubStateView(
            icon: Icons.post_add_outlined,
            title: context.l10n.contributionNoItems,
            message: context.l10n.contributionEmptyBody,
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: submissions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final submission = submissions[index];
                final busy = _busyIds.contains(submission.id);
                return _SubmissionCard(
                  submission: submission,
                  statusLabel: _statusLabel(submission.status),
                  busy: busy,
                  onOpen: () => _open(submission),
                  onEdit: submission.canEdit ? () => _edit(submission) : null,
                  onDelete: submission.canEdit
                      ? () => _delete(submission)
                      : null,
                  onSubmit: submission.canEdit
                      ? () => _submit(submission)
                      : null,
                );
              },
            ),
          ),
        );
      },
    ),
  );

  void _reload() =>
      _submissions = widget.contributionRepository.listSubmissions();

  Future<void> _create() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionEditorScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
        ),
      ),
    );
    if (mounted) setState(_reload);
  }

  Future<void> _edit(ContributionSubmission submission) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionEditorScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
          initialDraft: submission.draft,
          existingSubmissionId: submission.id,
        ),
      ),
    );
    if (mounted) setState(_reload);
  }

  void _open(ContributionSubmission submission) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionDetailScreen(submission: submission),
      ),
    );
  }

  Future<void> _delete(ContributionSubmission submission) async {
    final deletedMessage = context.l10n.contributionDeleted;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionDeleteDraft),
        content: Text(context.l10n.contributionDeleteDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.contributionDeleteDraft),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      submission.id,
      () => widget.contributionRepository.deleteDraft(submission.id),
      successMessage: deletedMessage,
    );
  }

  Future<void> _submit(ContributionSubmission submission) async {
    final successMessage = context.l10n.contributionSubmissionSuccessful;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionSubmitForReview),
        content: Text(context.l10n.contributionSubmitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send_outlined),
            label: Text(context.l10n.contributionSubmitForReview),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      submission.id,
      () => widget.contributionRepository.submitDraftForReview(submission.id),
      successMessage: successMessage,
    );
  }

  Future<void> _runAction(
    String submissionId,
    Future<Object?> Function() action, {
    required String successMessage,
  }) async {
    if (_busyIds.contains(submissionId)) return;
    setState(() => _busyIds.add(submissionId));
    try {
      await action();
      if (!mounted) return;
      setState(_reload);
      _showMessage(successMessage);
    } catch (_) {
      if (mounted) _showMessage(context.l10n.contributionActionError);
    } finally {
      if (mounted) setState(() => _busyIds.remove(submissionId));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(ContributionStatus status) => switch (status) {
    ContributionStatus.draft => context.l10n.contributionDraft,
    ContributionStatus.pendingReview => context.l10n.contributionPendingReview,
    ContributionStatus.approved => context.l10n.contributionApproved,
    ContributionStatus.rejected => context.l10n.contributionRejected,
  };
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.statusLabel,
    required this.busy,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
    this.onSubmit,
  });

  final ContributionSubmission submission;
  final String statusLabel;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final (statusIcon, statusColor) = switch (submission.status) {
      ContributionStatus.draft => (
        Icons.edit_note_rounded,
        Theme.of(context).colorScheme.primary,
      ),
      ContributionStatus.pendingReview => (
        Icons.schedule_rounded,
        Theme.of(context).colorScheme.tertiary,
      ),
      ContributionStatus.approved => (
        Icons.verified_rounded,
        Colors.green.shade700,
      ),
      ContributionStatus.rejected => (
        Icons.report_outlined,
        Theme.of(context).colorScheme.error,
      ),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      submission.draft.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(statusIcon, size: 17, color: statusColor),
                    label: Text(statusLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.contributionQuestionCount(
                  submission.draft.questions.length,
                ),
              ),
              if (submission.rejectionReason case final reason?) ...[
                const SizedBox(height: 8),
                Text(
                  '${context.l10n.contributionRejectionReason}: $reason',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : onOpen,
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(context.l10n.openDetails),
                  ),
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: busy ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(context.l10n.contributionEditDraft),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: busy ? null : onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(context.l10n.contributionDeleteDraft),
                    ),
                  if (onSubmit != null)
                    FilledButton.icon(
                      onPressed: busy ? null : onSubmit,
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(context.l10n.contributionSubmitForReview),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
