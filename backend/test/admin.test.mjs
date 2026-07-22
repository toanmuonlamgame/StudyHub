import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';
import { InMemoryAdminService } from '../dist/services/inMemoryAdminService.js';

const adminUser = {
  id: 'admin_1',
  email: 'admin@example.invalid',
  displayName: 'Development Admin',
  role: 'admin',
  status: 'active',
  createdAt: new Date(0).toISOString(),
};

function buildAdminApp() {
  return buildApp({
    adminService: new InMemoryAdminService(),
    requireUser: async () => adminUser,
  });
}

test('ordinary authenticated users cannot access admin APIs', async (t) => {
  const app = buildApp();
  t.after(() => app.close());
  const registration = await app.inject({
    method: 'POST',
    url: '/auth/register',
    payload: {
      email: 'learner@example.com',
      password: 'password123',
      displayName: 'Learner',
    },
  });
  const token = registration.json().accessToken;
  const response = await app.inject({
    method: 'GET',
    url: '/admin/dashboard',
    headers: { authorization: `Bearer ${token}` },
  });
  assert.equal(response.statusCode, 403);
  assert.equal(response.json().error, 'Administrator access is required.');
});

test('admin dashboard and paginated contribution list return real memory data', async (t) => {
  const app = buildAdminApp();
  t.after(() => app.close());
  const dashboard = await app.inject({ method: 'GET', url: '/admin/dashboard' });
  assert.equal(dashboard.statusCode, 200);
  assert.equal(dashboard.json().summary.pendingContributions, 1);

  const list = await app.inject({
    method: 'GET',
    url: '/admin/contributions?status=pendingReview&page=1&limit=10',
  });
  assert.equal(list.statusCode, 200);
  assert.equal(list.json().page.total, 1);
  assert.equal(list.json().page.items[0].id, 'submission_pending_demo');
});

test('admin can inspect and approve a pending contribution exactly once', async (t) => {
  const app = buildAdminApp();
  t.after(() => app.close());
  const detail = await app.inject({
    method: 'GET',
    url: '/admin/contributions/submission_pending_demo',
  });
  assert.equal(detail.statusCode, 200);
  assert.equal(detail.json().contribution.questions[0].answerOptions[1].isCorrect, true);
  assert.equal(detail.json().contribution.contributor.email, 'learner@example.invalid');

  const approved = await app.inject({
    method: 'POST',
    url: '/admin/contributions/submission_pending_demo/approve',
  });
  assert.equal(approved.statusCode, 200);
  assert.equal(approved.json().contribution.status, 'published');
  assert.equal(approved.json().contribution.reviewedByUserId, adminUser.id);

  const repeated = await app.inject({
    method: 'POST',
    url: '/admin/contributions/submission_pending_demo/approve',
  });
  assert.equal(repeated.statusCode, 409);
});

test('rejection requires a reason and remains visible in contribution detail', async (t) => {
  const app = buildAdminApp();
  t.after(() => app.close());
  const invalid = await app.inject({
    method: 'POST',
    url: '/admin/contributions/submission_pending_demo/reject',
    payload: { reason: '' },
  });
  assert.equal(invalid.statusCode, 400);

  const rejected = await app.inject({
    method: 'POST',
    url: '/admin/contributions/submission_pending_demo/reject',
    payload: { reason: 'Please cite the source and improve the explanation.' },
  });
  assert.equal(rejected.statusCode, 200);
  assert.equal(rejected.json().contribution.status, 'rejected');
  assert.match(rejected.json().contribution.rejectionReason, /cite the source/);
});

test('admin user responses never expose password or session fields', async (t) => {
  const app = buildAdminApp();
  t.after(() => app.close());
  const response = await app.inject({ method: 'GET', url: '/admin/users' });
  assert.equal(response.statusCode, 200);
  const serialized = JSON.stringify(response.json());
  assert.equal(serialized.includes('password'), false);
  assert.equal(serialized.includes('token'), false);
});

test('taxonomy changes validate duplicates and question sets can be archived', async (t) => {
  const app = buildAdminApp();
  t.after(() => app.close());
  const duplicate = await app.inject({
    method: 'POST',
    url: '/admin/subjects',
    payload: { name: 'javascript basics' },
  });
  assert.equal(duplicate.statusCode, 409);

  const archived = await app.inject({
    method: 'PATCH',
    url: '/admin/question-sets/question_set_js_basics',
    payload: { isArchived: true },
  });
  assert.equal(archived.statusCode, 200);
  assert.equal(archived.json().questionSet.isArchived, true);
});
