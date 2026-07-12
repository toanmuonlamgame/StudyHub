import 'package:flutter/material.dart';

import '../../core/widgets/studyhub_ui.dart';
import '../../l10n/app_localizations_x.dart';

class ProgressPlaceholderScreen extends StatelessWidget {
  const ProgressPlaceholderScreen({super.key, required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final metrics = [
      (Icons.history_outlined, l10n.recentResults),
      (Icons.track_changes_outlined, l10n.accuracy),
      (Icons.task_alt_outlined, l10n.completedSets),
      (Icons.calendar_month_outlined, l10n.learningActivity),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTab)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              key: const ValueKey('progress-list'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                StudyHubSectionHeader(
                  title: l10n.progressOverview,
                  subtitle: l10n.progressOverviewSubtitle,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final width = (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      key: const ValueKey('progress-empty-metrics'),
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final metric in metrics)
                          SizedBox(
                            width: width,
                            child: EmptyMetricCard(
                              icon: metric.$1,
                              label: metric.$2,
                              emptyLabel: l10n.noDataYet,
                              comingSoonLabel: l10n.comingSoon,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StudyHubIconSurface(
                            icon: Icons.menu_book_outlined,
                            foregroundColor: theme.colorScheme.onPrimary,
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.progressStartTitle,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.progressStartBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        key: const ValueKey('progress-start-learning'),
                        onPressed: onStartLearning,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.startLearning),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
