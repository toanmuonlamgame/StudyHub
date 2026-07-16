import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../models/answer_option_draft.dart';
import '../models/question_draft.dart';
import '../models/question_set_draft.dart';

class QuestionEditorCard extends StatelessWidget {
  const QuestionEditorCard({
    super.key,
    required this.index,
    required this.question,
    required this.errorFor,
    required this.onChanged,
    required this.onDuplicate,
    required this.onRemove,
  });

  final int index;
  final QuestionDraft question;
  final String? Function(String path) errorFor;
  final ValueChanged<QuestionDraft> onChanged;
  final VoidCallback? onDuplicate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final questionPath = 'questions[$index]';
    final answerOptionsError = errorFor('$questionPath.answerOptions');
    return Card(
      key: ValueKey(question.id),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.contributionQuestion} ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.contributionDuplicateQuestion,
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: l10n.contributionRemoveQuestion,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              key: ValueKey('${question.id}-text'),
              initialValue: question.text,
              maxLength: contributionQuestionLengthMax,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.contributionQuestionText,
                errorText: errorFor('$questionPath.text'),
              ),
              onChanged: (value) => onChanged(question.copyWith(text: value)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('${question.id}-explanation'),
              initialValue: question.explanation,
              maxLength: contributionExplanationLengthMax,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.contributionExplanationOptional,
                errorText: errorFor('$questionPath.explanation'),
              ),
              onChanged: (value) =>
                  onChanged(question.copyWith(explanation: value)),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contributionAnswerOptions,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: question.answerOptions
                  .where((option) => option.isCorrect)
                  .firstOrNull
                  ?.id,
              onChanged: (selectedId) {
                if (selectedId == null) {
                  return;
                }
                final options = question.answerOptions
                    .map(
                      (item) => item.copyWith(isCorrect: item.id == selectedId),
                    )
                    .toList(growable: false);
                onChanged(question.copyWith(answerOptions: options));
              },
              child: Column(
                children: List.generate(
                  question.answerOptions.length,
                  (optionIndex) => _AnswerOptionEditor(
                    questionId: question.id,
                    option: question.answerOptions[optionIndex],
                    optionIndex: optionIndex,
                    errorText: errorFor(
                      '$questionPath.answerOptions[$optionIndex].text',
                    ),
                    canRemove: question.answerOptions.length > 2,
                    onChanged: (updated) {
                      final options = [...question.answerOptions];
                      options[optionIndex] = updated;
                      onChanged(question.copyWith(answerOptions: options));
                    },
                    onRemove: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.contributionRemoveAnswer),
                          content: Text(l10n.contributionRemoveAnswerConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.progressCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(l10n.contributionRemove),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      final options = [...question.answerOptions]
                        ..removeAt(optionIndex);
                      onChanged(question.copyWith(answerOptions: options));
                    },
                  ),
                ),
              ),
            ),
            if (answerOptionsError != null) ...[
              const SizedBox(height: 4),
              Text(
                answerOptionsError,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed:
                    question.answerOptions.length >=
                        contributionAnswerOptionCountMax
                    ? null
                    : () {
                        onChanged(
                          question.copyWith(
                            answerOptions: [
                              ...question.answerOptions,
                              AnswerOptionDraft(
                                id: '${question.id}-answer-${DateTime.now().microsecondsSinceEpoch}',
                              ),
                            ],
                          ),
                        );
                      },
                icon: const Icon(Icons.add),
                label: Text(l10n.contributionAddAnswer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionEditor extends StatelessWidget {
  const _AnswerOptionEditor({
    required this.questionId,
    required this.option,
    required this.optionIndex,
    required this.errorText,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final String questionId;
  final AnswerOptionDraft option;
  final int optionIndex;
  final String? errorText;
  final bool canRemove;
  final ValueChanged<AnswerOptionDraft> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<String>(value: option.id),
        Expanded(
          child: TextFormField(
            key: ValueKey('$questionId-${option.id}'),
            initialValue: option.text,
            maxLength: contributionAnswerLengthMax,
            decoration: InputDecoration(
              labelText: '${l10n.contributionAnswer} ${optionIndex + 1}',
              helperText: option.isCorrect
                  ? l10n.contributionCorrectAnswer
                  : null,
              errorText: errorText,
            ),
            onChanged: (value) => onChanged(option.copyWith(text: value)),
          ),
        ),
        IconButton(
          tooltip: l10n.contributionRemoveAnswer,
          onPressed: canRemove ? onRemove : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}
