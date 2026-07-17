import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend/features/attempts/models/exam_attempt.dart';
import 'package:frontend/features/attempts/repositories/api_attempt_repository.dart';
import 'package:frontend/features/attempts/repositories/mock_attempt_repository.dart';

void main() {
  test(
    'MockAttemptRepository saves once and returns newest-first history',
    () async {
      final repository = MockAttemptRepository();
      final request = ExamAttemptSaveRequest(
        submissionId: 'stable-key',
        questionSetId: 'question_set_js_basics',
        startedAt: DateTime.utc(2026, 7, 17),
        selectedAnswerOptionIdsByQuestionId: const {
          'question_js_basics_1': 'js_b1_c',
        },
      );

      final first = await repository.saveExamAttempt(request);
      final retry = await repository.saveExamAttempt(request);
      final second = await repository.saveExamAttempt(
        ExamAttemptSaveRequest(
          submissionId: 'new-key',
          questionSetId: 'question_set_js_basics',
          startedAt: DateTime.utc(2026, 7, 17, 1),
          selectedAnswerOptionIdsByQuestionId: const {},
        ),
      );

      expect(retry.id, first.id);
      expect(first.correctAnswers, 1);
      expect(first.unansweredAnswers, 2);
      expect((await repository.listExamAttempts()).length, 2);
      expect((await repository.listExamAttempts()).first.id, second.id);
      expect((await repository.getExamAttempt(first.id))?.result, first.result);
    },
  );

  test('ApiAttemptRepository maps save, list, and detail contracts', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'POST') {
        return http.Response(jsonEncode({'attempt': _attemptJson}), 201);
      }
      if (request.url.path.endsWith('/attempts/attempt_1')) {
        return http.Response(jsonEncode({'attempt': _attemptJson}), 200);
      }
      return http.Response(
        jsonEncode({
          'attempts': [_summaryJson],
        }),
        200,
      );
    });
    final repository = ApiAttemptRepository(
      baseUrl: 'http://localhost:3000',
      client: client,
    );

    final saved = await repository.saveExamAttempt(
      ExamAttemptSaveRequest(
        submissionId: 'stable-key',
        questionSetId: 'set_1',
        startedAt: DateTime.utc(2026, 7, 17),
        selectedAnswerOptionIdsByQuestionId: const {'q1': 'a1'},
      ),
    );
    final history = await repository.listExamAttempts();
    final detail = await repository.getExamAttempt('attempt_1');

    expect(saved.result.answerReviews.single.correctAnswerOptionId, 'a1');
    expect(history.single.questionSetTitle, 'Example exam');
    expect(detail?.id, 'attempt_1');
    expect(requests.first.url.path, '/learning/question-sets/set_1/attempts');
    final sent = jsonDecode(requests.first.body) as Map<String, dynamic>;
    expect(sent.containsKey('score'), isFalse);
    expect(sent.containsKey('submissionId'), isTrue);
  });

  test('ApiAttemptRepository throws on non-2xx response', () async {
    final repository = ApiAttemptRepository(
      baseUrl: 'http://localhost:3000',
      client: MockClient((_) async => http.Response('{}', 500)),
    );

    expect(repository.listExamAttempts(), throwsA(isA<AttemptApiException>()));
  });

  test(
    'ApiAttemptRepository times out when the API does not respond',
    () async {
      final repository = ApiAttemptRepository(
        baseUrl: 'http://localhost:3000',
        client: MockClient((_) => Completer<http.Response>().future),
        requestTimeout: const Duration(milliseconds: 1),
      );

      await expectLater(
        repository.listExamAttempts(),
        throwsA(isA<TimeoutException>()),
      );
    },
  );
}

final _summaryJson = <String, Object?>{
  'id': 'attempt_1',
  'questionSetId': 'set_1',
  'questionSetTitle': 'Example exam',
  'startedAt': '2026-07-17T00:00:00.000Z',
  'completedAt': '2026-07-17T00:05:00.000Z',
  'totalQuestions': 1,
  'correctAnswers': 1,
  'wrongAnswers': 0,
  'unansweredAnswers': 0,
  'percentageScore': 100,
};

final _attemptJson = <String, Object?>{
  ..._summaryJson,
  'result': {
    'questionSetId': 'set_1',
    'questionSetTitle': 'Example exam',
    'totalQuestions': 1,
    'correctAnswers': 1,
    'wrongAnswers': 0,
    'unansweredAnswers': 0,
    'percentageScore': 100,
    'answerReviews': [
      {
        'questionId': 'q1',
        'questionText': 'Question?',
        'answerOptions': [
          {'id': 'a1', 'text': 'Answer'},
        ],
        'selectedAnswerOptionId': 'a1',
        'selectedAnswerText': 'Answer',
        'correctAnswerOptionId': 'a1',
        'correctAnswerText': 'Answer',
        'isCorrect': true,
        'explanation': null,
      },
    ],
  },
};
