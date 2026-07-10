import 'package:flutter/material.dart';

import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.questionSet,
    required this.result,
    required this.questions,
    required this.selectedAnswerIds,
  });

  final QuestionSet questionSet;
  final QuizResult result;
  final List<Question> questions;
  final Map<String, String> selectedAnswerIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = result.percentageScore.toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
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
            const SizedBox(height: 24),
            Text(
              '$score%',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your score',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            Card(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  _ResultRow(
                    label: 'Correct answers',
                    value: result.correctCount.toString(),
                  ),
                  const Divider(height: 1),
                  _ResultRow(
                    label: 'Wrong answers',
                    value: result.wrongCount.toString(),
                  ),
                  const Divider(height: 1),
                  _ResultRow(
                    label: 'Total questions',
                    value: result.totalCount.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Answer review',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < questions.length; index++) ...[
              _AnswerReviewCard(
                key: ValueKey(questions[index].id),
                question: questions[index],
                questionNumber: index + 1,
                selectedAnswerId: selectedAnswerIds[questions[index].id],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Question Set'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  const _AnswerReviewCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedAnswerId,
  });

  final Question question;
  final int questionNumber;
  final String? selectedAnswerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAnswer = _findAnswerById(selectedAnswerId);
    final correctAnswer = _findCorrectAnswer();
    final isCorrect = selectedAnswer?.isCorrect ?? false;
    final statusColor = isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: statusColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Question $questionNumber',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  isCorrect ? 'Correct' : 'Incorrect',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text('Your answer: ${selectedAnswer?.text ?? 'Not answered'}'),
            const SizedBox(height: 6),
            Text('Correct answer: ${correctAnswer?.text ?? 'Unavailable'}'),
          ],
        ),
      ),
    );
  }

  AnswerOption? _findAnswerById(String? answerOptionId) {
    if (answerOptionId == null) {
      return null;
    }

    for (final answerOption in question.answerOptions) {
      if (answerOption.id == answerOptionId) {
        return answerOption;
      }
    }

    return null;
  }

  AnswerOption? _findCorrectAnswer() {
    for (final answerOption in question.answerOptions) {
      if (answerOption.isCorrect) {
        return answerOption;
      }
    }

    return null;
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
