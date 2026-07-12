import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
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
    final l10n = context.l10n;
    final estimatedMinutes =
        questionSet.estimatedMinutes ??
        (questionSet.questionCount * 1.5).ceil();
    final difficulty = questionSet.difficulty ?? 'easy';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.questionSetTitle)),
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
                        : '${subject.name} / ${topic!.name}',
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
                  label: l10n.questionCount(questionSet.questionCount),
                ),
                LearningStatChip(
                  icon: Icons.schedule_outlined,
                  label: l10n.minuteCount(estimatedMinutes),
                ),
                LearningStatChip(
                  icon: Icons.signal_cellular_alt,
                  label: _localizedDifficulty(context, difficulty),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(l10n.aboutQuestionSet, style: theme.textTheme.titleLarge),
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.answersHiddenDetail)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => _chooseMode(context),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.chooseLearningMode),
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

  String _localizedDifficulty(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value.toLowerCase()) {
      'medium' => l10n.difficultyMedium,
      'hard' => l10n.difficultyHard,
      _ => l10n.difficultyEasy,
    };
  }
}
