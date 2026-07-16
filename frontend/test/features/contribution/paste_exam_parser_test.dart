import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/contribution/parsing/paste_exam_parse_result.dart';
import 'package:frontend/features/contribution/parsing/paste_exam_parser.dart';

void main() {
  const parser = PasteExamParser();

  test('parses one valid Vietnamese question with explanation', () {
    final result = parser.parse('''
/question: Thủ đô Việt Nam là gì?
/answer1: Hà Nội
/answer2: Hải Phòng
/answer3: Huế
/answer4: Đà Nẵng
/correct: 1
/explanation: Hà Nội là thủ đô Việt Nam.
''');

    expect(result.hasErrors, isFalse);
    expect(result.validQuestionCount, 1);
    expect(result.questions.single.draft.text, 'Thủ đô Việt Nam là gì?');
    expect(result.questions.single.draft.explanation, contains('Hà Nội'));
    expect(
      result.questions.single.draft.answerOptions
          .singleWhere((option) => option.isCorrect)
          .text,
      'Hà Nội',
    );
  });

  test('parses multiple questions with different answer counts', () {
    final result = parser.parse('''
/question: 2 + 2?
/answer1: 3
/answer2: 4
/answer3: 5
/correct: 2

/question: Flutter uses which language?
/answer1: Java
/answer2: Kotlin
/answer3: Dart
/answer4: Swift
/correct: 3
''');

    expect(result.hasErrors, isFalse);
    expect(result.questions, hasLength(2));
    expect(result.questions.first.draft.answerOptions, hasLength(3));
    expect(result.questions.last.draft.answerOptions, hasLength(4));
  });

  test('reports missing question, answers, and correct tag', () {
    final result = parser.parse('''
/answer1: Only answer

/question: Missing answers
/correct: 1

/question: Missing correct
/answer1: A
/answer2: B
''');

    expect(result.hasErrors, isTrue);
    expect(result.questions, hasLength(3));
    expect(
      result.questions.first.issues.map((issue) => issue.code),
      containsAll([
        PasteExamIssueCode.missingQuestion,
        PasteExamIssueCode.missingAnswers,
        PasteExamIssueCode.missingCorrectAnswer,
      ]),
    );
    expect(
      result.questions[1].issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.missingAnswers),
    );
    expect(
      result.questions[2].issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.missingCorrectAnswer),
    );
  });

  test('treats blank answer tags as missing answers', () {
    final result = parser.parse('''
/question: Blank answer
/answer1:
/answer2: B
/correct: 2
''');

    expect(result.hasErrors, isTrue);
    expect(
      result.questions.single.issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.missingAnswers),
    );
  });

  test('rejects a blank answer even when two other answers are valid', () {
    final result = parser.parse('''
/question: What is 1 + 1?
/answer1: 2
/answer2: 3
/answer3:
/correct: 1
''');

    expect(result.hasErrors, isTrue);
    expect(
      result.questions.single.issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.missingAnswers),
    );
  });

  test('reports correct index outside answer range', () {
    final result = parser.parse('''
/question: Pick one
/answer1: A
/answer2: B
/correct: 4
''');

    expect(result.hasErrors, isTrue);
    expect(
      result.questions.single.issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.invalidCorrectAnswer),
    );
  });

  test('rejects more than the supported answer count', () {
    final answers = List.generate(
      9,
      (index) => '/answer${index + 1}: $index',
    ).join('\n');
    final result = parser.parse(
      '/question: Too many answers\n$answers\n/correct: 1',
    );

    expect(result.hasErrors, isTrue);
    expect(
      result.questions.single.issues.map((issue) => issue.code),
      contains(PasteExamIssueCode.tooManyAnswers),
    );
  });

  test('reports duplicate tags and duplicate answers', () {
    final result = parser.parse('''
/question: Pick one
/answer1: Same
/answer1: Same
/answer2: Same
/correct: 1
/correct: 2
''');

    final codes = result.questions.single.issues.map((issue) => issue.code);
    expect(codes, contains(PasteExamIssueCode.duplicateTag));
    expect(codes, contains(PasteExamIssueCode.duplicateAnswers));
  });

  test(
    'unknown tags warn without invalidating an otherwise valid question',
    () {
      final result = parser.parse('''
/question: Pick one
/answer1: A
/answer2: B
/note: ignored
/correct: 1
''');

      expect(result.hasErrors, isFalse);
      expect(
        result.documentIssues.map((issue) => issue.code),
        contains(PasteExamIssueCode.unknownTag),
      );
    },
  );

  test('accepts compatibility aliases and reports warnings', () {
    final result = parser.parse('''
/quest: Pick one
/awser1: A
/awser2: B
/correct: 2
''');

    expect(result.hasErrors, isFalse);
    expect(result.validQuestionCount, 1);
    expect(
      result.documentIssues.where(
        (issue) => issue.code == PasteExamIssueCode.compatibilityAlias,
      ),
      hasLength(3),
    );
  });

  test('preserves multiline content, whitespace, and blank lines', () {
    final result = parser.parse('''
  /question: First line
second line

/answer1: A
/answer2: B
/correct: 1
/explanation: Explanation line one
line two
''');

    expect(result.hasErrors, isFalse);
    expect(
      result.questions.single.draft.text,
      contains('First line\nsecond line'),
    );
    expect(result.questions.single.draft.explanation, contains('line two'));
  });

  test('keeps a malformed question between valid questions visible', () {
    final result = parser.parse('''
/question: Valid one
/answer1: A
/answer2: B
/correct: 1

/question:
/answer1: A
/correct: 1

/question: Valid two
/answer1: A
/answer2: B
/correct: 2
''');

    expect(result.questions, hasLength(3));
    expect(result.validQuestionCount, 2);
    expect(result.invalidQuestionCount, 1);
    expect(result.questions[1].isValid, isFalse);
  });
}
