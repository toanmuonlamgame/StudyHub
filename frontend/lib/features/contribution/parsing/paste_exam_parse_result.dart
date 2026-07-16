import '../models/question_draft.dart';

enum PasteExamIssueSeverity { warning, error }

enum PasteExamIssueCode {
  ignoredText,
  unknownTag,
  compatibilityAlias,
  duplicateTag,
  missingQuestion,
  missingAnswers,
  tooManyAnswers,
  missingCorrectAnswer,
  invalidCorrectAnswer,
  duplicateAnswers,
  contentTooLong,
  tooManyQuestions,
}

class PasteExamIssue {
  const PasteExamIssue({
    required this.code,
    required this.severity,
    required this.lineNumber,
    this.questionNumber,
    this.detail,
  });

  final PasteExamIssueCode code;
  final PasteExamIssueSeverity severity;
  final int lineNumber;
  final int? questionNumber;
  final String? detail;
}

class ParsedExamQuestion {
  const ParsedExamQuestion({
    required this.questionNumber,
    required this.sourceLine,
    required this.draft,
    required this.issues,
  });

  final int questionNumber;
  final int sourceLine;
  final QuestionDraft draft;
  final List<PasteExamIssue> issues;

  bool get isValid =>
      issues.every((issue) => issue.severity != PasteExamIssueSeverity.error);
}

class PasteExamParseResult {
  const PasteExamParseResult({
    required this.questions,
    required this.documentIssues,
  });

  final List<ParsedExamQuestion> questions;
  final List<PasteExamIssue> documentIssues;

  int get validQuestionCount => questions.where((item) => item.isValid).length;
  int get invalidQuestionCount => questions.length - validQuestionCount;
  bool get hasErrors =>
      invalidQuestionCount > 0 ||
      documentIssues.any(
        (issue) => issue.severity == PasteExamIssueSeverity.error,
      );
  List<QuestionDraft> get drafts =>
      questions.map((item) => item.draft).toList(growable: false);
}
