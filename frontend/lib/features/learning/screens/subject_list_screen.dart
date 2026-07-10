import 'package:flutter/material.dart';

import '../data/mock_learning_data.dart';
import '../models/subject.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key, this.subjects = mockSubjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: SafeArea(
        child: subjects.isEmpty
            ? const _EmptySubjects()
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: subjects.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const _SubjectListHeader();
                  }

                  final subject = subjects[index - 1];
                  return _SubjectCard(
                    subject: subject,
                    onTap: () => _openSubject(context, subject),
                  );
                },
              ),
      ),
    );
  }

  void _openSubject(BuildContext context, Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _QuestionSetPlaceholderScreen(subject: subject),
      ),
    );
  }
}

class _SubjectListHeader extends StatelessWidget {
  const _SubjectListHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a subject',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start with a subject to find question sets for your next study session.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = _buildMetadata(subject);

    return Semantics(
      button: true,
      label: 'Open ${subject.name}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subject.description != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          subject.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (metadata != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          metadata,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _buildMetadata(Subject subject) {
    final parts = <String>[];

    if (subject.school != null) {
      parts.add('School: ${subject.school}');
    }
    if (subject.program != null) {
      parts.add('Program: ${subject.program}');
    }
    if (subject.major != null) {
      parts.add('Major: ${subject.major}');
    }

    return parts.isEmpty ? null : parts.join(' | ');
  }
}

class _EmptySubjects extends StatelessWidget {
  const _EmptySubjects();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No subjects are available yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _QuestionSetPlaceholderScreen extends StatelessWidget {
  const _QuestionSetPlaceholderScreen({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Question Sets')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: theme.colorScheme.primary,
                  size: 44,
                ),
                const SizedBox(height: 16),
                Text(
                  subject.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question set browsing will be added in the next step.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
