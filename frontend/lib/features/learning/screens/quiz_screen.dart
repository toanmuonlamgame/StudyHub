import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_motion.dart';
import '../../../core/device_feedback.dart';
import '../../media/widgets/study_media_image.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/answer_check_result.dart';
import '../models/answer_option.dart';
import '../models/answer_review.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/quiz_mode.dart';
import '../models/quiz_result.dart';
import '../repositories/learning_repository.dart';
import '../widgets/answer_option_card.dart';
import '../widgets/learning_state_view.dart';
import 'quiz_result_screen.dart';
import '../../attempts/models/exam_attempt.dart';

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
  bool _isSubmittingExamModeQuiz = false;
  bool _isConfirmingExamSubmission = false;
  bool _isConfirmingDiscard = false;
  bool _allowPop = false;
  int _examQuestionIndex = 0;
  late final DateTime _examStartedAt;
  late final String _examSubmissionId;

  int _practiceQuestionIndex = 0;
  String? _practiceSelectedAnswerId;
  AnswerCheckResult? _practiceAnswerCheckResult;
  bool _isCheckingPracticeAnswer = false;
  bool _isCompletingPractice = false;
  bool _practiceAnswerCheckFailed = false;
  final List<AnswerReview> _practiceAnswerReviews = [];

  bool get _isPracticeMode => widget.quizMode == QuizMode.practice;
  bool get _isExamBusy =>
      _isSubmittingExamModeQuiz || _isConfirmingExamSubmission;
  bool get _hasMeaningfulProgress => _isPracticeMode
      ? _practiceSelectedAnswerId != null || _practiceAnswerReviews.isNotEmpty
      : _examSelectedAnswerIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _examStartedAt = DateTime.now();
    _examSubmissionId =
        '${widget.questionSet.id}-${_examStartedAt.microsecondsSinceEpoch}';
    _questionsFuture = _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: _allowPop || !_hasMeaningfulProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSubmittingExamModeQuiz && !_isConfirmingDiscard) {
          _confirmDiscardAttempt();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isPracticeMode ? l10n.practiceMode : l10n.examMode),
        ),
        body: SafeArea(
          child: FutureBuilder<List<Question>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return LearningLoadingState(message: l10n.loadingQuestions);
              }

              if (snapshot.hasError) {
                return LearningErrorState(
                  title: l10n.questionsLoadErrorTitle,
                  message: l10n.connectionRetryMessage,
                  onRetry: _retryLoadingQuestions,
                );
              }

              final questions = snapshot.data ?? const <Question>[];
              if (questions.isEmpty) {
                return LearningEmptyState(
                  icon: Icons.quiz_outlined,
                  title: l10n.noQuestionsTitle,
                  message: l10n.noQuestionsMessage,
                );
              }

              return _isPracticeMode
                  ? _buildPracticeContent(context, questions)
                  : _buildExamContent(context, questions);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExamContent(BuildContext context, List<Question> questions) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
                l10n.questionProgress(_examQuestionIndex + 1, questions.length),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Flexible(
              child: Text(
                l10n.examAnswerStatus(
                  _examSelectedAnswerIds.length,
                  questions.length - _examSelectedAnswerIds.length,
                ),
                textAlign: TextAlign.end,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
          showError: false,
          enabled: !_isExamBusy,
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
                  onPressed: _isExamBusy ? null : _previousExamQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.previous),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: isFirstQuestion ? 1 : 1,
              child: FilledButton.icon(
                onPressed: _isExamBusy
                    ? null
                    : () => isLastQuestion
                          ? _submitExamModeQuiz(questions)
                          : _nextExamQuestion(),
                icon: _isSubmittingExamModeQuiz
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                label: Text(
                  _isSubmittingExamModeQuiz
                      ? l10n.submitting
                      : isLastQuestion
                      ? l10n.submitQuiz
                      : l10n.nextQuestion,
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
    final l10n = context.l10n;
    final question = questions[_practiceQuestionIndex];
    final isLastQuestion = _practiceQuestionIndex == questions.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.questionProgress(
                  _practiceQuestionIndex + 1,
                  questions.length,
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Text(
              l10n.instantFeedback,
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
            duration: AppMotion.duration(
              context,
              const Duration(milliseconds: 180),
            ),
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
          onPressed: _practiceAnswerCheckResult == null || _isCompletingPractice
              ? null
              : () => _continuePractice(questions),
          icon: Icon(isLastQuestion ? Icons.done : Icons.arrow_forward),
          label: Text(isLastQuestion ? l10n.finishPractice : l10n.nextQuestion),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    );
  }

  Widget? _buildPracticeFeedback(BuildContext context, Question question) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (_isCheckingPracticeAnswer) {
      return Padding(
        key: const ValueKey('checking-practice-answer'),
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(l10n.checkingAnswer)),
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
                l10n.answerCheckError,
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
              label: Text(l10n.tryAgain),
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
        borderRadius: BorderRadius.circular(14),
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
                  result.isCorrect ? l10n.correct : l10n.incorrect,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: feedbackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.yourAnswer(result.selectedAnswerText)),
                Text(l10n.correctAnswer(result.correctAnswerText)),
                if (result.explanation?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(result.explanation!),
                ],
                if (result.explanationMedia != null) ...[
                  const SizedBox(height: 10),
                  StudyMediaImage(
                    media: result.explanationMedia!,
                    maxHeight: 200,
                  ),
                ],
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

    unawaited(DeviceFeedback.selection());
    setState(() {
      _examSelectedAnswerIds[questionId] = answerOptionId;
    });
  }

  void _nextExamQuestion() {
    setState(() => _examQuestionIndex++);
  }

  void _previousExamQuestion() {
    setState(() => _examQuestionIndex--);
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
    unawaited(DeviceFeedback.selection());

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
            answerOptions: question.answerOptions,
            selectedAnswerOptionId: result.selectedAnswerOptionId,
            selectedAnswerText: result.selectedAnswerText,
            correctAnswerOptionId: result.correctAnswerOptionId,
            correctAnswerText: result.correctAnswerText,
            isCorrect: result.isCorrect,
            explanation: result.explanation,
            questionMedia: result.questionMedia ?? question.media,
            explanationMedia: result.explanationMedia,
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
    if (_isCompletingPractice) return;
    if (_practiceQuestionIndex == questions.length - 1) {
      setState(() => _isCompletingPractice = true);
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
    final result = QuizResult.fromTrustedReviews(
      questionSetId: widget.questionSet.id,
      questionSetTitle: widget.questionSet.title,
      totalCount: totalQuestions,
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
    if (_isExamBusy) {
      return;
    }

    final unansweredCount = questions.length - _examSelectedAnswerIds.length;
    if (unansweredCount > 0) {
      setState(() => _isConfirmingExamSubmission = true);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: Text(context.l10n.submitExamTitle),
          content: Text(context.l10n.submitWithUnanswered(unansweredCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.progressCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.submitAnyway),
            ),
          ],
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() => _isConfirmingExamSubmission = false);
      if (confirmed != true) {
        return;
      }
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
          builder: (context) => QuizResultScreen(
            result: result,
            attemptSaveRequest: ExamAttemptSaveRequest(
              submissionId: _examSubmissionId,
              questionSetId: widget.questionSet.id,
              startedAt: _examStartedAt,
              selectedAnswerOptionIdsByQuestionId: examSelectedAnswerIds,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.quizSubmitError)));
      setState(() {
        _isSubmittingExamModeQuiz = false;
      });
    }
  }

  Future<void> _confirmDiscardAttempt() async {
    if (_isConfirmingDiscard) {
      return;
    }
    setState(() => _isConfirmingDiscard = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(context.l10n.leaveExamTitle),
        content: Text(context.l10n.discardExamProgressMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.keepLearning),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.discardProgress),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() => _isConfirmingDiscard = false);
    if (confirmed != true) {
      return;
    }

    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _AnimatedQuizProgress extends StatelessWidget {
  const _AnimatedQuizProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: AppMotion.duration(context, const Duration(milliseconds: 220)),
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
            if (question.media != null) ...[
              const SizedBox(height: 14),
              StudyMediaImage(media: question.media!),
            ],
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
                context.l10n.chooseOneAnswer,
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
