import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../repositories/learning_repository.dart';
import 'question_set_list_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late Future<List<Subject>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = widget.learningRepository.getSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse subjects')),
      body: SafeArea(
        child: FutureBuilder<List<Subject>>(
          future: _subjectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _SubjectLoadError(onRetry: _retryLoadingSubjects);
            }

            final subjects = snapshot.data ?? const <Subject>[];
            if (subjects.isEmpty) {
              return const _EmptySubjects();
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: subjects.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
            );
          },
        ),
      ),
    );
  }

  void _retryLoadingSubjects() {
    setState(() {
      _subjectsFuture = widget.learningRepository.getSubjects();
    });
  }

  void _openSubject(BuildContext context, Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuestionSetListScreen(
          subject: subject,
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }
}

class _SubjectLoadError extends StatelessWidget {
  const _SubjectLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Subjects could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
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
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
