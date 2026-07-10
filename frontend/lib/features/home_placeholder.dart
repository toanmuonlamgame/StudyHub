import 'package:flutter/material.dart';

import 'learning/screens/subject_list_screen.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  static const _flowSteps = [
    'Subject',
    'Question Sets',
    'Quiz',
    'Result',
    'Upload Placeholder',
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
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a subject, explore question sets, and build a steady study habit.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => _openSubjects(context),
              icon: const Icon(Icons.school_outlined),
              label: const Text('Start learning'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'V1 learning path',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final step in _flowSteps)
                  Chip(
                    label: Text(step),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSubjects(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const SubjectListScreen()),
    );
  }
}
