import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

test('GET /health returns the backend service status', async (t) => {
  const app = buildApp();
  t.after(() => app.close());

  const response = await app.inject({
    method: 'GET',
    url: '/health',
  });
  const body = response.json();

  assert.equal(response.statusCode, 200);
  assert.equal(body.status, 'ok');
  assert.equal(body.service, 'studyhub-backend');
});

test('CORS allows Flutter Web localhost development origins', async (t) => {
  const app = buildApp();
  t.after(() => app.close());
  const origin = 'http://localhost:54321';

  const response = await app.inject({
    method: 'OPTIONS',
    url: '/learning/subjects',
    headers: {
      origin,
      'access-control-request-method': 'GET',
    },
  });

  assert.equal(response.statusCode, 204);
  assert.equal(response.headers['access-control-allow-origin'], origin);
  assert.match(response.headers.vary, /Origin/);
});

test('readiness is safe in memory mode and independent from liveness', async (t) => {
  const memory = buildApp({ learningDataSource: 'memory' });
  const unavailable = buildApp({
    learningDataSource: 'memory',
    readinessProbe: async () => { throw new Error('Private database details'); },
  });
  t.after(() => Promise.all([memory.close(), unavailable.close()]));

  const ready = await memory.inject('/ready');
  assert.equal(ready.statusCode, 200);
  assert.deepEqual(ready.json(), { status: 'ready' });
  assert.equal(ready.headers['cache-control'], 'no-store');

  const failed = await unavailable.inject('/ready');
  assert.equal(failed.statusCode, 503);
  assert.deepEqual(failed.json(), { status: 'unavailable' });
  assert.equal((await unavailable.inject('/health')).statusCode, 200);
});

test('CORS allows 127.0.0.1 but not non-local browser origins', async (t) => {
  const app = buildApp();
  t.after(() => app.close());

  const loopbackResponse = await app.inject({
    method: 'GET',
    url: '/health',
    headers: { origin: 'http://127.0.0.1:62000' },
  });
  const remoteResponse = await app.inject({
    method: 'GET',
    url: '/health',
    headers: { origin: 'https://example.com' },
  });

  assert.equal(
    loopbackResponse.headers['access-control-allow-origin'],
    'http://127.0.0.1:62000',
  );
  assert.equal(remoteResponse.statusCode, 200);
  assert.equal(remoteResponse.headers['access-control-allow-origin'], undefined);
});

test('production CORS uses only the configured browser allowlist', async (t) => {
  const allowedOrigin = 'https://studyhub.example.test';
  const app = buildApp({
    learningService: createHealthTestService(),
    isProduction: true,
    corsOrigins: [allowedOrigin],
  });
  t.after(() => app.close());

  const allowedResponse = await app.inject({
    method: 'GET',
    url: '/health',
    headers: { origin: allowedOrigin },
  });
  const localResponse = await app.inject({
    method: 'GET',
    url: '/health',
    headers: { origin: 'http://localhost:54321' },
  });

  assert.equal(
    allowedResponse.headers['access-control-allow-origin'],
    allowedOrigin,
  );
  assert.equal(localResponse.headers['access-control-allow-origin'], undefined);
});

function createHealthTestService() {
  return {
    getSubjects: async () => [],
    getTopicsBySubjectId: async () => [],
    getQuestionSetsBySubjectId: async () => [],
    listQuestionSets: async () => ({ items: [], nextCursor: null, hasMore: false }),
    getQuestionSetById: async () => null,
    getQuestionsByQuestionSetId: async () => [],
    checkAnswer: async () => { throw new Error('Not used.'); },
    submitQuiz: async () => { throw new Error('Not used.'); },
    saveExamAttempt: async () => { throw new Error('Not used.'); },
    listExamAttempts: async () => [],
    getExamAttempt: async () => null,
    listStudyMaterials: async () => ({ items: [], nextCursor: null, hasMore: false }),
    getStudyMaterialById: async () => null,
    createQuestionSetSubmission: async () => { throw new Error('Not used.'); },
    createQuestionSetSubmissionForReview: async () => { throw new Error('Not used.'); },
    updateQuestionSetSubmission: async () => { throw new Error('Not used.'); },
    getQuestionSetSubmission: async () => null,
    submitQuestionSetForReview: async () => { throw new Error('Not used.'); },
  };
}
