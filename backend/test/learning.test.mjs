import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

function createTestApp(t) {
  const app = buildApp();
  t.after(() => app.close());
  return app;
}

test('GET /learning/subjects returns subjects', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/subjects',
  });
  const body = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(body.subjects.length, 3);
  assert.equal(body.subjects[0].id, 'subject_javascript');
});

test('GET question sets filters by subject', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/subjects/subject_javascript/question-sets',
  });
  const body = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(body.questionSets.length, 2);
  assert.ok(
    body.questionSets.every(
      (questionSet) => questionSet.subjectId === 'subject_javascript',
    ),
  );
});

test('GET questions never exposes correctness metadata', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/question-sets/question_set_js_basics/questions',
  });
  const body = response.json();
  const serializedBody = JSON.stringify(body);

  assert.equal(response.statusCode, 200);
  assert.equal(body.questions.length, 3);
  assert.equal(serializedBody.includes('isCorrect'), false);
  assert.equal(serializedBody.includes('correctAnswer'), false);
  assert.equal(serializedBody.includes('correctAnswerOptionId'), false);
});

test('POST submit calculates score and answer reviews', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/submit',
    payload: {
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'js_b1_b',
        question_js_basics_2: 'js_b2_b',
        question_js_basics_3: 'js_b3_c',
      },
    },
  });
  const { result } = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(result.questionSetId, 'question_set_js_basics');
  assert.equal(result.questionSetTitle, 'JavaScript Basics Check');
  assert.equal(result.totalQuestions, 3);
  assert.equal(result.correctAnswers, 2);
  assert.equal(result.wrongAnswers, 1);
  assert.equal(result.percentageScore, (2 / 3) * 100);
  assert.equal(result.answerReviews.length, 3);
  assert.equal(result.answerReviews[0].selectedAnswerText, 'const');
  assert.equal(result.answerReviews[0].correctAnswerText, 'let');
  assert.equal(result.answerReviews[0].isCorrect, false);
});

test('GET unknown question set returns 404', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/question-sets/missing-question-set',
  });

  assert.equal(response.statusCode, 404);
});

test('GET data for an unknown subject returns 404', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/subjects/missing-subject/topics',
  });

  assert.equal(response.statusCode, 404);
});

test('POST submit rejects an invalid body', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/submit',
    payload: {
      selectedAnswerOptionIdsByQuestionId: [],
    },
  });

  assert.equal(response.statusCode, 400);
});

test('POST submit rejects an invalid selected answer', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/submit',
    payload: {
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'not-an-option',
        question_js_basics_2: 'js_b2_b',
        question_js_basics_3: 'js_b3_c',
      },
    },
  });

  assert.equal(response.statusCode, 400);
});
