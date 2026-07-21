import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';
import { InMemoryLearningService } from '../dist/services/inMemoryLearningService.js';

function createTestApp(t) {
  const app = buildApp({
    learningDataSource: 'memory',
    requireUser: async () => ({ id: 'test-user' }),
  });
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

test('production requires an explicit Prisma data source', () => {
  assert.throws(
    () => buildApp({ isProduction: true }),
    /STUDYHUB_LEARNING_DATA_SOURCE=prisma/,
  );
  assert.throws(
    () => buildApp({ isProduction: true, learningDataSource: 'memory' }),
    /STUDYHUB_LEARNING_DATA_SOURCE=prisma/,
  );
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

test('GET materials returns compact published metadata', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/materials',
  });
  const body = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(body.items.length, 4);
  assert.equal(body.hasMore, false);
  assert.equal(body.nextCursor, null);
  assert.ok(body.items.every(({ id }) => id !== 'material_database_draft'));
  assert.deepEqual(Object.keys(body.items[0]).sort(), [
    'createdAt',
    'description',
    'id',
    'language',
    'materialType',
    'subjectId',
    'title',
    'topicId',
  ]);

  const serialized = JSON.stringify(body);
  assert.equal(serialized.includes('status'), false);
  assert.equal(serialized.includes('sourceUrl'), false);
  assert.equal(serialized.includes('moderation'), false);
});

test('GET materials supports filters and metadata search', async (t) => {
  const app = createTestApp(t);
  const cases = [
    ['subjectId=subject_database', 2],
    ['topicId=topic_database_relations', 1],
    ['q=normalization', 1],
    ['materialType=link', 1],
    ['language=vi', 1],
  ];

  for (const [query, expectedCount] of cases) {
    const response = await app.inject({
      method: 'GET',
      url: `/learning/materials?${query}`,
    });
    assert.equal(response.statusCode, 200, query);
    assert.equal(response.json().items.length, expectedCount, query);
  }
});

test('GET materials supports stable cursor pagination', async (t) => {
  const app = createTestApp(t);
  const firstResponse = await app.inject({
    method: 'GET',
    url: '/learning/materials?limit=2',
  });
  const firstPage = firstResponse.json();

  assert.equal(firstResponse.statusCode, 200);
  assert.equal(firstPage.items.length, 2);
  assert.equal(firstPage.hasMore, true);
  assert.equal(typeof firstPage.nextCursor, 'string');

  const secondResponse = await app.inject({
    method: 'GET',
    url: `/learning/materials?limit=2&cursor=${encodeURIComponent(firstPage.nextCursor)}`,
  });
  const secondPage = secondResponse.json();
  assert.equal(secondResponse.statusCode, 200);
  assert.equal(secondPage.items.length, 2);
  assert.equal(secondPage.hasMore, false);
  assert.equal(
    new Set([
      ...firstPage.items.map(({ id }) => id),
      ...secondPage.items.map(({ id }) => id),
    ]).size,
    4,
  );
});

test('GET materials validates list query values', async (t) => {
  const app = createTestApp(t);
  const maximumPage = await app.inject({
    method: 'GET',
    url: '/learning/materials?limit=50',
  });
  assert.equal(maximumPage.statusCode, 200);

  for (const query of [
    'limit=0',
    'limit=51',
    'limit=1.5',
    'materialType=video',
    'cursor=not-a-cursor',
  ]) {
    const response = await app.inject({
      method: 'GET',
      url: `/learning/materials?${query}`,
    });
    assert.equal(response.statusCode, 400, query);
  }
});

test('GET published material returns safe detail metadata', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'GET',
    url: '/learning/materials/material_js_functions',
  });
  const { material } = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(material.id, 'material_js_functions');
  assert.equal(material.sourceType, 'externalLink');
  assert.match(material.sourceUrl, /^https:\/\//);
  assert.equal('status' in material, false);
  assert.equal('moderationNotes' in material, false);
});

test('GET material hides missing and unpublished resources', async (t) => {
  const app = createTestApp(t);
  for (const materialId of ['missing-material', 'material_database_draft']) {
    const response = await app.inject({
      method: 'GET',
      url: `/learning/materials/${materialId}`,
    });
    assert.equal(response.statusCode, 404, materialId);
  }
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
  assert.equal(result.unansweredAnswers, 0);
  assert.equal(result.percentageScore, 67);
  assert.equal(result.answerReviews.length, 3);
  assert.equal(result.answerReviews[0].answerOptions.length, 4);
  assert.equal(result.answerReviews[0].selectedAnswerText, 'const');
  assert.equal(result.answerReviews[0].correctAnswerText, 'let');
  assert.equal(result.answerReviews[0].isCorrect, false);
  assert.equal(typeof result.answerReviews[0].explanation, 'string');
});

test('POST submit scores unanswered questions without rejecting them', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/submit',
    payload: {
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_2: 'js_b2_b',
      },
    },
  });
  const { result } = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(result.totalQuestions, 3);
  assert.equal(result.correctAnswers, 1);
  assert.equal(result.wrongAnswers, 0);
  assert.equal(result.unansweredAnswers, 2);
  assert.equal(result.percentageScore, 33);
  assert.equal(result.answerReviews[0].selectedAnswerOptionId, null);
  assert.equal(result.answerReviews[0].selectedAnswerText, null);
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
  assert.equal(typeof result.explanation, 'string');
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

test('exam attempts are scored by the server and can be reopened', async (t) => {
  const app = createTestApp(t);
  const saveResponse = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: {
      submissionId: 'attempt-request-1',
      startedAt: '2026-07-17T01:00:00.000Z',
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'js_b1_c',
        question_js_basics_2: 'js_b2_a',
      },
    },
  });

  assert.equal(saveResponse.statusCode, 201);
  const saved = saveResponse.json().attempt;
  assert.equal(saved.correctAnswers, 1);
  assert.equal(saved.wrongAnswers, 1);
  assert.equal(saved.unansweredAnswers, 1);
  assert.equal(saved.percentageScore, 33);
  assert.equal(saved.result.answerReviews.length, 3);

  const listResponse = await app.inject({
    method: 'GET',
    url: '/learning/attempts',
  });
  assert.equal(listResponse.statusCode, 200);
  assert.equal(listResponse.json().attempts.length, 1);
  assert.equal(
    JSON.stringify(listResponse.json()).includes('answerReviews'),
    false,
  );

  const detailResponse = await app.inject({
    method: 'GET',
    url: `/learning/attempts/${saved.id}`,
  });
  assert.equal(detailResponse.statusCode, 200);
  assert.deepEqual(detailResponse.json().attempt.result, saved.result);
});

test('exam attempt submission is idempotent and history is newest first', async (t) => {
  const app = createTestApp(t);
  const payload = {
    submissionId: 'stable-retry-key',
    selectedAnswerOptionIdsByQuestionId: {
      question_js_basics_1: 'js_b1_c',
    },
  };
  const first = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload,
  });
  const retry = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: { ...payload, submissionId: '  stable-retry-key  ' },
  });
  assert.equal(first.statusCode, 201);
  assert.equal(retry.statusCode, 200);
  assert.equal(first.json().attempt.id, retry.json().attempt.id);

  await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: { ...payload, submissionId: 'newer-request-key' },
  });
  const history = (
    await app.inject({ method: 'GET', url: '/learning/attempts' })
  ).json().attempts;
  assert.equal(history.length, 2);
  assert.equal(history[0].id, 'attempt_2');
});

test('exam attempt rejects a reused idempotency key with different data', async (t) => {
  const app = createTestApp(t);
  const first = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: {
      submissionId: 'conflicting-retry-key',
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'js_b1_c',
      },
    },
  });
  const conflict = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: {
      submissionId: 'conflicting-retry-key',
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'js_b1_a',
      },
    },
  });

  assert.equal(first.statusCode, 201);
  assert.equal(conflict.statusCode, 409);
});

test('exam attempt endpoints reject invalid references and malformed input', async (t) => {
  const app = createTestApp(t);
  const invalidQuestionSet = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/missing/attempts',
    payload: {
      submissionId: 'missing-set',
      selectedAnswerOptionIdsByQuestionId: {},
    },
  });
  assert.equal(invalidQuestionSet.statusCode, 404);

  const invalidAnswer = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: {
      submissionId: 'invalid-answer',
      selectedAnswerOptionIdsByQuestionId: {
        question_js_basics_1: 'not-an-option',
      },
    },
  });
  assert.equal(invalidAnswer.statusCode, 400);

  const malformed = await app.inject({
    method: 'POST',
    url: '/learning/question-sets/question_set_js_basics/attempts',
    payload: {
      submissionId: '',
      selectedAnswerOptionIdsByQuestionId: {},
      score: 100,
    },
  });
  assert.equal(malformed.statusCode, 400);
});

test('in-memory attempt detail enforces owner identity', async () => {
  const service = new InMemoryLearningService();
  const { attempt } = await service.saveExamAttempt(
    'owner-a',
    'question_set_js_basics',
    {
      submissionId: 'owner-test',
      selectedAnswerOptionIdsByQuestionId: {},
    },
  );

  assert.equal(await service.getExamAttempt('owner-b', attempt.id), null);
  assert.equal((await service.listExamAttempts('owner-b')).length, 0);
  assert.equal((await service.listExamAttempts('owner-a')).length, 1);
});
