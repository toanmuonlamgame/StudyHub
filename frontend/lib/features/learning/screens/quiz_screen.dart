import 'package:flutter/material.dart';

import '../data/mock_learning_data.dart';
import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_result.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questionSet});

  final QuestionSet questionSet;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<String, String> _selectedAnswerIds = {};
  late final List<Question> _questions;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _questions = getQuestionsByQuestionSetId(widget.questionSet.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: SafeArea(
        child: _questions.isEmpty
            ? const _EmptyQuiz()
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.questionSet.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedAnswerIds.length} of ${_questions.length} answered',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _selectedAnswerIds.length / _questions.length,
                  ),
                  const SizedBox(height: 24),
                  for (var index = 0; index < _questions.length; index++) ...[
                    _QuestionCard(
                      key: ValueKey(_questions[index].id),
                      question: _questions[index],
                      questionNumber: index + 1,
                      totalQuestions: _questions.length,
                      selectedAnswerId:
                          _selectedAnswerIds[_questions[index].id],
                      showError:
                          _showValidation &&
                          !_selectedAnswerIds.containsKey(_questions[index].id),
                      onSelected: (answerOptionId) {
                        _selectAnswer(_questions[index].id, answerOptionId);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 6),
                  FilledButton.icon(
                    onPressed: _submitQuiz,
                    icon: const Icon(Icons.check),
                    label: const Text('Submit Quiz'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _selectAnswer(String questionId, String answerOptionId) {
    setState(() {
      _selectedAnswerIds[questionId] = answerOptionId;
    });
  }

  void _submitQuiz() {
    if (_selectedAnswerIds.length != _questions.length) {
      setState(() {
        _showValidation = true;
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Answer every question before submitting.'),
        ),
      );
      return;
    }

    var correctCount = 0;

    for (final question in _questions) {
      final selectedAnswerId = _selectedAnswerIds[question.id];

      for (final answerOption in question.answerOptions) {
        if (answerOption.id == selectedAnswerId && answerOption.isCorrect) {
          correctCount++;
          break;
        }
      }
    }

    final totalCount = _questions.length;
    final result = QuizResult(
      questionSetId: widget.questionSet.id,
      correctCount: correctCount,
      wrongCount: totalCount - correctCount,
      totalCount: totalCount,
      percentageScore: correctCount / totalCount * 100,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => QuizResultScreen(
          questionSet: widget.questionSet,
          result: result,
          questions: _questions,
          selectedAnswerIds: Map.unmodifiable(_selectedAnswerIds),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswerId,
    required this.showError,
    required this.onSelected,
  });

  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswerId;
  final bool showError;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $questionNumber of $totalQuestions',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: selectedAnswerId,
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                }
              },
              child: Column(
                children: [
                  for (final answerOption in question.answerOptions)
                    _AnswerOptionTile(answerOption: answerOption),
                ],
              ),
            ),
            if (showError) ...[
              const SizedBox(height: 4),
              Text(
                'Choose one answer.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({required this.answerOption});

  final AnswerOption answerOption;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: answerOption.id,
      contentPadding: EdgeInsets.zero,
      title: Text(answerOption.text),
    );
  }
}

class _EmptyQuiz extends StatelessWidget {
  const _EmptyQuiz();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This question set does not have any questions yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
