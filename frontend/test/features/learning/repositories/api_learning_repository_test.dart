import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend/features/learning/repositories/api_learning_repository.dart';
import 'package:frontend/features/materials/models/study_material.dart';

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

  test(
    'maps paginated question sets and sends list query parameters',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/learning/question-sets');
        expect(request.url.queryParameters, {
          'limit': '10',
          'subjectId': 'subject_javascript',
          'topicId': 'topic_js_syntax',
          'q': 'basics',
          'cursor': 'opaque-cursor',
        });

        return _jsonResponse({
          'items': [
            {
              'id': 'question_set_js_basics',
              'subjectId': 'subject_javascript',
              'topicId': 'topic_js_syntax',
              'title': 'JavaScript Basics Check',
              'description': 'Review variables, equality, and arrays.',
              'questionCount': 3,
              'estimatedMinutes': 5,
              'difficulty': 'easy',
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          ],
          'nextCursor': 'next-page',
          'hasMore': true,
        });
      });
      final repository = ApiLearningRepository(
        baseUrl: 'http://studyhub.test',
        client: client,
      );

      final page = await repository.listQuestionSets(
        subjectId: 'subject_javascript',
        topicId: 'topic_js_syntax',
        q: ' basics ',
        limit: 10,
        cursor: 'opaque-cursor',
      );

      expect(page.items, hasLength(1));
      expect(page.items.single.estimatedMinutes, 5);
      expect(page.items.single.difficulty, 'easy');
      expect(page.items.single.createdAt, DateTime.utc(2026));
      expect(page.nextCursor, 'next-page');
      expect(page.hasMore, isTrue);
    },
  );

  test('normalizes an empty next cursor', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient(
        (_) async => _jsonResponse({
          'items': <Object>[],
          'nextCursor': '',
          'hasMore': false,
        }),
      ),
    );

    final page = await repository.listQuestionSets();

    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
    expect(page.hasMore, isFalse);
  });

  test('maps paginated study material metadata and query filters', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient((request) async {
        expect(request.url.path, '/learning/materials');
        expect(request.url.queryParameters, {
          'limit': '10',
          'subjectId': 'subject_database',
          'materialType': 'notes',
          'language': 'en',
          'q': 'normalization',
          'cursor': 'page-2',
        });
        return _jsonResponse({
          'items': [
            {
              'id': 'material_database_normalization',
              'subjectId': 'subject_database',
              'topicId': 'topic_database_relations',
              'title': 'Database normalization notes',
              'description': 'Normal forms.',
              'materialType': 'notes',
              'language': 'en',
              'createdAt': '2026-04-01T00:00:00.000Z',
            },
          ],
          'nextCursor': null,
          'hasMore': false,
        });
      }),
    );

    final page = await repository.listStudyMaterials(
      subjectId: 'subject_database',
      materialType: StudyMaterialType.notes,
      language: 'en',
      q: ' normalization ',
      limit: 10,
      cursor: 'page-2',
    );

    expect(page.items.single.materialType, StudyMaterialType.notes);
    expect(page.items.single.sourceType, isNull);
    expect(page.hasMore, isFalse);
  });

  test('maps safe study material detail metadata', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient((request) async {
        expect(request.url.path, '/learning/materials/material_js_functions');
        return _jsonResponse({
          'material': {
            'id': 'material_js_functions',
            'subjectId': 'subject_javascript',
            'topicId': 'topic_js_functions',
            'title': 'JavaScript functions reference',
            'description': 'Functions reference.',
            'materialType': 'link',
            'sourceType': 'externalLink',
            'sourceUrl': 'https://developer.mozilla.org/example',
            'language': 'en',
            'createdAt': '2026-04-02T00:00:00.000Z',
            'updatedAt': '2026-04-02T00:00:00.000Z',
          },
        });
      }),
    );

    final material = await repository.getStudyMaterialById(
      'material_js_functions',
    );

    expect(material?.sourceType, StudyMaterialSourceType.externalLink);
    expect(material?.sourceUrl, startsWith('https://'));
  });

  test('throws for a missing study material detail', () async {
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: MockClient(
        (_) async => _jsonResponse({'error': 'Study material not found.'}, 404),
      ),
    );

    expect(
      () => repository.getStudyMaterialById('missing'),
      throwsA(
        isA<LearningApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
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

  test('maps a practice answer check result', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.path,
        '/learning/questions/question_js_basics_1/check-answer',
      );
      expect(jsonDecode(request.body), {'selectedAnswerOptionId': 'js_b1_b'});

      return _jsonResponse({
        'result': {
          'questionId': 'question_js_basics_1',
          'selectedAnswerOptionId': 'js_b1_b',
          'selectedAnswerText': 'const',
          'correctAnswerOptionId': 'js_b1_c',
          'correctAnswerText': 'let',
          'isCorrect': false,
        },
      });
    });
    final repository = ApiLearningRepository(
      baseUrl: 'http://studyhub.test',
      client: client,
    );

    final result = await repository.checkAnswer(
      questionId: 'question_js_basics_1',
      selectedAnswerOptionId: 'js_b1_b',
    );

    expect(result.questionId, 'question_js_basics_1');
    expect(result.selectedAnswerText, 'const');
    expect(result.correctAnswerText, 'let');
    expect(result.isCorrect, isFalse);
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
