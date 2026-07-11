import 'package:flutter/material.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key, required this.onStartLearning});

  final VoidCallback onStartLearning;

  static const _learningModes = [
    _ModePreviewData(
      icon: Icons.assignment_outlined,
      title: 'Exam Mode',
      description: 'Answer the full set, then submit once for your result.',
    ),
    _ModePreviewData(
      icon: Icons.school_outlined,
      title: 'Practice Mode',
      description: 'Check each answer and learn from immediate feedback.',
    ),
    _ModePreviewData(
      icon: Icons.fact_check_outlined,
      title: 'Safe Review',
      description: 'See correct answers only after you submit or check.',
    ),
  ];

  static const _learningSteps = [
    'Pick a subject',
    'Choose a question set',
    'Practise or take an exam',
    'Review your results',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Study smarter, one set at a time.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose a subject, practise with focused question sets, and understand every result.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onStartLearning,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Start learning'),
                ),
                const SizedBox(height: 14),
                _SafetyNote(colorScheme: theme.colorScheme),
                const SizedBox(height: 36),
                const _SectionHeader(
                  title: 'Choose how you learn',
                  subtitle: 'Switch modes for each question set.',
                ),
                const SizedBox(height: 14),
                for (final mode in _learningModes) ...[
                  _ModePreview(data: mode),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 26),
                const _SectionHeader(
                  title: 'A simple learning flow',
                  subtitle: 'From choosing a subject to reviewing your work.',
                ),
                const SizedBox(height: 16),
                for (var index = 0; index < _learningSteps.length; index++)
                  _LearningStep(
                    number: index + 1,
                    label: _learningSteps[index],
                    isLast: index == _learningSteps.length - 1,
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
        Text('StudyHub', style: theme.textTheme.titleLarge),
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
              'Answers stay hidden until you submit or check.',
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
