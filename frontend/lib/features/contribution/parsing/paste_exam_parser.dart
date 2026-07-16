import '../models/answer_option_draft.dart';
import '../models/question_draft.dart';
import '../models/question_set_draft.dart';
import 'paste_exam_parse_result.dart';

class PasteExamParser {
  const PasteExamParser();

  PasteExamParseResult parse(String source) {
    final builders = <_QuestionBuilder>[];
    final documentIssues = <PasteExamIssue>[];
    _QuestionBuilder? current;
    _FieldTarget? activeField;
    final lines = source
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');

    for (var index = 0; index < lines.length; index++) {
      final lineNumber = index + 1;
      final rawLine = lines[index];
      final match = _tagPattern.firstMatch(rawLine.trimLeft());
      if (match == null) {
        if (rawLine.trim().isEmpty) {
          if (current != null && activeField != null) {
            current.append(activeField, '');
          }
          continue;
        }
        if (current != null && activeField != null) {
          current.append(activeField, rawLine.trimRight());
        } else {
          documentIssues.add(
            PasteExamIssue(
              code: PasteExamIssueCode.ignoredText,
              severity: PasteExamIssueSeverity.warning,
              lineNumber: lineNumber,
            ),
          );
        }
        continue;
      }

      final rawName = match.group(1)!.toLowerCase();
      final suffix = match.group(2) ?? '';
      final value = match.group(3) ?? '';
      final tag = _normalizeTag(rawName, suffix);
      if (tag == null) {
        documentIssues.add(
          PasteExamIssue(
            code: PasteExamIssueCode.unknownTag,
            severity: PasteExamIssueSeverity.warning,
            lineNumber: lineNumber,
            detail: '/$rawName$suffix',
          ),
        );
        activeField = null;
        continue;
      }
      if (tag.usedAlias) {
        documentIssues.add(
          PasteExamIssue(
            code: PasteExamIssueCode.compatibilityAlias,
            severity: PasteExamIssueSeverity.warning,
            lineNumber: lineNumber,
            detail: '/$rawName$suffix',
          ),
        );
      }

      if (tag.kind == _TagKind.question) {
        current = _QuestionBuilder(lineNumber: lineNumber);
        builders.add(current);
      } else if (current == null) {
        current = _QuestionBuilder(lineNumber: lineNumber);
        builders.add(current);
      }

      activeField = current.set(tag, value.trimRight(), lineNumber);
    }

    final questions = <ParsedExamQuestion>[];
    for (var index = 0; index < builders.length; index++) {
      questions.add(builders[index].build(index + 1));
    }
    if (questions.length > contributionQuestionCountMax) {
      documentIssues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.tooManyQuestions,
          severity: PasteExamIssueSeverity.error,
          lineNumber: questions[contributionQuestionCountMax].sourceLine,
          detail: '$contributionQuestionCountMax',
        ),
      );
    }

    return PasteExamParseResult(
      questions: List.unmodifiable(questions),
      documentIssues: List.unmodifiable(documentIssues),
    );
  }
}

final _tagPattern = RegExp(r'^/([a-zA-Z]+)(\d*)\s*:\s*(.*)$');

enum _TagKind { question, answer, correct, explanation }

class _NormalizedTag {
  const _NormalizedTag(this.kind, {this.answerNumber, this.usedAlias = false});
  final _TagKind kind;
  final int? answerNumber;
  final bool usedAlias;
}

_NormalizedTag? _normalizeTag(String name, String suffix) {
  if (name == 'question' && suffix.isEmpty) {
    return const _NormalizedTag(_TagKind.question);
  }
  if ((name == 'quest' || name == 'quests') && suffix.isEmpty) {
    return const _NormalizedTag(_TagKind.question, usedAlias: true);
  }
  if ((name == 'answer' || name == 'awser') && suffix.isNotEmpty) {
    final number = int.tryParse(suffix);
    if (number == null || number < 1) return null;
    return _NormalizedTag(
      _TagKind.answer,
      answerNumber: number,
      usedAlias: name == 'awser',
    );
  }
  if (name == 'correct' && suffix.isEmpty) {
    return const _NormalizedTag(_TagKind.correct);
  }
  if (name == 'explanation' && suffix.isEmpty) {
    return const _NormalizedTag(_TagKind.explanation);
  }
  return null;
}

enum _FieldKind { question, answer, explanation }

class _FieldTarget {
  const _FieldTarget(this.kind, {this.answerNumber});
  final _FieldKind kind;
  final int? answerNumber;
}

class _QuestionBuilder {
  _QuestionBuilder({required this.lineNumber});

  final int lineNumber;
  String? question;
  String? explanation;
  int? correctAnswerNumber;
  final Map<int, String> answers = {};
  final List<PasteExamIssue> issues = [];

  _FieldTarget? set(_NormalizedTag tag, String value, int sourceLine) {
    switch (tag.kind) {
      case _TagKind.question:
        if (question != null) {
          _duplicate(sourceLine, '/question');
        }
        question = value;
        return const _FieldTarget(_FieldKind.question);
      case _TagKind.answer:
        final number = tag.answerNumber!;
        if (answers.containsKey(number)) {
          _duplicate(sourceLine, '/answer$number');
        }
        answers[number] = value;
        return _FieldTarget(_FieldKind.answer, answerNumber: number);
      case _TagKind.correct:
        if (correctAnswerNumber != null) {
          _duplicate(sourceLine, '/correct');
        }
        correctAnswerNumber = int.tryParse(value.trim());
        if (correctAnswerNumber == null) {
          issues.add(
            PasteExamIssue(
              code: PasteExamIssueCode.invalidCorrectAnswer,
              severity: PasteExamIssueSeverity.error,
              lineNumber: sourceLine,
              detail: value.trim(),
            ),
          );
        }
        return null;
      case _TagKind.explanation:
        if (explanation != null) {
          _duplicate(sourceLine, '/explanation');
        }
        explanation = value;
        return const _FieldTarget(_FieldKind.explanation);
    }
  }

  void append(_FieldTarget target, String value) {
    switch (target.kind) {
      case _FieldKind.question:
        question = _appendLine(question ?? '', value);
      case _FieldKind.answer:
        final number = target.answerNumber!;
        answers[number] = _appendLine(answers[number] ?? '', value);
      case _FieldKind.explanation:
        explanation = _appendLine(explanation ?? '', value);
    }
  }

  ParsedExamQuestion build(int questionNumber) {
    if ((question ?? '').trim().isEmpty) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.missingQuestion,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
        ),
      );
    }
    final nonEmptyAnswerCount = answers.values
        .where((answer) => answer.trim().isNotEmpty)
        .length;
    final hasBlankAnswer = answers.values.any(
      (answer) => answer.trim().isEmpty,
    );
    if (nonEmptyAnswerCount < 2 || hasBlankAnswer) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.missingAnswers,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
        ),
      );
    }
    if (answers.length > contributionAnswerOptionCountMax) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.tooManyAnswers,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
        ),
      );
    }
    if (correctAnswerNumber == null &&
        !issues.any(
          (issue) => issue.code == PasteExamIssueCode.invalidCorrectAnswer,
        )) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.missingCorrectAnswer,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
        ),
      );
    } else if (correctAnswerNumber != null &&
        !answers.containsKey(correctAnswerNumber)) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.invalidCorrectAnswer,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
          detail: '$correctAnswerNumber',
        ),
      );
    }

    final sortedAnswers = answers.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    final normalized = <String>{};
    for (final answer in sortedAnswers) {
      final value = answer.value.trim().toLowerCase();
      if (value.isNotEmpty && !normalized.add(value)) {
        issues.add(
          PasteExamIssue(
            code: PasteExamIssueCode.duplicateAnswers,
            severity: PasteExamIssueSeverity.error,
            lineNumber: lineNumber,
            questionNumber: questionNumber,
          ),
        );
        break;
      }
    }
    if ((question ?? '').length > contributionQuestionLengthMax ||
        (explanation ?? '').length > contributionExplanationLengthMax ||
        sortedAnswers.any(
          (entry) => entry.value.length > contributionAnswerLengthMax,
        )) {
      issues.add(
        PasteExamIssue(
          code: PasteExamIssueCode.contentTooLong,
          severity: PasteExamIssueSeverity.error,
          lineNumber: lineNumber,
          questionNumber: questionNumber,
        ),
      );
    }

    final id = 'pasted-question-$questionNumber-$lineNumber';
    final draft = QuestionDraft(
      id: id,
      text: (question ?? '').trim(),
      explanation: (explanation ?? '').trim(),
      answerOptions: sortedAnswers
          .map(
            (entry) => AnswerOptionDraft(
              id: '$id-answer-${entry.key}',
              text: entry.value.trim(),
              isCorrect: entry.key == correctAnswerNumber,
            ),
          )
          .toList(growable: false),
    );
    return ParsedExamQuestion(
      questionNumber: questionNumber,
      sourceLine: lineNumber,
      draft: draft,
      issues: List.unmodifiable(issues),
    );
  }

  void _duplicate(int line, String tag) {
    issues.add(
      PasteExamIssue(
        code: PasteExamIssueCode.duplicateTag,
        severity: PasteExamIssueSeverity.error,
        lineNumber: line,
        detail: tag,
      ),
    );
  }
}

String _appendLine(String existing, String next) =>
    existing.isEmpty ? next : '$existing\n$next';
