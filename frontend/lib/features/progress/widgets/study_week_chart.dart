import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/completed_learning_session.dart';

class StudyWeekChart extends StatelessWidget {
  const StudyWeekChart({super.key, required this.sessions});

  final List<CompletedLearningSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day - 6 + index),
    );
    final counts = <DateTime, int>{for (final date in dates) date: 0};
    for (final session in sessions) {
      final local = session.completedAt.toLocal();
      final date = DateTime(local.year, local.month, local.day);
      if (counts.containsKey(date)) counts.update(date, (value) => value + 1);
    }
    final peak = counts.values.fold(1, math.max);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final day = DateFormat.E(locale);
    final fullDate = DateFormat.yMMMd(locale);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudyHubSectionHeader(
              title: l10n.studyWeekHeading,
              subtitle: l10n.studyWeekCaption,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final date in dates)
                  Expanded(
                    child: Semantics(
                      label:
                          '${fullDate.format(date)}: ${number.format(counts[date])}',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Text(
                              number.format(counts[date]),
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 5 + 48 * counts[date]! / peak,
                              constraints: const BoxConstraints(maxWidth: 25),
                              decoration: BoxDecoration(
                                color: counts[date] == 0
                                    ? colors.outlineVariant
                                    : colors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              day.format(date),
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
