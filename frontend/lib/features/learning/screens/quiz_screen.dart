import 'package:flutter/material.dart';

import '../models/answer_check_result.dart';
import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_mode.dart';
import '../repositories/learning_repository.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.questionSet,
    required this.learningRepository,
    this.quizMode = QuizMode.exam,
  });

  final QuestionSet questionSet;
  final LearningRepository learningRepository;
  final QuizMode quizMode;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<String, String> _examSelectedAnswerIds = {};
  late Future<List<Question>> _questionsFuture;
  bool _showValidation = false;
  bool _isSubmittingExamModeQuiz = false;

  int _practiceQuestionIndex = 0;
  String? _practiceSelectedAnswerId;
  AnswerCheckResult? _practiceAnswerCheckResult;
  bool _isCheckingPracticeAnswer = false;
  bool _practiceAnswerCheckFailed = false;

  bool get _isPracticeMode => widget.quizMode == QuizMode.practice;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isPracticeMode ? 'Practice Mode' : 'Quiz')),
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

            return _isPracticeMode
                ? _buildPracticeContent(context, questions)
                : _buildExamContent(context, questions);
          },
        ),
      ),
    );
  }

  Widget _buildExamContent(BuildContext context, List<Question> questions) {
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
            enabled: !_isSubmittingExamModeQuiz,
            onSelected: (answerOptionId) {
              _selectExamAnswer(questions[index].id, answerOptionId);
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

  Widget _buildPracticeContent(BuildContext context, List<Question> questions) {
    final theme = Theme.of(context);
    final question = questions[_practiceQuestionIndex];
    final isLastQuestion = _practiceQuestionIndex == questions.length - 1;

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
          'Check each answer as you learn.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_practiceQuestionIndex + 1) / questions.length,
        ),
        const SizedBox(height: 24),
        _QuestionCard(
          key: ValueKey(question.id),
          question: question,
          questionNumber: _practiceQuestionIndex + 1,
          totalQuestions: questions.length,
          selectedAnswerId: _practiceSelectedAnswerId,
          showError: false,
          enabled:
              !_isCheckingPracticeAnswer && _practiceAnswerCheckResult == null,
          onSelected: (answerOptionId) {
            _checkPracticeAnswer(question, answerOptionId);
          },
          feedback: _buildPracticeFeedback(context, question),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _practiceAnswerCheckResult == null
              ? null
              : () => _continuePractice(questions.length),
          icon: Icon(isLastQuestion ? Icons.done : Icons.arrow_forward),
          label: Text(isLastQuestion ? 'Finish Practice' : 'Next Question'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }

  Widget? _buildPracticeFeedback(BuildContext context, Question question) {
    final theme = Theme.of(context);

    if (_isCheckingPracticeAnswer) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Checking answer...'),
          ],
        ),
      );
    }

    if (_practiceAnswerCheckFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Answer could not be checked.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final selectedAnswerId = _practiceSelectedAnswerId;
                if (selectedAnswerId != null) {
                  _checkPracticeAnswer(question, selectedAnswerId);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final result = _practiceAnswerCheckResult;
    if (result == null) {
      return null;
    }

    final feedbackColor = result.isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.1),
        border: Border.all(color: feedbackColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.isCorrect ? Icons.check_circle : Icons.cancel,
            color: feedbackColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isCorrect ? 'Correct' : 'Incorrect',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: feedbackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Your answer: ${result.selectedAnswerText}'),
                Text('Correct answer: ${result.correctAnswerText}'),
              ],
            ),
          ),
        ],
      ),
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
      _practiceQuestionIndex = 0;
      _practiceSelectedAnswerId = null;
      _practiceAnswerCheckResult = null;
      _practiceAnswerCheckFailed = false;
      _questionsFuture = _loadQuestions();
    });
  }

  void _selectExamAnswer(String questionId, String answerOptionId) {
    if (_isSubmittingExamModeQuiz) {
      return;
    }

    setState(() {
      _examSelectedAnswerIds[questionId] = answerOptionId;
    });
  }

  Future<void> _checkPracticeAnswer(
    Question question,
    String answerOptionId,
  ) async {
    if (_isCheckingPracticeAnswer || _practiceAnswerCheckResult != null) {
      return;
    }

    setState(() {
      _practiceSelectedAnswerId = answerOptionId;
      _isCheckingPracticeAnswer = true;
      _practiceAnswerCheckFailed = false;
    });

    try {
      final result = await widget.learningRepository.checkAnswer(
        questionId: question.id,
        selectedAnswerOptionId: answerOptionId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _practiceAnswerCheckResult = result;
        _isCheckingPracticeAnswer = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingPracticeAnswer = false;
        _practiceAnswerCheckFailed = true;
      });
    }
  }

  void _continuePractice(int totalQuestions) {
    if (_practiceQuestionIndex == totalQuestions - 1) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _practiceQuestionIndex++;
      _practiceSelectedAnswerId = null;
      _practiceAnswerCheckResult = null;
      _practiceAnswerCheckFailed = false;
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
    required this.enabled,
    required this.onSelected,
    this.feedback,
  });

  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswerId;
  final bool showError;
  final bool enabled;
  final ValueChanged<String> onSelected;
  final Widget? feedback;

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
                if (enabled && value != null) {
                  onSelected(value);
                }
              },
              child: Column(
                children: [
                  for (final answerOption in question.answerOptions)
                    _AnswerOptionTile(
                      answerOption: answerOption,
                      enabled: enabled,
                    ),
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
            ?feedback,
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({required this.answerOption, required this.enabled});

  final AnswerOption answerOption;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: answerOption.id,
      enabled: enabled,
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
