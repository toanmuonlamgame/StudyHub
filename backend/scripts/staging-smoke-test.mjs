import assert from 'node:assert/strict';

async function main() {
  const origin = new URL(process.argv[2] ?? '');
  assert.ok(
    origin.protocol === 'https:' && origin.href === `${origin.origin}/`,
    'Provide an HTTPS origin without credentials, path, query, or fragment.',
  );

  async function get(path) {
    const response = await fetch(new URL(path, origin), {
      redirect: 'error',
      signal: AbortSignal.timeout(30_000),
    }).catch(() => {
      throw new Error(`${path}: could not reach the API over HTTPS within 30 seconds.`);
    });
    assert.equal(response.status, 200, `${path}: expected HTTP 200, got ${response.status}.`);
    const body = await response.json().catch(() => {
      throw new Error(`${path}: expected a JSON response.`);
    });
    assert.ok(body && typeof body === 'object', `${path}: invalid response body.`);
    return body;
  }

  const health = await get('/health');
  assert.ok(health.status === 'ok' && health.service === 'studyhub-backend', 'Unexpected health response.');
  console.log('PASS: HTTPS and backend health');

  const readiness = await get('/ready');
  assert.equal(readiness.status, 'ready', 'The backend data source is not ready.');
  console.log('PASS: backend data source readiness');

  const { subjects } = await get('/learning/subjects');
  assert.ok(Array.isArray(subjects), 'Expected subjects array.');
  const { items } = await get('/learning/question-sets?limit=1');
  assert.ok(Array.isArray(items) && items.length <= 1, 'Invalid question set page.');
  assert.ok(
    subjects.length > 0 && items.length > 0,
    'Catalog is empty: add approved demo content before testing the learner flow.',
  );
  assert.ok(typeof items[0]?.id === 'string' && items[0].id.length > 0, 'Missing question set ID.');
  const forbiddenKeys = /"(?:questions|answerOptions|answers|isCorrect|correctAnswer|correctAnswerOptionId)"\s*:/;
  assert.ok(!forbiddenKeys.test(JSON.stringify(items)), 'Question set list exposes question or answer data.');
  const { questions } = await get(`/learning/question-sets/${encodeURIComponent(items[0].id)}/questions`);
  assert.ok(Array.isArray(questions) && questions.length > 0, 'Expected at least one question.');
  assert.ok(
    !/"(?:isCorrect|correctAnswer|correctAnswerOptionId)"\s*:/.test(JSON.stringify(questions)),
    'Pre-submit questions expose answer correctness.',
  );
  console.log('PASS: non-empty catalog and pre-submit answer safety');
}

try {
  await main();
} catch (error) {
  console.error(
    error?.code === 'ERR_INVALID_URL'
      ? 'Usage: npm run test:staging -- https://your-api.example'
      : error.message,
  );
  process.exitCode = 1;
}
