import 'package:flutter/material.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  static const _flowSteps = [
    'Subject',
    'Question Sets',
    'Quiz',
    'Result',
    'Upload Placeholder',
  ];

  static const _focusItems = [
    _FocusItem(
      icon: Icons.menu_book_outlined,
      title: 'Browse by subject',
      description:
          'Subject is required; school, program, major, and topic stay optional for V1.',
    ),
    _FocusItem(
      icon: Icons.quiz_outlined,
      title: 'Practice question sets',
      description:
          'Start with simple multiple-choice quizzes before adding advanced study flows.',
    ),
    _FocusItem(
      icon: Icons.upload_file_outlined,
      title: 'Prepare uploads',
      description:
          'Capture document, exam, or question set metadata as a placeholder.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('StudyHub')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'StudyHub',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mobile learning platform',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'V1 flow', color: theme.colorScheme.onSurface),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final step in _flowSteps)
                  Chip(
                    label: Text(step),
                    avatar: const Icon(Icons.arrow_forward, size: 16),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    side: BorderSide.none,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              title: 'First milestone focus',
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 12),
            for (final item in _focusItems) ...[
              _FocusCard(item: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.item});

  final _FocusItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusItem {
  const _FocusItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
