import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../models/contribution_submission.dart';
import '../models/question_draft.dart';

class ContributionDetailScreen extends StatelessWidget {
  const ContributionDetailScreen({super.key, required this.submission});

  final ContributionSubmission submission;

  @override
  Widget build(BuildContext context) {
    final draft = submission.draft;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.contributionDetails)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _StatusChip(status: submission.status),
                const SizedBox(height: 14),
                Text(
                  draft.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (draft.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    draft.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  context.l10n.contributionQuestionCount(
                    draft.questions.length,
                  ),
                ),
                if (submission.rejectionReason case final reason?) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: Text(context.l10n.contributionRejectionReason),
                      subtitle: Text(reason),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  context.l10n.contributionReviewSubmission,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                for (
                  var index = 0;
                  index < draft.questions.length;
                  index++
                ) ...[
                  _QuestionCard(
                    number: index + 1,
                    question: draft.questions[index],
                  ),
                  if (index < draft.questions.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.number, required this.question});

  final int number;
  final QuestionDraft question;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.questionNumber(number),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(question.text, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final option in question.answerOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    option.isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 20,
                    color: option.isCorrect
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.text),
                        if (option.isCorrect)
                          Text(
                            context.l10n.correctChoice,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (question.explanation.trim().isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              context.l10n.explanation,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(question.explanation),
          ],
        ],
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ContributionStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status) {
      ContributionStatus.draft => (
        Icons.edit_note_rounded,
        context.l10n.contributionDraft,
        Theme.of(context).colorScheme.primary,
      ),
      ContributionStatus.pendingReview => (
        Icons.schedule_rounded,
        context.l10n.contributionPendingReview,
        Theme.of(context).colorScheme.tertiary,
      ),
      ContributionStatus.approved => (
        Icons.verified_rounded,
        context.l10n.contributionApproved,
        Colors.green.shade700,
      ),
      ContributionStatus.rejected => (
        Icons.report_outlined,
        context.l10n.contributionRejected,
        Theme.of(context).colorScheme.error,
      ),
    };
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Chip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text(label),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
    );
  }
}
