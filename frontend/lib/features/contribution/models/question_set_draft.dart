import 'answer_option_draft.dart';
import 'question_draft.dart';

const contributionQuestionCountMax = 50;
const contributionAnswerOptionCountMax = 8;
const contributionTitleLengthMax = 160;
const contributionDescriptionLengthMax = 2000;
const contributionQuestionLengthMax = 2000;
const contributionExplanationLengthMax = 4000;
const contributionAnswerLengthMax = 1000;

class QuestionSetDraft {
  const QuestionSetDraft({
    this.subjectId = '',
    this.topicId,
    this.title = '',
    this.description = '',
    this.questions = const [],
  });

  final String subjectId;
  final String? topicId;
  final String title;
  final String description;
  final List<QuestionDraft> questions;

  bool get isEmpty =>
      subjectId.isEmpty &&
      title.trim().isEmpty &&
      description.trim().isEmpty &&
      questions.isEmpty;

  QuestionSetDraft copyWith({
    String? subjectId,
    Object? topicId = _unchanged,
    String? title,
    String? description,
    List<QuestionDraft>? questions,
  }) {
    return QuestionSetDraft(
      subjectId: subjectId ?? this.subjectId,
      topicId: identical(topicId, _unchanged)
          ? this.topicId
          : topicId as String?,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
    );
  }

  Map<String, Object?> toJson() => {
    'subjectId': subjectId,
    if (topicId != null) 'topicId': topicId,
    'title': title.trim(),
    'description': description.trim(),
    'questions': questions
        .map(
          (question) => {
            'text': question.text.trim(),
            if (question.explanation.trim().isNotEmpty)
              'explanation': question.explanation.trim(),
            'answerOptions': question.answerOptions
                .map(
                  (option) => {
                    'text': option.text.trim(),
                    'isCorrect': option.isCorrect,
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
  };

  List<DraftValidationIssue> validateForSubmission() {
    final issues = <DraftValidationIssue>[];
    if (subjectId.isEmpty) {
      issues.add(
        const DraftValidationIssue('subjectId', 'Subject is required.'),
      );
    }
    if (title.trim().isEmpty) {
      issues.add(const DraftValidationIssue('title', 'Title is required.'));
    }
    if (title.length > contributionTitleLengthMax) {
      issues.add(const DraftValidationIssue('title', 'Title is too long.'));
    }
    if (description.length > contributionDescriptionLengthMax) {
      issues.add(
        const DraftValidationIssue('description', 'Description is too long.'),
      );
    }
    if (questions.isEmpty) {
      issues.add(
        const DraftValidationIssue('questions', 'Add at least one question.'),
      );
    }
    if (questions.length > contributionQuestionCountMax) {
      issues.add(
        const DraftValidationIssue(
          'questions',
          'No more than 50 questions are allowed.',
        ),
      );
    }
    for (var index = 0; index < questions.length; index++) {
      final question = questions[index];
      final path = 'questions[$index]';
      if (question.text.trim().isEmpty) {
        issues.add(
          DraftValidationIssue('$path.text', 'Question text is required.'),
        );
      }
      if (question.text.length > contributionQuestionLengthMax) {
        issues.add(
          DraftValidationIssue('$path.text', 'Question text is too long.'),
        );
      }
      if (question.explanation.length > contributionExplanationLengthMax) {
        issues.add(
          DraftValidationIssue('$path.explanation', 'Explanation is too long.'),
        );
      }
      if (question.answerOptions.length < 2) {
        issues.add(
          DraftValidationIssue(
            '$path.answerOptions',
            'Add at least two answers.',
          ),
        );
      }
      if (question.answerOptions.length > contributionAnswerOptionCountMax) {
        issues.add(
          DraftValidationIssue(
            '$path.answerOptions',
            'No more than 8 answer options are allowed.',
          ),
        );
      }
      if (question.answerOptions.where((option) => option.isCorrect).length !=
          1) {
        issues.add(
          DraftValidationIssue(
            '$path.answerOptions',
            'Choose exactly one correct answer.',
          ),
        );
      }
      final seen = <String>{};
      for (
        var optionIndex = 0;
        optionIndex < question.answerOptions.length;
        optionIndex++
      ) {
        final text = question.answerOptions[optionIndex].text.trim();
        if (text.isEmpty) {
          issues.add(
            DraftValidationIssue(
              '$path.answerOptions[$optionIndex].text',
              'Answer text is required.',
            ),
          );
        }
        if (question.answerOptions[optionIndex].text.length >
            contributionAnswerLengthMax) {
          issues.add(
            DraftValidationIssue(
              '$path.answerOptions[$optionIndex].text',
              'Answer text is too long.',
            ),
          );
        }
        final normalized = text.toLowerCase();
        if (normalized.isNotEmpty && !seen.add(normalized)) {
          issues.add(
            DraftValidationIssue(
              '$path.answerOptions[$optionIndex].text',
              'Answers must be unique.',
            ),
          );
        }
      }
    }
    return issues;
  }

  static QuestionDraft newQuestion(int seed) => QuestionDraft(
    id: 'question-draft-$seed',
    answerOptions: [
      AnswerOptionDraft(id: 'answer-draft-$seed-1'),
      AnswerOptionDraft(id: 'answer-draft-$seed-2'),
    ],
  );
}

class DraftValidationIssue {
  const DraftValidationIssue(this.path, this.message);
  final String path;
  final String message;
}

const _unchanged = Object();
