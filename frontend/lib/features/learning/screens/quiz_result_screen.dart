import 'package:flutter/material.dart';

import '../models/answer_review.dart';
import '../models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});

  final QuizResult result;

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
              result.questionSetTitle,
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
            for (
              var index = 0;
              index < result.answerReviews.length;
              index++
            ) ...[
              _AnswerReviewCard(
                key: ValueKey(result.answerReviews[index].questionId),
                answerReview: result.answerReviews[index],
                questionNumber: index + 1,
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
    required this.answerReview,
    required this.questionNumber,
  });

  final AnswerReview answerReview;
  final int questionNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = answerReview.isCorrect
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
                  answerReview.isCorrect
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
                  answerReview.isCorrect ? 'Correct' : 'Incorrect',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              answerReview.questionText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your answer: '
              '${answerReview.selectedAnswerText ?? 'Not answered'}',
            ),
            const SizedBox(height: 6),
            Text('Correct answer: ${answerReview.correctAnswerText}'),
          ],
        ),
      ),
    );
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
