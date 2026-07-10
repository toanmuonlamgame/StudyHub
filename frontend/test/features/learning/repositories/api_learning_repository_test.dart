import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend/features/learning/repositories/api_learning_repository.dart';

void main() {
  test('maps subjects from the subjects endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'http://studyhub.test/learning/subjects');

      return _jsonResponse({
        'subjects': [
          {
            'id': 'subject_javascript',
            'name': 'JavaScript Basics',
            'description': 'Core JavaScript syntax and functions.',
          },
        ],
      });
    });
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: client,
    );

    final subjects = await repository.getSubjects();

    expect(subjects, hasLength(1));
    expect(subjects.single.id, 'subject_javascript');
    expect(subjects.single.name, 'JavaScript Basics');
    expect(
      subjects.single.description,
      'Core JavaScript syntax and functions.',
    );
  });

  test('maps quiz-safe questions without correctness metadata', () async {
    final client = MockClient((request) async {
      expect(
        request.url.path,
        '/learning/question-sets/question_set_js_basics/questions',
      );

      return _jsonResponse({
        'questions': [
          {
            'id': 'question_js_basics_1',
            'questionSetId': 'question_set_js_basics',
            'text': 'Which keyword declares a block-scoped variable?',
            'answerOptions': [
              {'id': 'js_b1_a', 'text': 'var'},
              {'id': 'js_b1_c', 'text': 'let'},
            ],
          },
        ],
      });
    });
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test/',
      client: client,
    );

    final questions = await repository.getQuestionsByQuestionSetId(
      'question_set_js_basics',
    );

    expect(questions, hasLength(1));
    expect(questions.single.answerOptions, hasLength(2));
    expect(questions.single.answerOptions.first.id, 'js_b1_a');
    expect(questions.single.answerOptions.first.text, 'var');
  });

  test('maps submit result and answer reviews', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.path,
        '/learning/question-sets/question_set_js_basics/submit',
      );
      expect(jsonDecode(request.body), {
        'selectedAnswerOptionIdsByQuestionId': {
          'question_js_basics_1': 'js_b1_b',
        },
      });

      return _jsonResponse({
        'result': {
          'questionSetId': 'question_set_js_basics',
          'questionSetTitle': 'JavaScript Basics Check',
          'totalQuestions': 1,
          'correctAnswers': 0,
          'wrongAnswers': 1,
          'percentageScore': 0,
          'answerReviews': [
            {
              'questionId': 'question_js_basics_1',
              'questionText': 'Which keyword declares a variable?',
              'selectedAnswerOptionId': 'js_b1_b',
              'selectedAnswerText': 'const',
              'correctAnswerOptionId': 'js_b1_c',
              'correctAnswerText': 'let',
              'isCorrect': false,
            },
          ],
        },
      });
    });
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: client,
    );

    final result = await repository.submitQuiz(
      questionSetId: 'question_set_js_basics',
      selectedAnswerOptionIdsByQuestionId: const {
        'question_js_basics_1': 'js_b1_b',
      },
    );

    expect(result.questionSetId, 'question_set_js_basics');
    expect(result.questionSetTitle, 'JavaScript Basics Check');
    expect(result.totalCount, 1);
    expect(result.correctCount, 0);
    expect(result.wrongCount, 1);
    expect(result.percentageScore, 0);
    expect(result.answerReviews, hasLength(1));
    expect(result.answerReviews.single.selectedAnswerText, 'const');
    expect(result.answerReviews.single.correctAnswerText, 'let');
    expect(result.answerReviews.single.isCorrect, isFalse);
  });

  test('throws a clear exception for non-success responses', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient(
        (_) async => _jsonResponse({'error': 'Subject not found.'}, 404),
      ),
    );

    expect(
      () => repository.getTopicsBySubjectId('missing'),
      throwsA(
        isA<LearningApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.message,
              'message',
              contains('status 404'),
            ),
      ),
    );
  });

  test('throws a clear exception for malformed response data', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient(
        (_) async => _jsonResponse({'subjects': 'not-a-list'}),
      ),
    );

    expect(
      () => repository.getSubjects(),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('subjects'),
        ),
      ),
    );
  });
}

http.Response _jsonResponse(Object body, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}
