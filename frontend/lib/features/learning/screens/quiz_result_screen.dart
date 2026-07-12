import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_motion.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/answer_review.dart';
import '../models/quiz_mode.dart';
import '../models/quiz_result.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final modeLabel = result.quizMode == QuizMode.practice
        ? l10n.practiceMode
        : l10n.examMode;
    final message = result.percentageScore >= 80
        ? l10n.strongResultMessage
        : result.percentageScore >= 50
        ? l10n.goodResultMessage
        : l10n.learningResultMessage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          result.quizMode == QuizMode.practice
              ? l10n.practiceResult
              : l10n.examResult,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  modeLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(result.questionSetTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: result.percentageScore),
                        duration: AppMotion.duration(
                          context,
                          const Duration(milliseconds: 280),
                        ),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Text(
                          NumberFormat.percentPattern(
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(value / 100),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultStat(
                            label: l10n.correctAnswers,
                            value: result.correctCount.toString(),
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Expanded(
                          child: _ResultStat(
                            label: l10n.wrongAnswers,
                            value: result.wrongCount.toString(),
                            color: theme.colorScheme.error,
                          ),
                        ),
                        Expanded(
                          child: _ResultStat(
                            label: l10n.totalQuestions,
                            value: result.totalCount.toString(),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            TweenAnimationBuilder<double>(
              tween: Tween(end: 1),
              duration: AppMotion.duration(
                context,
                const Duration(milliseconds: 260),
              ),
              curve: Curves.easeOutCubic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.answerReview, style: theme.textTheme.titleLarge),
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
                ],
              ),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.backToQuestionSet),
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
    final l10n = context.l10n;
    final statusColor = answerReview.isCorrect
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
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
                  l10n.questionNumber(questionNumber),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                answerReview.isCorrect ? l10n.correct : l10n.incorrect,
                style: theme.textTheme.labelLarge?.copyWith(color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(answerReview.questionText, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            l10n.yourAnswer(
              answerReview.selectedAnswerText ?? l10n.notAnswered,
            ),
            style: TextStyle(
              color: answerReview.isCorrect
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.correctAnswer(answerReview.correctAnswerText),
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
