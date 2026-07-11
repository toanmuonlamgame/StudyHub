import 'package:flutter/material.dart';

import '../models/answer_check_result.dart';
import '../models/answer_option.dart';
import '../models/answer_review.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_mode.dart';
import '../models/quiz_result.dart';
import '../repositories/learning_repository.dart';
import '../widgets/answer_option_card.dart';
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
  int _examQuestionIndex = 0;

  int _practiceQuestionIndex = 0;
  String? _practiceSelectedAnswerId;
  AnswerCheckResult? _practiceAnswerCheckResult;
  bool _isCheckingPracticeAnswer = false;
  bool _practiceAnswerCheckFailed = false;
  final List<AnswerReview> _practiceAnswerReviews = [];

  bool get _isPracticeMode => widget.quizMode == QuizMode.practice;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isPracticeMode ? 'Practice Mode' : 'Exam Mode'),
      ),
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
    final question = questions[_examQuestionIndex];
    final isFirstQuestion = _examQuestionIndex == 0;
    final isLastQuestion = _examQuestionIndex == questions.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${_examQuestionIndex + 1} of ${questions.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(
              '${_examSelectedAnswerIds.length} answered',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _AnimatedQuizProgress(
          value: (_examQuestionIndex + 1) / questions.length,
        ),
        const SizedBox(height: 24),
        _QuestionCard(
          key: ValueKey(question.id),
          question: question,
          selectedAnswerId: _examSelectedAnswerIds[question.id],
          showError:
              _showValidation &&
              !_examSelectedAnswerIds.containsKey(question.id),
          enabled: !_isSubmittingExamModeQuiz,
          onSelected: (answerOptionId) {
            _selectExamAnswer(question.id, answerOptionId);
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (!isFirstQuestion) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmittingExamModeQuiz
                      ? null
                      : _previousExamQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: isFirstQuestion ? 1 : 1,
              child: FilledButton.icon(
                onPressed: _isSubmittingExamModeQuiz
                    ? null
                    : () => isLastQuestion
                          ? _submitExamModeQuiz(questions)
                          : _nextExamQuestion(question),
                icon: _isSubmittingExamModeQuiz
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                label: Text(
                  _isSubmittingExamModeQuiz
                      ? 'Submitting...'
                      : isLastQuestion
                      ? 'Submit Quiz'
                      : 'Next Question',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.questionSet.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeContent(BuildContext context, List<Question> questions) {
    final theme = Theme.of(context);
    final question = questions[_practiceQuestionIndex];
    final isLastQuestion = _practiceQuestionIndex == questions.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${_practiceQuestionIndex + 1} of ${questions.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(
              'Instant feedback',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _AnimatedQuizProgress(
          value: (_practiceQuestionIndex + 1) / questions.length,
        ),
        const SizedBox(height: 24),
        _QuestionCard(
          key: ValueKey(question.id),
          question: question,
          selectedAnswerId: _practiceSelectedAnswerId,
          showError: false,
          enabled:
              !_isCheckingPracticeAnswer && _practiceAnswerCheckResult == null,
          onSelected: (answerOptionId) {
            _checkPracticeAnswer(question, answerOptionId);
          },
          feedback: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: _buildPracticeFeedback(context, question),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _practiceAnswerCheckResult == null
              ? null
              : () => _continuePractice(questions),
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
        key: ValueKey('checking-practice-answer'),
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
        key: const ValueKey('practice-answer-error'),
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
      key: ValueKey('practice-feedback-${result.questionId}'),
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
      _practiceAnswerReviews.clear();
      _examQuestionIndex = 0;
      _questionsFuture = _loadQuestions();
    });
  }

  void _selectExamAnswer(String questionId, String answerOptionId) {
    if (_isSubmittingExamModeQuiz) {
      return;
    }

    setState(() {
      _examSelectedAnswerIds[questionId] = answerOptionId;
      _showValidation = false;
    });
  }

  void _nextExamQuestion(Question question) {
    if (!_examSelectedAnswerIds.containsKey(question.id)) {
      setState(() => _showValidation = true);
      return;
    }

    setState(() {
      _examQuestionIndex++;
      _showValidation = false;
    });
  }

  void _previousExamQuestion() {
    setState(() {
      _examQuestionIndex--;
      _showValidation = false;
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
        _practiceAnswerReviews.add(
          AnswerReview(
            questionId: question.id,
            questionText: question.text,
            selectedAnswerOptionId: result.selectedAnswerOptionId,
            selectedAnswerText: result.selectedAnswerText,
            correctAnswerOptionId: result.correctAnswerOptionId,
            correctAnswerText: result.correctAnswerText,
            isCorrect: result.isCorrect,
          ),
        );
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

  void _continuePractice(List<Question> questions) {
    if (_practiceQuestionIndex == questions.length - 1) {
      _showPracticeResult(questions.length);
      return;
    }

    setState(() {
      _practiceQuestionIndex++;
      _practiceSelectedAnswerId = null;
      _practiceAnswerCheckResult = null;
      _practiceAnswerCheckFailed = false;
    });
  }

  void _showPracticeResult(int totalQuestions) {
    final reviews = List<AnswerReview>.unmodifiable(_practiceAnswerReviews);
    final correctCount = reviews.where((review) => review.isCorrect).length;
    final result = QuizResult(
      questionSetId: widget.questionSet.id,
      questionSetTitle: widget.questionSet.title,
      correctCount: correctCount,
      wrongCount: totalQuestions - correctCount,
      totalCount: totalQuestions,
      percentageScore: totalQuestions == 0
          ? 0
          : correctCount / totalQuestions * 100,
      answerReviews: reviews,
      quizMode: QuizMode.practice,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => QuizResultScreen(result: result),
      ),
    );
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

class _AnimatedQuizProgress extends StatelessWidget {
  const _AnimatedQuizProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) => LinearProgressIndicator(
        value: animatedValue,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswerId,
    required this.showError,
    required this.enabled,
    required this.onSelected,
    this.feedback,
  });

  final Question question;
  final String? selectedAnswerId;
  final bool showError;
  final bool enabled;
  final ValueChanged<String> onSelected;
  final Widget? feedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
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
                      selected: answerOption.id == selectedAnswerId,
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
  const _AnswerOptionTile({
    required this.answerOption,
    required this.enabled,
    required this.selected,
  });

  final AnswerOption answerOption;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnswerOptionCard(
      answerOption: answerOption,
      selected: selected,
      enabled: enabled,
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
