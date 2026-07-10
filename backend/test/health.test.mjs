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
