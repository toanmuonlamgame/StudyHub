import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/contribution_submission.dart';
import '../repositories/contribution_repository.dart';
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
      icon: const Icon(Icons.add),
      label: Text(context.l10n.contributionCreateDraft),
    ),
    body: FutureBuilder<List<ContributionSubmission>>(
      future: _submissions,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: () => setState(_reload),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          );
        }
        final submissions = snapshot.data!;
        if (submissions.isEmpty) {
          return Center(child: Text(context.l10n.contributionNoItems));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: submissions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _SubmissionCard(
            submission: submissions[index],
            statusLabel: _statusLabel(submissions[index].status),
            onEdit: submissions[index].canEdit
                ? () => _edit(submissions[index])
                : null,
            onDelete: submissions[index].canEdit
                ? () => _delete(submissions[index])
                : null,
            onSubmit: submissions[index].canEdit
                ? () => _submit(submissions[index])
                : null,
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

  Future<void> _delete(ContributionSubmission submission) async {
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
    await widget.contributionRepository.deleteDraft(submission.id);
    if (mounted) setState(_reload);
  }

  Future<void> _submit(ContributionSubmission submission) async {
    await widget.contributionRepository.submitDraftForReview(submission.id);
    if (mounted) setState(_reload);
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
    this.onEdit,
    this.onDelete,
    this.onSubmit,
  });

  final ContributionSubmission submission;
  final String statusLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            submission.draft.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('${context.l10n.contributionStatus}: $statusLabel'),
          if (submission.rejectionReason case final reason?) ...[
            const SizedBox(height: 8),
            Text('${context.l10n.contributionRejectionReason}: $reason'),
          ],
          if (onEdit != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.contributionEditDraft),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.l10n.contributionDeleteDraft),
                ),
                FilledButton(
                  onPressed: onSubmit,
                  child: Text(context.l10n.contributionSubmitForReview),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
