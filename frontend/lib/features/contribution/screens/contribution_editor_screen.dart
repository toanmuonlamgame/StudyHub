import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../learning/models/subject.dart';
import '../../learning/models/topic.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/answer_option_draft.dart';
import '../models/question_draft.dart';
import '../models/question_set_draft.dart';
import '../repositories/contribution_repository.dart';
import '../widgets/question_editor_card.dart';
import 'paste_exam_screen.dart';
import 'submission_confirmation_screen.dart';

enum _EditorStep { details, questions, review }

class ContributionEditorScreen extends StatefulWidget {
  const ContributionEditorScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
    this.initialDraft = const QuestionSetDraft(),
    this.startWithQuestions = false,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;
  final QuestionSetDraft initialDraft;
  final bool startWithQuestions;

  @override
  State<ContributionEditorScreen> createState() =>
      _ContributionEditorScreenState();
}

class _ContributionEditorScreenState extends State<ContributionEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionsScrollController = ScrollController();
  _EditorStep _step = _EditorStep.details;
  late QuestionSetDraft _draft;
  late final String _submissionId;
  List<Subject> _subjects = const [];
  List<Topic> _topics = const [];
  bool _loadingTaxonomy = true;
  bool _submitting = false;
  String? _loadError;
  List<DraftValidationIssue> _issues = const [];

  @override
  void initState() {
    super.initState();
    _draft = widget.initialDraft;
    _submissionId = _createSubmissionId();
    _titleController.text = _draft.title;
    _descriptionController.text = _draft.description;
    if (widget.startWithQuestions && _draft.questions.isNotEmpty) {
      _step = _EditorStep.questions;
    }
    _loadSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _questionsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: _draft.isEmpty && !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_submitting) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: _submitting ? null : _handleAppBarBack,
          ),
          title: Text(_stepTitle(l10n)),
          actions: [
            IconButton(
              tooltip: l10n.contributionPasteFullExam,
              onPressed: _submitting ? null : _openPasteExam,
              icon: const Icon(Icons.content_paste_go_outlined),
            ),
            PopupMenuButton<_EditorAction>(
              enabled: !_submitting,
              onSelected: (action) {
                if (action == _EditorAction.reset) _confirmResetDraft();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _EditorAction.reset,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: Text(l10n.contributionResetDraft),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  LinearProgressIndicator(value: (_step.index + 1) / 3),
                  Expanded(child: _buildStep()),
                  _BottomActions(
                    showBack: _step != _EditorStep.details,
                    busy: _submitting,
                    primaryLabel: switch (_step) {
                      _EditorStep.details => l10n.contributionContinue,
                      _EditorStep.questions => l10n.contributionReviewAndFinish,
                      _EditorStep.review => l10n.contributionSubmitForReview,
                    },
                    secondaryLabel: _step == _EditorStep.questions
                        ? l10n.contributionAddNextQuestion
                        : null,
                    onSecondary: _step == _EditorStep.questions
                        ? (_draft.questions.length >=
                                  contributionQuestionCountMax
                              ? null
                              : _addQuestion)
                        : null,
                    onBack: _goBack,
                    onPrimary: _step == _EditorStep.review
                        ? _confirmSubmit
                        : _goNext,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    _EditorStep.details => _buildDetails(),
    _EditorStep.questions => _buildQuestions(),
    _EditorStep.review => _buildReview(),
  };

  Widget _buildDetails() {
    final l10n = context.l10n;
    if (_loadingTaxonomy) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.subjectsLoadErrorTitle),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadSubjects,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Text(
          l10n.contributionDetailsIntro,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _draft.subjectId.isEmpty ? null : _draft.subjectId,
          decoration: InputDecoration(
            labelText: l10n.contributionSubject,
            errorText: _issueFor('subjectId'),
          ),
          items: _subjects
              .map(
                (subject) => DropdownMenuItem(
                  value: subject.id,
                  child: Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: _selectSubject,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          isExpanded: true,
          initialValue: _draft.topicId,
          decoration: InputDecoration(
            labelText: l10n.contributionTopicOptional,
            errorText: _issueFor('topicId'),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                l10n.allTopics,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ..._topics.map(
              (topic) => DropdownMenuItem<String?>(
                value: topic.id,
                child: Text(
                  topic.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) =>
              setState(() => _draft = _draft.copyWith(topicId: value)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          maxLength: contributionTitleLengthMax,
          decoration: InputDecoration(
            labelText: l10n.contributionSetTitle,
            errorText: _issueFor('title'),
          ),
          onChanged: (value) {
            setState(() => _draft = _draft.copyWith(title: value));
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLength: contributionDescriptionLengthMax,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.contributionDescription,
            errorText: _issueFor('description'),
          ),
          onChanged: (value) {
            setState(() => _draft = _draft.copyWith(description: value));
          },
        ),
      ],
    );
  }

  Widget _buildQuestions() {
    final l10n = context.l10n;
    return ListView(
      controller: _questionsScrollController,
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Text(
          l10n.contributionQuestionCount(_draft.questions.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (_issues.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ValidationSummary(
            messages: _issues
                .map(_localizedIssueMessage)
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 16),
        ...List.generate(
          _draft.questions.length,
          (index) => QuestionEditorCard(
            index: index,
            question: _draft.questions[index],
            errorFor: _issueFor,
            onChanged: (question) => _replaceQuestion(index, question),
            onDuplicate: _draft.questions.length >= contributionQuestionCountMax
                ? null
                : () => _duplicateQuestion(index),
            onRemove: () => _removeQuestion(index),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _draft.questions.length >= contributionQuestionCountMax
              ? null
              : _addQuestion,
          icon: const Icon(Icons.add),
          label: Text(l10n.contributionAddQuestion),
        ),
      ],
    );
  }

  Widget _buildReview() {
    final l10n = context.l10n;
    final subjectName =
        _subjects
            .where((subject) => subject.id == _draft.subjectId)
            .firstOrNull
            ?.name ??
        _draft.subjectId;
    final topicName = _topics
        .where((topic) => topic.id == _draft.topicId)
        .firstOrNull
        ?.name;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_issues.isNotEmpty) ...[
          _ValidationSummary(
            messages: _issues
                .map(_localizedIssueMessage)
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
        ],
        Text(_draft.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(subjectName),
        if (topicName != null) Text(topicName),
        if (_draft.description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(_draft.description),
        ],
        const SizedBox(height: 20),
        Text(
          l10n.contributionQuestionCount(_draft.questions.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...List.generate(_draft.questions.length, (index) {
          final question = _draft.questions[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question.text}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...question.answerOptions.map(
                    (option) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        option.isCorrect
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                      ),
                      title: Text(option.text),
                      subtitle: option.isCorrect
                          ? Text(l10n.contributionCorrectAnswer)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loadingTaxonomy = true;
      _loadError = null;
    });
    try {
      final subjects = await widget.learningRepository.getSubjects();
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _loadingTaxonomy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'load';
        _loadingTaxonomy = false;
      });
    }
  }

  Future<void> _selectSubject(String? subjectId) async {
    if (subjectId == null) return;
    setState(() {
      _draft = _draft.copyWith(subjectId: subjectId, topicId: null);
      _topics = const [];
    });
    try {
      final topics = await widget.learningRepository.getTopicsBySubjectId(
        subjectId,
      );
      if (mounted && _draft.subjectId == subjectId) {
        setState(() => _topics = topics);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.connectionRetryMessage)),
        );
      }
    }
  }

  void _goNext() {
    if (_step == _EditorStep.details) {
      final issues = _draft
          .validateForSubmission()
          .where((issue) => issue.path == 'subjectId' || issue.path == 'title')
          .toList();
      if (issues.isNotEmpty) {
        setState(() => _issues = issues);
        return;
      }
      if (_draft.questions.isEmpty) {
        _draft = _draft.copyWith(questions: [QuestionSetDraft.newQuestion(1)]);
      }
      setState(() {
        _issues = const [];
        _step = _EditorStep.questions;
      });
      return;
    }
    final issues = _draft.validateForSubmission();
    if (issues.isNotEmpty) {
      setState(() => _issues = issues);
      return;
    }
    setState(() {
      _issues = const [];
      _step = _EditorStep.review;
    });
  }

  void _goBack() => setState(() => _step = _EditorStep.values[_step.index - 1]);

  void _addQuestion() {
    if (_draft.questions.length >= contributionQuestionCountMax) return;
    setState(
      () => _draft = _draft.copyWith(
        questions: [
          ..._draft.questions,
          QuestionSetDraft.newQuestion(DateTime.now().microsecondsSinceEpoch),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_questionsScrollController.hasClients) {
        _questionsScrollController.animateTo(
          _questionsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _duplicateQuestion(int index) {
    if (_draft.questions.length >= contributionQuestionCountMax) return;
    final source = _draft.questions[index];
    final seed = DateTime.now().microsecondsSinceEpoch;
    final duplicate = QuestionDraft(
      id: 'question-draft-$seed',
      text: source.text,
      explanation: source.explanation,
      answerOptions: List.generate(source.answerOptions.length, (optionIndex) {
        final option = source.answerOptions[optionIndex];
        return AnswerOptionDraft(
          id: 'answer-draft-$seed-${optionIndex + 1}',
          text: option.text,
          isCorrect: option.isCorrect,
        );
      }),
    );
    setState(() {
      final questions = [..._draft.questions]..insert(index + 1, duplicate);
      _draft = _draft.copyWith(questions: questions);
    });
  }

  void _replaceQuestion(int index, QuestionDraft question) => setState(() {
    final questions = [..._draft.questions];
    questions[index] = question;
    _draft = _draft.copyWith(questions: questions);
  });

  Future<void> _removeQuestion(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionRemoveQuestion),
        content: Text(context.l10n.contributionRemoveQuestionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.contributionRemove),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        final questions = [..._draft.questions]..removeAt(index);
        _draft = _draft.copyWith(questions: questions);
      });
    }
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionSubmitForReview),
        content: Text(context.l10n.contributionSubmitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.contributionContinueEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.contributionSubmitForReview),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _submit();
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _issues = const [];
    });
    try {
      final confirmation = await widget.contributionRepository.submitForReview(
        _draft,
        submissionId: _submissionId,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              SubmissionConfirmationScreen(confirmation: confirmation),
        ),
      );
    } on ContributionValidationException catch (error) {
      if (mounted) {
        setState(() {
          _issues = error.issues;
          _submitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.contributionSubmissionFailed)),
        );
      }
    }
  }

  String _createSubmissionId() {
    final randomSuffix = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    return 'question-set-${DateTime.now().microsecondsSinceEpoch}-$randomSuffix';
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionUnsavedTitle),
        content: Text(context.l10n.contributionUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.contributionContinueEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.contributionDiscardDraft),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmResetDraft() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.contributionResetDraft),
        content: Text(context.l10n.contributionResetDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.contributionReset),
          ),
        ],
      ),
    );
    if (reset != true || !mounted) return;
    final preservedSubject = _draft.subjectId;
    final preservedTopic = _draft.topicId;
    setState(() {
      _draft = QuestionSetDraft(
        subjectId: preservedSubject,
        topicId: preservedTopic,
      );
      _titleController.clear();
      _descriptionController.clear();
      _issues = const [];
      _step = _EditorStep.details;
    });
  }

  Future<void> _openPasteExam() async {
    if (_draft.questions.isNotEmpty) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.contributionReplaceQuestionsTitle),
          content: Text(context.l10n.contributionReplaceQuestionsBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.progressCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.contributionReplaceQuestions),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    final imported = await Navigator.of(context).push<QuestionSetDraft>(
      MaterialPageRoute<QuestionSetDraft>(
        builder: (_) =>
            PasteExamScreen(baseDraft: _draft.copyWith(questions: const [])),
      ),
    );
    if (imported == null || !mounted) return;
    setState(() {
      _draft = imported;
      _issues = const [];
      _step = imported.subjectId.isEmpty || imported.title.trim().isEmpty
          ? _EditorStep.details
          : _EditorStep.questions;
    });
  }

  void _handleAppBarBack() {
    if (_draft.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    _confirmDiscard();
  }

  String? _issueFor(String path) {
    final issue = _issues.where((issue) => issue.path == path).firstOrNull;
    return issue == null ? null : _localizedIssueMessage(issue);
  }

  String _localizedIssueMessage(DraftValidationIssue issue) {
    final l10n = context.l10n;
    final message = issue.message.toLowerCase();
    if (issue.path == 'subjectId' && message.contains('does not exist')) {
      return l10n.contributionValidationSubjectUnavailable;
    }
    if (issue.path == 'questions') {
      return message.contains('more than')
          ? l10n.contributionValidationMaxQuestions
          : l10n.contributionValidationAddQuestion;
    }
    if (issue.path == 'title' || issue.path == 'description') {
      return message.contains('long') || message.contains('fewer')
          ? l10n.contributionValidationTooLong
          : l10n.contributionValidationRequired;
    }
    if (issue.path.endsWith('.explanation')) {
      return l10n.contributionValidationTooLong;
    }
    if (issue.path.endsWith('.text') && issue.path.contains('answerOptions')) {
      if (message.contains('unique')) {
        return l10n.contributionValidationUniqueAnswers;
      }
      return message.contains('long') || message.contains('fewer')
          ? l10n.contributionValidationTooLong
          : l10n.contributionValidationRequired;
    }
    if (issue.path.endsWith('.text') && issue.path.startsWith('questions')) {
      return message.contains('long') || message.contains('fewer')
          ? l10n.contributionValidationTooLong
          : l10n.contributionValidationQuestionText;
    }
    if (issue.path.endsWith('.answerOptions')) {
      if (message.contains('more than')) {
        return l10n.contributionValidationMaxAnswers;
      }
      return message.contains('two')
          ? l10n.contributionValidationAddAnswers
          : l10n.contributionValidationCorrectAnswer;
    }
    return l10n.contributionValidationRequired;
  }

  String _stepTitle(AppLocalizations l10n) => switch (_step) {
    _EditorStep.details => l10n.contributionDetails,
    _EditorStep.questions => l10n.contributionQuestionBuilder,
    _EditorStep.review => l10n.contributionReviewSubmission,
  };
}

enum _EditorAction { reset }

class _ValidationSummary extends StatelessWidget {
  const _ValidationSummary({required this.messages});
  final List<String> messages;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: messages
          .map((message) => Text('- $message'))
          .toList(growable: false),
    ),
  );
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.showBack,
    required this.busy,
    required this.primaryLabel,
    required this.onBack,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });
  final bool showBack;
  final bool busy;
  final String primaryLabel;
  final VoidCallback onBack;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryLabel != null) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: busy ? null : onSecondary,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(secondaryLabel!),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (showBack) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onBack,
                    child: Text(context.l10n.previous),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : onPrimary,
                  child: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(primaryLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
