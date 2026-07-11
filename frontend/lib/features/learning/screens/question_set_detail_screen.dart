import 'package:flutter/material.dart';

import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../repositories/learning_repository.dart';
import '../widgets/learning_stat_chip.dart';
import 'mode_selection_screen.dart';

class QuestionSetDetailScreen extends StatelessWidget {
  const QuestionSetDetailScreen({
    super.key,
    required this.subject,
    required this.questionSet,
    required this.learningRepository,
    this.topic,
  });

  final Subject subject;
  final QuestionSet questionSet;
  final Topic? topic;
  final LearningRepository learningRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estimatedMinutes =
        questionSet.estimatedMinutes ??
        (questionSet.questionCount * 1.5).ceil();
    final difficulty = questionSet.difficulty ?? 'easy';

    return Scaffold(
      appBar: AppBar(title: const Text('Question set')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(questionSet.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    topic == null
                        ? subject.name
                        : '${subject.name} · ${topic!.name}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LearningStatChip(
                  icon: Icons.help_outline,
                  label: '${questionSet.questionCount} questions',
                ),
                LearningStatChip(
                  icon: Icons.schedule_outlined,
                  label: '$estimatedMinutes min',
                ),
                LearningStatChip(
                  icon: Icons.signal_cellular_alt,
                  label: _capitalize(difficulty),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text('About this question set', style: theme.textTheme.titleLarge),
            const SizedBox(height: 9),
            Text(
              questionSet.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Correct answers stay hidden until you submit or check an answer.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => _chooseMode(context),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Choose learning mode'),
            ),
          ],
        ),
      ),
    );
  }

  void _chooseMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ModeSelectionScreen(
          questionSet: questionSet,
          learningRepository: learningRepository,
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
