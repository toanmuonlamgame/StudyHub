import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key, required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final learningModes = [
      _ModePreviewData(
        icon: Icons.assignment_outlined,
        title: l10n.examMode,
        description: l10n.examModePreview,
      ),
      _ModePreviewData(
        icon: Icons.school_outlined,
        title: l10n.practiceMode,
        description: l10n.practiceModePreview,
      ),
      _ModePreviewData(
        icon: Icons.fact_check_outlined,
        title: l10n.safeReview,
        description: l10n.safeReviewPreview,
      ),
    ];
    final learningSteps = [
      l10n.pickSubjectStep,
      l10n.chooseQuestionSetStep,
      l10n.learnOrExamStep,
      l10n.reviewResultsStep,
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const _AppHeader(),
                const SizedBox(height: 34),
                Text(
                  l10n.homeHeadline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onStartLearning,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.startLearning),
                ),
                const SizedBox(height: 14),
                _SafetyNote(colorScheme: theme.colorScheme),
                const SizedBox(height: 36),
                _SectionHeader(
                  title: l10n.learningModes,
                  subtitle: l10n.learningModesSubtitle,
                ),
                const SizedBox(height: 14),
                for (final mode in learningModes) ...[
                  _ModePreview(data: mode),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 26),
                _SectionHeader(
                  title: l10n.howItWorks,
                  subtitle: l10n.howItWorksSubtitle,
                ),
                const SizedBox(height: 16),
                for (var index = 0; index < learningSteps.length; index++)
                  _LearningStep(
                    number: index + 1,
                    label: learningSteps[index],
                    isLast: index == learningSteps.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_stories_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(context.l10n.appTitle, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 19, color: colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.answersHiddenNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ModePreviewData {
  const _ModePreviewData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _ModePreview extends StatelessWidget {
  const _ModePreview({required this.data});

  final _ModePreviewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A171A21),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: theme.colorScheme.primary, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningStep extends StatelessWidget {
  const _LearningStep({
    required this.number,
    required this.label,
    required this.isLast,
  });

  final int number;
  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
