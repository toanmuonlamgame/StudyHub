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
