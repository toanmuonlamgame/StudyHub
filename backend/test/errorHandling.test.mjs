import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';
import { InMemoryLearningService } from '../dist/services/inMemoryLearningService.js';
import { LearningDataIntegrityError } from '../dist/services/learningService.js';

function createFailingApp(t, error) {
  const service = new InMemoryLearningService();
  service.getSubjects = async () => {
    throw error;
  };
  const app = buildApp({ learningService: service });
  t.after(() => app.close());
  return app;
}

test('unexpected backend errors do not leak internal details', async (t) => {
  const app = createFailingApp(
    t,
    new Error('internal-database-detail-that-must-not-leak'),
  );
  const response = await app.inject({ method: 'GET', url: '/learning/subjects' });

  assert.equal(response.statusCode, 500);
  assert.deepEqual(response.json(), { error: 'Internal server error.' });
  assert.equal(response.body.includes('internal-database-detail'), false);
});

test('data integrity errors use a stable public message', async (t) => {
  const app = createFailingApp(
    t,
    new LearningDataIntegrityError('Correct answer key missing for q_private.'),
  );
  const response = await app.inject({ method: 'GET', url: '/learning/subjects' });

  assert.equal(response.statusCode, 500);
  assert.deepEqual(response.json(), {
    error: 'Learning data is temporarily unavailable.',
  });
  assert.equal(response.body.includes('q_private'), false);
});
