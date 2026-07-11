import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

function createTestApp(t) {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());
  return app;
}

test('buildApp defaults to in-memory data without PostgreSQL', async (t) => {
  const previousDataSource = process.env.STUDYHUB_LEARNING_DATA_SOURCE;
  const previousDatabaseUrl = process.env.DATABASE_URL;
  delete process.env.STUDYHUB_LEARNING_DATA_SOURCE;
  delete process.env.DATABASE_URL;

  try {
    const app = buildApp();
    t.after(() => app.close());
    const response = await app.inject({
      method: 'GET',
      url: '/learning/subjects',
    });

    assert.equal(response.statusCode, 200);
  } finally {
    if (previousDataSource !== undefined) {
      process.env.STUDYHUB_LEARNING_DATA_SOURCE = previousDataSource;
    }
    if (previousDatabaseUrl !== undefined) {
      process.env.DATABASE_URL = previousDatabaseUrl;
    }
  }
});

test('buildApp accepts an injected LearningService', async (t) => {
  const learningService = {
    getSubjects: async () => [{ id: 'injected', name: 'Injected Subject' }],
    getTopicsBySubjectId: async () => [],
    getQuestionSetsBySubjectId: async () => [],
    listQuestionSets: async () => ({
      items: [],
      nextCursor: null,
      hasMore: false,
    }),
    getQuestionSetById: async () => null,
    getQuestionsByQuestionSetId: async () => [],
    checkAnswer: async () => {
      throw new Error('Not used by this test.');
    },
    submitQuiz: async () => {
      throw new Error('Not used by this test.');
    },
  };
  const app = buildApp({ learningService });
  t.after(() => app.close());
  const response = await app.inject({
    method: 'GET',
    url: '/learning/subjects',
  });

  assert.equal(response.statusCode, 200);
  assert.equal(response.json().subjects[0].id, 'injected');
});

test('prisma data source requires DATABASE_URL', () => {
  const previousDatabaseUrl = process.env.DATABASE_URL;
  delete process.env.DATABASE_URL;

  try {
    assert.throws(
      () => buildApp({ learningDataSource: 'prisma' }),
      /requires DATABASE_URL/,
    );
  } finally {
    if (previousDatabaseUrl !== undefined) {
      process.env.DATABASE_URL = previousDatabaseUrl;
    }
  }
});

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

test('GET paginated question sets returns the default page shape', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/question-sets',
  });
  const body = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(body.items.length, 4);
  assert.equal(body.hasMore, false);
  assert.equal(body.nextCursor, null);
  assert.equal(typeof body.items[0].createdAt, 'string');
  assert.equal(typeof body.items[0].estimatedMinutes, 'number');
  assert.ok(['easy', 'medium', 'hard'].includes(body.items[0].difficulty));

  const serializedBody = JSON.stringify(body);
  assert.equal(serializedBody.includes('questions'), false);
  assert.equal(serializedBody.includes('answerOptions'), false);
  assert.equal(serializedBody.includes('isCorrect'), false);
  assert.equal(serializedBody.includes('correctAnswer'), false);
});

test('GET paginated question sets respects limit and cursor', async (t) => {
  const app = createTestApp(t);
  const firstResponse = await app.inject({
    method: 'GET',
    url: '/learning/question-sets?limit=2',
  });
  const firstPage = firstResponse.json();

  assert.equal(firstResponse.statusCode, 200);
  assert.equal(firstPage.items.length, 2);
  assert.equal(firstPage.hasMore, true);
  assert.equal(typeof firstPage.nextCursor, 'string');
  assert.deepEqual(
    Object.keys(
      JSON.parse(Buffer.from(firstPage.nextCursor, 'base64url').toString()),
    ).sort(),
    ['createdAt', 'id'],
  );

  const secondResponse = await app.inject({
    method: 'GET',
    url: `/learning/question-sets?limit=2&cursor=${encodeURIComponent(firstPage.nextCursor)}`,
  });
  const secondPage = secondResponse.json();

  assert.equal(secondResponse.statusCode, 200);
  assert.equal(secondPage.items.length, 2);
  assert.equal(secondPage.hasMore, false);
  assert.equal(secondPage.nextCursor, null);
  assert.deepEqual(
    new Set([
      ...firstPage.items.map(({ id }) => id),
      ...secondPage.items.map(({ id }) => id),
    ]).size,
    4,
  );
});

test('GET paginated question sets validates limit and cursor', async (t) => {
  const app = createTestApp(t);
  const invalidLimits = ['0', '51', '1.5', 'abc'];

  for (const limit of invalidLimits) {
    const response = await app.inject({
      method: 'GET',
      url: `/learning/question-sets?limit=${limit}`,
    });
    assert.equal(response.statusCode, 400);
  }

  const invalidCursorResponse = await app.inject({
    method: 'GET',
    url: '/learning/question-sets?cursor=not-a-cursor',
  });
  assert.equal(invalidCursorResponse.statusCode, 400);
});

test('GET paginated question sets supports subject, topic, and title filters', async (t) => {
  const app = createTestApp(t);

  const subjectResponse = await app.inject({
    method: 'GET',
    url: '/learning/question-sets?subjectId=subject_javascript',
  });
  assert.equal(subjectResponse.statusCode, 200);
  assert.equal(subjectResponse.json().items.length, 2);
  assert.ok(
    subjectResponse
      .json()
      .items.every(({ subjectId }) => subjectId === 'subject_javascript'),
  );

  const topicResponse = await app.inject({
    method: 'GET',
    url: '/learning/question-sets?topicId=topic_js_functions',
  });
  assert.equal(topicResponse.statusCode, 200);
  assert.deepEqual(
    topicResponse.json().items.map(({ id }) => id),
    ['question_set_js_functions'],
  );

  const searchResponse = await app.inject({
    method: 'GET',
    url: '/learning/question-sets?q=oop',
  });
  assert.equal(searchResponse.statusCode, 200);
  assert.deepEqual(
    searchResponse.json().items.map(({ id }) => id),
    ['question_set_java_oop'],
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

test('POST check-answer returns correct feedback', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/questions/question_js_basics_1/check-answer',
    payload: { selectedAnswerOptionId: 'js_b1_c' },
  });
  const { result } = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(result.questionId, 'question_js_basics_1');
  assert.equal(result.selectedAnswerOptionId, 'js_b1_c');
  assert.equal(result.selectedAnswerText, 'let');
  assert.equal(result.correctAnswerOptionId, 'js_b1_c');
  assert.equal(result.correctAnswerText, 'let');
  assert.equal(result.isCorrect, true);
});

test('POST check-answer returns incorrect feedback', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/questions/question_js_basics_1/check-answer',
    payload: { selectedAnswerOptionId: 'js_b1_b' },
  });
  const { result } = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(result.selectedAnswerText, 'const');
  assert.equal(result.correctAnswerText, 'let');
  assert.equal(result.isCorrect, false);
});

test('POST check-answer rejects an unknown question', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/questions/missing-question/check-answer',
    payload: { selectedAnswerOptionId: 'missing-option' },
  });

  assert.equal(response.statusCode, 404);
});

test('POST check-answer rejects an option from another question', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/questions/question_js_basics_1/check-answer',
    payload: { selectedAnswerOptionId: 'js_b2_b' },
  });

  assert.equal(response.statusCode, 400);
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
