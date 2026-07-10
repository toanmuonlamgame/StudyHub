import 'package:flutter/material.dart';

import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';

class QuestionSetDetailScreen extends StatelessWidget {
  const QuestionSetDetailScreen({
    super.key,
    required this.subject,
    required this.questionSet,
    this.topic,
  });

  final Subject subject;
  final QuestionSet questionSet;
  final Topic? topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Question Set')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              questionSet.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(subject.name),
                ),
                if (topic != null)
                  Chip(
                    avatar: const Icon(Icons.label_outline, size: 18),
                    label: Text(topic!.name),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'About this question set',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              questionSet.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: theme.colorScheme.surface,
              child: ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.primary,
                ),
                title: Text('${questionSet.questionCount} questions'),
                subtitle: const Text('Simple multiple-choice format'),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => _showQuizPlaceholder(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Quiz'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuizPlaceholder(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Quiz flow will be added in the next step.'),
      ),
    );
  }
}
