import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/models/quiz_mode.dart';
import '../models/completed_learning_session.dart';

class ProgressMetricCard extends StatelessWidget {
  const ProgressMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressSessionCard extends StatelessWidget {
  const ProgressSessionCard({
    super.key,
    required this.session,
    required this.formattedDate,
    required this.formattedPercentage,
  });

  final CompletedLearningSession session;
  final String formattedDate;
  final String formattedPercentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isPractice = session.quizMode == QuizMode.practice;
    final modeColor = isPractice
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final modeLabel = isPractice
        ? l10n.progressPracticeSession
        : l10n.progressExamSession;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPractice ? Icons.bolt_outlined : Icons.assignment_outlined,
              color: modeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.questionSetTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      modeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: modeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.progressScoreSummary(
                    session.correctCount,
                    session.totalQuestions,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedPercentage,
            style: theme.textTheme.titleMedium?.copyWith(
              color: modeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
