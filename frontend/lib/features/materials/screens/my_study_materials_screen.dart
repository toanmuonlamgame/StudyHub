import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../contribution/repositories/contribution_repository.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/study_material_submission.dart';
import 'study_material_editor_screen.dart';

class MyStudyMaterialsScreen extends StatefulWidget {
  const MyStudyMaterialsScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;

  @override
  State<MyStudyMaterialsScreen> createState() => _MyStudyMaterialsScreenState();
}

class _MyStudyMaterialsScreenState extends State<MyStudyMaterialsScreen> {
  late Future<List<StudyMaterialSubmission>> _submissions;
  String? _activeSubmissionId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.myStudyMaterials)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openEditor(),
      icon: const Icon(Icons.add_rounded),
      label: Text(context.l10n.addMaterial),
    ),
    body: SafeArea(
      child: FutureBuilder<List<StudyMaterialSubmission>>(
        future: _submissions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return StudyHubStateView(
              icon: Icons.cloud_off_outlined,
              title: context.l10n.materialSubmissionLoadError,
              tone: StudyHubStateTone.error,
              action: FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.tryAgain),
              ),
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return StudyHubStateView(
              icon: Icons.library_add_outlined,
              title: context.l10n.noMaterialSubmissions,
              message: context.l10n.noMaterialSubmissionsBody,
              action: FilledButton.icon(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.addMaterial),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                104,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _MaterialSubmissionCard(
                submission: items[index],
                busy: _activeSubmissionId == items[index].id,
                onEdit: () => _openEditor(items[index]),
                onDelete: () => _delete(items[index]),
                onSubmit: () => _submit(items[index]),
              ),
            ),
          );
        },
      ),
    ),
  );

  void _reload() => setState(() {
    _submissions = widget.contributionRepository.listMaterialSubmissions();
  });

  Future<void> _refresh() async {
    _reload();
    await _submissions;
  }

  Future<void> _openEditor([StudyMaterialSubmission? submission]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StudyMaterialEditorScreen(
          learningRepository: widget.learningRepository,
          contributionRepository: widget.contributionRepository,
          initialSubmission: submission,
        ),
      ),
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _delete(StudyMaterialSubmission submission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteMaterialDraft),
        content: Text(context.l10n.deleteMaterialDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.contributionDeleteDraft),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _perform(
      submission.id,
      () => widget.contributionRepository.deleteMaterialDraft(submission.id),
    );
  }

  Future<void> _submit(StudyMaterialSubmission submission) => _perform(
    submission.id,
    () => widget.contributionRepository.submitMaterialDraftForReview(
      submission.id,
    ),
  );

  Future<void> _perform(
    String submissionId,
    Future<Object?> Function() action,
  ) async {
    if (_activeSubmissionId != null) return;
    setState(() => _activeSubmissionId = submissionId);
    try {
      await action();
      if (mounted) {
        _reload();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.materialActionError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _activeSubmissionId = null);
      }
    }
  }
}

class _MaterialSubmissionCard extends StatelessWidget {
  const _MaterialSubmissionCard({
    required this.submission,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    required this.onSubmit,
  });

  final StudyMaterialSubmission submission;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  submission.draft.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Chip(label: Text(_statusLabel(context))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            submission.draft.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (submission.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              submission.rejectionReason!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (submission.canEdit) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                TextButton.icon(
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.contributionEditDraft),
                ),
                TextButton.icon(
                  onPressed: busy ? null : onSubmit,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(context.l10n.contributionSubmitForReview),
                ),
                IconButton(
                  tooltip: context.l10n.contributionDeleteDraft,
                  onPressed: busy ? null : onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  String _statusLabel(BuildContext context) => switch (submission.status) {
    StudyMaterialSubmissionStatus.draft => context.l10n.contributionDraft,
    StudyMaterialSubmissionStatus.pendingReview =>
      context.l10n.contributionPendingReview,
    StudyMaterialSubmissionStatus.published =>
      context.l10n.contributionApproved,
    StudyMaterialSubmissionStatus.rejected => context.l10n.contributionRejected,
  };
}
