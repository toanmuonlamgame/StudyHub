import assert from 'node:assert/strict';
import { loadEnvFile } from 'node:process';
import { fileURLToPath } from 'node:url';

const localEnvPath = fileURLToPath(new URL('../.env', import.meta.url));

if (!process.env.DATABASE_URL?.trim()) {
  try {
    loadEnvFile(localEnvPath);
  } catch (error) {
    if (error?.code !== 'ENOENT') {
      throw error;
    }
  }
}

assert.ok(
  process.env.DATABASE_URL?.trim(),
  'DATABASE_URL is required. Set it locally or create backend/.env from .env.example.',
);

let buildApp;
let getPrismaClient;

try {
  ({ buildApp } = await import('../dist/app.js'));
  ({ getPrismaClient } = await import('../dist/db/prisma.js'));
} catch (error) {
  if (error?.code === 'ERR_MODULE_NOT_FOUND') {
    throw new Error(
      'Compiled backend files are missing. Run npm run build before this smoke test.',
      { cause: error },
    );
  }
  throw error;
}

const app = buildApp({ learningDataSource: 'prisma' });
const prisma = getPrismaClient();

async function expectOk(requestOptions) {
  const response = await app.inject(requestOptions);
  assert.equal(
    response.statusCode,
    200,
    `${requestOptions.method} ${requestOptions.url} returned ${response.statusCode}: ${response.body}`,
  );
  return response.json();
}

try {
  const health = await expectOk({ method: 'GET', url: '/health' });
  assert.equal(health.status, 'ok');

  const subjects = await expectOk({
    method: 'GET',
    url: '/learning/subjects',
  });
  assert.ok(Array.isArray(subjects.subjects));
  assert.ok(
    subjects.subjects.some(({ id }) => id === 'subject_database'),
    'Seeded subject_database was not found.',
  );

  const questionSets = await expectOk({
    method: 'GET',
    url: '/learning/subjects/subject_database/question-sets',
  });
  assert.ok(Array.isArray(questionSets.questionSets));
  assert.ok(
    questionSets.questionSets.some(
      ({ id }) => id === 'question_set_database',
    ),
    'Seeded question_set_database was not found.',
  );

  const paginatedQuestionSets = await expectOk({
    method: 'GET',
    url: '/learning/question-sets?subjectId=subject_database&limit=1',
  });
  assert.equal(paginatedQuestionSets.items.length, 1);
  assert.equal(paginatedQuestionSets.items[0].id, 'question_set_database');
  assert.equal(JSON.stringify(paginatedQuestionSets).includes('questions'), false);
  assert.equal(JSON.stringify(paginatedQuestionSets).includes('isCorrect'), false);

  const questions = await expectOk({
    method: 'GET',
    url: '/learning/question-sets/question_set_database/questions',
  });
  assert.ok(Array.isArray(questions.questions));
  assert.equal(questions.questions.length, 3);

  const serializedQuestions = JSON.stringify(questions);
  assert.equal(serializedQuestions.includes('isCorrect'), false);
  assert.equal(serializedQuestions.includes('correctAnswer'), false);
  assert.equal(serializedQuestions.includes('correctAnswerOptionId'), false);

  const answerCheck = await expectOk({
    method: 'POST',
    url: '/learning/questions/question_database_1/check-answer',
    payload: { selectedAnswerOptionId: 'db_1_a' },
  });
  assert.equal(answerCheck.result.isCorrect, true);
  assert.equal(answerCheck.result.correctAnswerOptionId, 'db_1_a');

  const submission = await expectOk({
    method: 'POST',
    url: '/learning/question-sets/question_set_database/submit',
    payload: {
      selectedAnswerOptionIdsByQuestionId: {
        question_database_1: 'db_1_a',
        question_database_2: 'db_2_b',
        question_database_3: 'db_3_c',
      },
    },
  });

  assert.ok(submission.result, 'Submit response did not include result.');
  assert.equal(submission.result.correctAnswers, 3);
  assert.equal(submission.result.percentageScore, 100);
  assert.ok(Array.isArray(submission.result.answerReviews));
  assert.equal(submission.result.answerReviews.length, 3);

  console.log('Prisma Learning API smoke test passed.');
} finally {
  await app.close();
  await prisma.$disconnect();
}
