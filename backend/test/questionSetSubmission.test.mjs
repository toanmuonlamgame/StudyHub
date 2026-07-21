import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

const validInput = {
  subjectId: 'subject_javascript',
  topicId: 'topic_js_syntax',
  title: 'Community JavaScript Review',
  description: 'A small community-created review set.',
  questions: [
    {
      text: 'Which declaration creates a block-scoped variable?',
      explanation: 'let is block scoped.',
      answerOptions: [
        { text: 'var', isCorrect: false },
        { text: 'let', isCorrect: true },
      ],
    },
  ],
};

function createTestApp(t) {
  const app = buildApp({ learningDataSource: 'memory' });
  t.after(() => app.close());
  return app;
}

test('creates and updates an incomplete draft', async (t) => {
  const app = createTestApp(t);
  const createResponse = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: { ...validInput, questions: [] },
  });
  const draft = createResponse.json().submission;

  assert.equal(createResponse.statusCode, 201);
  assert.equal(draft.status, 'draft');
  assert.equal(draft.sourceType, 'community');
  assert.equal('createdByUserId' in draft, false);

  const updateResponse = await app.inject({
    method: 'PUT',
    url: `/learning/question-set-submissions/${draft.id}`,
    payload: validInput,
  });
  assert.equal(updateResponse.statusCode, 200);
  assert.equal(updateResponse.json().submission.questions.length, 1);

  const normalized = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload: {
      ...validInput,
      submissionId: 'normalized-submission',
      title: '  Community JavaScript Review  ',
      questions: [{
        ...validInput.questions[0],
        explanation: '   ',
        answerOptions: [
          { text: '  var  ', isCorrect: false },
          { text: '  let  ', isCorrect: true },
        ],
      }],
    },
  });
  assert.equal(normalized.json().submission.title, 'Community JavaScript Review');
  assert.equal('explanation' in normalized.json().submission.questions[0], false);
  assert.equal(
    normalized.json().submission.questions[0].answerOptions[0].text,
    'var',
  );
});

test('rejects malformed bodies and invalid subject/topic references', async (t) => {
  const app = createTestApp(t);
  const malformed = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: { title: 'Missing fields' },
  });
  assert.equal(malformed.statusCode, 400);

  const unknownField = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: { ...validInput, createdByUserId: 'untrusted-client-user' },
  });
  assert.equal(unknownField.statusCode, 400);

  const invalidSubject = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: { ...validInput, subjectId: 'missing-subject' },
  });
  assert.equal(invalidSubject.statusCode, 400);
  assert.equal(invalidSubject.json().error.code, 'SUBMISSION_VALIDATION_FAILED');
  assert.equal(invalidSubject.json().error.fields[0].path, 'subjectId');

  const invalidTopic = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: { ...validInput, topicId: 'topic_database_sql' },
  });
  assert.equal(invalidTopic.statusCode, 400);
  assert.equal(invalidTopic.json().error.fields[0].path, 'topicId');
});

test('returns structured full-validation errors', async (t) => {
  const app = createTestApp(t);
  const cases = [
    [{ ...validInput, title: '' }, 'title'],
    [{ ...validInput, questions: [] }, 'questions'],
    [
      {
        ...validInput,
        questions: [{ text: '', answerOptions: [{ text: 'Only', isCorrect: false }] }],
      },
      'questions[0].text',
    ],
    [
      {
        ...validInput,
        questions: [{
          text: 'Question',
          answerOptions: [
            { text: 'Same', isCorrect: true },
            { text: ' same ', isCorrect: false },
          ],
        }],
      },
      'questions[0].answerOptions[1].text',
    ],
    [
      {
        ...validInput,
        questions: [{
          text: 'Question',
          answerOptions: [
            { text: 'A', isCorrect: false },
            { text: 'B', isCorrect: false },
          ],
        }],
      },
      'questions[0].answerOptions',
    ],
    [
      {
        ...validInput,
        questions: [{
          text: 'Question',
          answerOptions: [
            { text: 'A', isCorrect: true },
            { text: 'B', isCorrect: true },
          ],
        }],
      },
      'questions[0].answerOptions',
    ],
    [
      { ...validInput, questions: Array(51).fill(validInput.questions[0]) },
      'questions',
    ],
    [
      {
        ...validInput,
        questions: [{
          text: 'Question',
          answerOptions: Array.from({ length: 9 }, (_, index) => ({
            text: `Option ${index + 1}`,
            isCorrect: index === 0,
          })),
        }],
      },
      'questions[0].answerOptions',
    ],
  ];

  let caseNumber = 0;
  for (const [payload, expectedPath] of cases) {
    caseNumber += 1;
    const response = await app.inject({
      method: 'POST',
      url: '/learning/question-set-submissions/submit',
      payload: { ...payload, submissionId: `invalid-case-${caseNumber}` },
    });
    const body = response.json();
    assert.equal(response.statusCode, 400, expectedPath);
    assert.equal(body.error.code, 'SUBMISSION_VALIDATION_FAILED');
    assert.ok(body.error.fields.some(({ path }) => path === expectedPath));
  }
});

test('moves a draft to pendingReview and prevents later edits or repeat submit', async (t) => {
  const app = createTestApp(t);
  const created = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions',
    payload: validInput,
  });
  const draft = created.json().submission;
  const submitted = await app.inject({
    method: 'POST',
    url: `/learning/question-set-submissions/${draft.id}/submit`,
  });

  assert.equal(submitted.statusCode, 200);
  assert.equal(submitted.json().submission.status, 'pendingReview');
  assert.equal(typeof submitted.json().submission.submittedAt, 'string');

  const edit = await app.inject({
    method: 'PUT',
    url: `/learning/question-set-submissions/${draft.id}`,
    payload: validInput,
  });
  const repeated = await app.inject({
    method: 'POST',
    url: `/learning/question-set-submissions/${draft.id}/submit`,
  });
  assert.equal(edit.statusCode, 409);
  assert.equal(repeated.statusCode, 409);
});

test('atomic contribution submit returns pendingReview and remains hidden from learner APIs', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload: { ...validInput, submissionId: 'atomic-hidden-submission' },
  });
  const submission = response.json().submission;

  assert.equal(response.statusCode, 201);
  assert.equal(submission.status, 'pendingReview');

  const list = await app.inject({ method: 'GET', url: '/learning/question-sets?q=Community' });
  const detail = await app.inject({
    method: 'GET',
    url: `/learning/question-sets/${submission.id}`,
  });
  const questions = await app.inject({
    method: 'GET',
    url: `/learning/question-sets/${submission.id}/questions`,
  });
  const quiz = await app.inject({
    method: 'POST',
    url: `/learning/question-sets/${submission.id}/submit`,
    payload: { selectedAnswerOptionIdsByQuestionId: {} },
  });

  assert.equal(list.json().items.length, 0);
  assert.equal(detail.statusCode, 404);
  assert.equal(questions.statusCode, 404);
  assert.equal(quiz.statusCode, 404);
});

test('atomic contribution submit is retry-safe and rejects changed payloads', async (t) => {
  const app = createTestApp(t);
  const payload = { ...validInput, submissionId: 'retry-safe-submission' };
  const first = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload,
  });
  const replay = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload,
  });
  const conflict = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload: { ...payload, title: 'Different title' },
  });

  assert.equal(first.statusCode, 201);
  assert.equal(first.json().submission.createdByUserId, 'demo-user');
  assert.equal(replay.statusCode, 200);
  assert.equal(replay.json().submission.id, first.json().submission.id);
  assert.equal(conflict.statusCode, 409);
  assert.equal(conflict.json().error.code, 'SUBMISSION_IDEMPOTENCY_CONFLICT');
});

test('atomic contribution submit requires a client submission ID', async (t) => {
  const app = createTestApp(t);
  const response = await app.inject({
    method: 'POST',
    url: '/learning/question-set-submissions/submit',
    payload: validInput,
  });
  assert.equal(response.statusCode, 400);
});
