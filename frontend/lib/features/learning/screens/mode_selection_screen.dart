import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../models/question_set.dart';
import '../models/quiz_mode.dart';
import '../repositories/learning_repository.dart';
import '../widgets/mode_card.dart';
import 'quiz_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({
    super.key,
    required this.questionSet,
    required this.learningRepository,
  });

  final QuestionSet questionSet;
  final LearningRepository learningRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.modeSelectionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              l10n.modeSelectionHeading,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              questionSet.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ModeCard(
              icon: Icons.assignment_outlined,
              title: l10n.examMode,
              description: l10n.examModeDescription,
              actionLabel: l10n.startExamMode,
              highlighted: true,
              onPressed: () => _startQuiz(context, QuizMode.exam),
            ),
            const SizedBox(height: 14),
            ModeCard(
              icon: Icons.school_outlined,
              title: l10n.practiceMode,
              description: l10n.practiceModeDescription,
              actionLabel: l10n.startPracticeMode,
              onPressed: () => _startQuiz(context, QuizMode.practice),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, QuizMode quizMode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuizScreen(
          questionSet: questionSet,
          learningRepository: learningRepository,
          quizMode: quizMode,
        ),
      ),
    );
  }
}
