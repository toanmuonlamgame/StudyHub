import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

const accountA = {
  email: 'learner@example.com',
  password: 'correct-horse-123',
  displayName: 'Learner A',
};

const accountB = {
  email: 'other@example.com',
  password: 'another-password-456',
  displayName: 'Learner B',
};

test('register, current user, profile update, logout, and invalid session', async (t) => {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());

  const registration = await app.inject({ method: 'POST', url: '/auth/register', payload: accountA });
  assert.equal(registration.statusCode, 201);
  const session = registration.json();
  assert.equal(session.user.email, accountA.email);
  assert.equal('passwordHash' in session.user, false);
  assert.ok(session.accessToken);

  const headers = { authorization: `Bearer ${session.accessToken}` };
  const me = await app.inject({ method: 'GET', url: '/auth/me', headers });
  assert.equal(me.statusCode, 200);
  assert.equal(me.json().user.displayName, accountA.displayName);

  const updated = await app.inject({
    method: 'PATCH',
    url: '/auth/me',
    headers,
    payload: { displayName: 'Updated learner' },
  });
  assert.equal(updated.statusCode, 200);
  assert.equal(updated.json().user.displayName, 'Updated learner');

  assert.equal((await app.inject({ method: 'POST', url: '/auth/logout', headers })).statusCode, 204);
  assert.equal((await app.inject({ method: 'GET', url: '/auth/me', headers })).statusCode, 401);
});

test('login rejects bad credentials and protected routes require authentication', async (t) => {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());
  await app.inject({ method: 'POST', url: '/auth/register', payload: accountA });

  const failed = await app.inject({
    method: 'POST',
    url: '/auth/login',
    payload: { email: accountA.email, password: 'wrong-password' },
  });
  assert.equal(failed.statusCode, 401);
  assert.equal((await app.inject({ method: 'GET', url: '/learning/bookmarks' })).statusCode, 401);
});

test('bookmarks are user-owned and duplicate saves stay unique', async (t) => {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());
  const sessionA = (await app.inject({ method: 'POST', url: '/auth/register', payload: accountA })).json();
  const sessionB = (await app.inject({ method: 'POST', url: '/auth/register', payload: accountB })).json();
  const headersA = { authorization: `Bearer ${sessionA.accessToken}` };
  const headersB = { authorization: `Bearer ${sessionB.accessToken}` };
  const url = '/learning/bookmarks/question_set_js_basics';

  assert.equal((await app.inject({ method: 'PUT', url, headers: headersA })).statusCode, 200);
  assert.equal((await app.inject({ method: 'PUT', url, headers: headersA })).statusCode, 200);
  assert.equal((await app.inject({ method: 'GET', url: '/learning/bookmarks', headers: headersA })).json().items.length, 1);
  assert.equal((await app.inject({ method: 'GET', url: '/learning/bookmarks', headers: headersB })).json().items.length, 0);
});

test('question-set drafts cannot be read by another user', async (t) => {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());
  const sessionA = (await app.inject({ method: 'POST', url: '/auth/register', payload: accountA })).json();
  const sessionB = (await app.inject({ method: 'POST', url: '/auth/register', payload: accountB })).json();
  const headersA = { authorization: `Bearer ${sessionA.accessToken}` };
  const headersB = { authorization: `Bearer ${sessionB.accessToken}` };
  const draft = {
    subjectId: 'subject_javascript',
    title: 'Owned draft',
    description: '',
    questions: [],
  };
  const created = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    headers: headersA,
    payload: draft,
  });
  assert.equal(created.statusCode, 201);
  const id = created.json().submission.id;
  assert.equal((await app.inject({ method: 'GET', url: `/learning/question-set-submissions/${id}`, headers: headersB })).statusCode, 404);
});
