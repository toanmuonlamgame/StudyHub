import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a mode')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'How do you want to learn?',
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
              title: 'Exam Mode',
              description:
                  'Answer every question, then submit once to see your score and full review.',
              actionLabel: 'Start Exam Mode',
              highlighted: true,
              onPressed: () => _startQuiz(context, QuizMode.exam),
            ),
            const SizedBox(height: 14),
            ModeCard(
              icon: Icons.school_outlined,
              title: 'Practice Mode',
              description:
                  'Check each answer immediately and learn from feedback before moving on.',
              actionLabel: 'Start Practice Mode',
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
