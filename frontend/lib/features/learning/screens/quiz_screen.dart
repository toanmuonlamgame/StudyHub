import 'package:flutter/material.dart';

import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../repositories/learning_repository.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.questionSet,
    required this.learningRepository,
  });

  final QuestionSet questionSet;
  final LearningRepository learningRepository;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<String, String> _examSelectedAnswerIds = {};
  late Future<List<Question>> _questionsFuture;
  bool _showValidation = false;
  bool _isSubmittingExamModeQuiz = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: SafeArea(
        child: FutureBuilder<List<Question>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _QuizLoadError(onRetry: _retryLoadingQuestions);
            }

            final questions = snapshot.data ?? const <Question>[];
            if (questions.isEmpty) {
              return const _EmptyQuiz();
            }

            return _buildQuizContent(context, questions);
          },
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, List<Question> questions) {
    final theme = Theme.of(context);

    return ListView(
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
          '${_examSelectedAnswerIds.length} of ${questions.length} answered',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _examSelectedAnswerIds.length / questions.length,
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < questions.length; index++) ...[
          _QuestionCard(
            key: ValueKey(questions[index].id),
            question: questions[index],
            questionNumber: index + 1,
            totalQuestions: questions.length,
            selectedAnswerId: _examSelectedAnswerIds[questions[index].id],
            showError:
                _showValidation &&
                !_examSelectedAnswerIds.containsKey(questions[index].id),
            onSelected: (answerOptionId) {
              _selectAnswer(questions[index].id, answerOptionId);
            },
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 6),
        FilledButton.icon(
          onPressed: _isSubmittingExamModeQuiz
              ? null
              : () => _submitExamModeQuiz(questions),
          icon: _isSubmittingExamModeQuiz
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _isSubmittingExamModeQuiz ? 'Submitting...' : 'Submit Quiz',
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }

  Future<List<Question>> _loadQuestions() {
    return widget.learningRepository.getQuestionsByQuestionSetId(
      widget.questionSet.id,
    );
  }

  void _retryLoadingQuestions() {
    setState(() {
      _examSelectedAnswerIds.clear();
      _showValidation = false;
      _questionsFuture = _loadQuestions();
    });
  }

  void _selectAnswer(String questionId, String answerOptionId) {
    if (_isSubmittingExamModeQuiz) {
      return;
    }

    setState(() {
      _examSelectedAnswerIds[questionId] = answerOptionId;
    });
  }

  Future<void> _submitExamModeQuiz(List<Question> questions) async {
    if (_examSelectedAnswerIds.length != questions.length) {
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

    final examSelectedAnswerIds = Map<String, String>.unmodifiable(
      _examSelectedAnswerIds,
    );

    setState(() {
      _isSubmittingExamModeQuiz = true;
    });

    try {
      final result = await widget.learningRepository.submitQuiz(
        questionSetId: widget.questionSet.id,
        selectedAnswerOptionIdsByQuestionId: examSelectedAnswerIds,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => QuizResultScreen(result: result),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz could not be submitted.')),
      );
      setState(() {
        _isSubmittingExamModeQuiz = false;
      });
    }
  }
}

class _QuizLoadError extends StatelessWidget {
  const _QuizLoadError({required this.onRetry});

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
              'Questions could not be loaded.',
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
