import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/question_set_draft.dart';
import '../parsing/paste_exam_parse_result.dart';
import '../parsing/paste_exam_parser.dart';

const pasteExamFormatTemplate = '''/question: What is 2 + 2?
/answer1: 3
/answer2: 4
/answer3: 5
/correct: 2
/explanation: 2 + 2 equals 4.

/question: Flutter primarily uses which language?
/answer1: Java
/answer2: Kotlin
/answer3: Dart
/answer4: Swift
/correct: 3''';

class PasteExamScreen extends StatefulWidget {
  const PasteExamScreen({super.key, required this.baseDraft});

  final QuestionSetDraft baseDraft;

  @override
  State<PasteExamScreen> createState() => _PasteExamScreenState();
}

class _PasteExamScreenState extends State<PasteExamScreen> {
  final _controller = TextEditingController();
  final _inputFocusNode = FocusNode();
  final _inputKey = GlobalKey();
  final _parser = const PasteExamParser();
  final _summaryKey = GlobalKey();
  PasteExamParseResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pasteExamTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: result == null
                        ? 1
                        : 2 +
                              result.documentIssues.length +
                              result.questions.length,
                    itemBuilder: (context, index) =>
                        _buildPreviewItem(context, result, index),
                  ),
                ),
                if (result != null)
                  _ImportBar(
                    enabled: result.questions.isNotEmpty && !result.hasErrors,
                    onImport: _importQuestions,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(
    BuildContext context,
    PasteExamParseResult? result,
    int index,
  ) {
    final l10n = context.l10n;
    if (index == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasteHeader(),
          const SizedBox(height: AppSpacing.lg),
          KeyedSubtree(
            key: _inputKey,
            child: TextField(
              key: const Key('paste-exam-input'),
              controller: _controller,
              focusNode: _inputFocusNode,
              minLines: 12,
              maxLines: 20,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: l10n.pasteExamInputLabel,
                alignLabelWithHint: true,
              ),
              onChanged: (_) {
                if (_result != null) setState(() => _result = null);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: _copyTemplate,
                icon: const Icon(Icons.content_copy_outlined),
                label: Text(l10n.copyFormatTemplate),
              ),
              FilledButton.tonalIcon(
                onPressed: _parse,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l10n.parseExamPreview),
              ),
            ],
          ),
        ],
      );
    }
    if (result == null) return const SizedBox.shrink();
    if (index == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: _ParseSummary(key: _summaryKey, result: result),
      );
    }
    final contentIndex = index - 2;
    if (contentIndex < result.documentIssues.length) {
      return _IssueTile(issue: result.documentIssues[contentIndex]);
    }
    final question =
        result.questions[contentIndex - result.documentIssues.length];
    return _QuestionPreview(
      question: question,
      onFix: question.isValid
          ? null
          : () => _focusSourceLine(question.sourceLine),
    );
  }

  Future<void> _copyTemplate() async {
    await Clipboard.setData(const ClipboardData(text: pasteExamFormatTemplate));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.formatTemplateCopied)));
  }

  void _parse() {
    FocusScope.of(context).unfocus();
    setState(() => _result = _parser.parse(_controller.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final summaryContext = _summaryKey.currentContext;
      if (summaryContext != null) {
        Scrollable.ensureVisible(
          summaryContext,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  void _importQuestions() {
    final result = _result;
    if (result == null || result.hasErrors || result.questions.isEmpty) return;
    Navigator.of(
      context,
    ).pop(widget.baseDraft.copyWith(questions: result.drafts));
  }

  void _focusSourceLine(int lineNumber) {
    final inputContext = _inputKey.currentContext;
    if (inputContext != null) {
      Scrollable.ensureVisible(
        inputContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
    final normalized = _controller.text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final targetIndex = (lineNumber - 1).clamp(0, lines.length - 1);
    var start = 0;
    for (var index = 0; index < targetIndex; index++) {
      start += lines[index].length + 1;
    }
    _controller.selection = TextSelection(
      baseOffset: start,
      extentOffset: start + lines[targetIndex].length,
    );
    _inputFocusNode.requestFocus();
  }
}

class _PasteHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadii.feature),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.document_scanner_outlined),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(context.l10n.pasteExamIntro)),
      ],
    ),
  );
}

class _ParseSummary extends StatelessWidget {
  const _ParseSummary({super.key, required this.result});
  final PasteExamParseResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pasteExamPreviewTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(
                    label: Text(
                      l10n.recognizedQuestions(result.questions.length),
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(l10n.validQuestions(result.validQuestionCount)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.error_outline, size: 18),
                    label: Text(
                      l10n.invalidQuestions(result.invalidQuestionCount),
                    ),
                  ),
                ],
              ),
              if (result.hasErrors) ...[
                const SizedBox(height: AppSpacing.md),
                Text(l10n.pasteExamFixErrors),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionPreview extends StatelessWidget {
  const _QuestionPreview({required this.question, this.onFix});
  final ParsedExamQuestion question;
  final VoidCallback? onFix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final invalid = !question.isValid;
    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      color: invalid ? scheme.errorContainer : scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  invalid ? Icons.error_outline : Icons.check_circle_outline,
                  color: invalid ? scheme.error : AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.pasteExamQuestionAtLine(
                      question.sourceLine,
                      question.questionNumber,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.draft.text.isEmpty
                  ? context.l10n.pasteExamMissingQuestion
                  : question.draft.text,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...question.draft.answerOptions.asMap().entries.map((entry) {
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      option.isCorrect
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: option.isCorrect
                          ? AppColors.success
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('${entry.key + 1}. ${option.text}')),
                  ],
                ),
              );
            }),
            if (question.draft.explanation.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.contributionExplanationOptional,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(question.draft.explanation),
            ],
            ...question.issues.map((issue) => _IssueTile(issue: issue)),
            if (onFix != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onFix,
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.pasteExamFixInSource),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.issue});
  final PasteExamIssue issue;

  @override
  Widget build(BuildContext context) {
    final warning = issue.severity == PasteExamIssueSeverity.warning;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.error_outline,
            size: 18,
            color: warning
                ? AppColors.warning
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(_message(context))),
        ],
      ),
    );
  }

  String _message(BuildContext context) {
    final l10n = context.l10n;
    return switch (issue.code) {
      PasteExamIssueCode.ignoredText => l10n.pasteExamIgnoredText(
        issue.lineNumber,
      ),
      PasteExamIssueCode.unknownTag => l10n.pasteExamUnknownTag(
        issue.lineNumber,
        issue.detail ?? '',
      ),
      PasteExamIssueCode.compatibilityAlias => l10n.pasteExamAliasUsed(
        issue.lineNumber,
        issue.detail ?? '',
      ),
      PasteExamIssueCode.duplicateTag => l10n.pasteExamDuplicateTag(
        issue.lineNumber,
        issue.detail ?? '',
      ),
      PasteExamIssueCode.missingQuestion => l10n.pasteExamMissingQuestion,
      PasteExamIssueCode.missingAnswers => l10n.pasteExamMissingAnswers,
      PasteExamIssueCode.tooManyAnswers =>
        l10n.contributionValidationMaxAnswers,
      PasteExamIssueCode.missingCorrectAnswer => l10n.pasteExamMissingCorrect,
      PasteExamIssueCode.invalidCorrectAnswer => l10n.pasteExamInvalidCorrect(
        issue.detail ?? '',
      ),
      PasteExamIssueCode.duplicateAnswers => l10n.pasteExamDuplicateAnswers,
      PasteExamIssueCode.contentTooLong => l10n.pasteExamContentTooLong,
      PasteExamIssueCode.tooManyQuestions => l10n.pasteExamTooManyQuestions(
        issue.detail ?? '',
      ),
    };
  }
}

class _ImportBar extends StatelessWidget {
  const _ImportBar({required this.enabled, required this.onImport});
  final bool enabled;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: FilledButton.icon(
          onPressed: enabled ? onImport : null,
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(context.l10n.pasteExamUseQuestions),
        ),
      ),
    ),
  );
}
