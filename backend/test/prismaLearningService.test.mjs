import assert from 'node:assert/strict';
import test from 'node:test';

import { mapQuestion } from '../dist/services/learningMappers.js';
import { createExamAttemptFingerprint } from '../dist/services/examAttemptValidation.js';
import { createPrismaLearningService } from '../dist/services/prismaLearningService.js';
import { createQuestionSetSubmissionFingerprint } from '../dist/services/questionSetSubmissionIdempotency.js';

test('mapQuestion strips internal correctness metadata', () => {
  const question = mapQuestion({
    id: 'question_1',
    questionSetId: 'question_set_1',
    text: 'Example question?',
    position: 1,
    createdAt: new Date(),
    updatedAt: new Date(),
    answerOptions: [
      {
        id: 'answer_1',
        questionId: 'question_1',
        text: 'Correct internally',
        position: 1,
        isCorrect: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ],
  });

  assert.deepEqual(question.answerOptions, [
    { id: 'answer_1', text: 'Correct internally' },
  ]);
  assert.equal(JSON.stringify(question).includes('isCorrect'), false);
});

test('PrismaLearningService submitQuiz returns score and answer reviews', async () => {
  let findArgs;
  const fakePrisma = {
    questionSet: {
      findFirst: async (args) => {
        findArgs = args;
        return ({
        id: 'question_set_1',
        subjectId: 'subject_1',
        topicId: null,
        title: 'Example set',
        description: 'Example description',
        createdAt: new Date(),
        updatedAt: new Date(),
        questions: [
          {
            id: 'question_1',
            questionSetId: 'question_set_1',
            text: 'First question?',
            explanation: 'Because this is the correct answer.',
            position: 1,
            createdAt: new Date(),
            updatedAt: new Date(),
            answerOptions: [
              {
                id: 'answer_1',
                questionId: 'question_1',
                text: 'Wrong answer',
                position: 1,
                isCorrect: false,
                createdAt: new Date(),
                updatedAt: new Date(),
              },
              {
                id: 'answer_2',
                questionId: 'question_1',
                text: 'Correct answer',
                position: 2,
                isCorrect: true,
                createdAt: new Date(),
                updatedAt: new Date(),
              },
            ],
          },
        ],
        });
      },
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const result = await service.submitQuiz('question_set_1', {
    question_1: 'answer_1',
  });

  assert.equal(result.totalQuestions, 1);
  assert.equal(result.correctAnswers, 0);
  assert.equal(result.wrongAnswers, 1);
  assert.equal(result.unansweredAnswers, 0);
  assert.equal(result.percentageScore, 0);
  assert.equal(findArgs.where.status, 'published');
  assert.deepEqual(result.answerReviews, [
    {
      questionId: 'question_1',
      questionText: 'First question?',
      answerOptions: [
        { id: 'answer_1', text: 'Wrong answer' },
        { id: 'answer_2', text: 'Correct answer' },
      ],
      selectedAnswerOptionId: 'answer_1',
      selectedAnswerText: 'Wrong answer',
      correctAnswerOptionId: 'answer_2',
      correctAnswerText: 'Correct answer',
      isCorrect: false,
      explanation: 'Because this is the correct answer.',
    },
  ]);

  const unansweredResult = await service.submitQuiz('question_set_1', {});
  assert.equal(unansweredResult.correctAnswers, 0);
  assert.equal(unansweredResult.wrongAnswers, 0);
  assert.equal(unansweredResult.unansweredAnswers, 1);
  assert.equal(unansweredResult.answerReviews[0].selectedAnswerOptionId, null);
});

test('PrismaLearningService checkAnswer uses internal correctness data', async () => {
  let findArgs;
  const fakePrisma = {
    question: {
      findFirst: async (args) => {
        findArgs = args;
        return ({
        id: 'question_1',
        questionSetId: 'question_set_1',
        text: 'First question?',
        explanation: null,
        position: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        answerOptions: [
          {
            id: 'answer_1',
            questionId: 'question_1',
            text: 'Wrong answer',
            position: 1,
            isCorrect: false,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
          {
            id: 'answer_2',
            questionId: 'question_1',
            text: 'Correct answer',
            position: 2,
            isCorrect: true,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
        ],
        });
      },
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const result = await service.checkAnswer('question_1', 'answer_1');

  assert.deepEqual(result, {
    questionId: 'question_1',
    selectedAnswerOptionId: 'answer_1',
    selectedAnswerText: 'Wrong answer',
    correctAnswerOptionId: 'answer_2',
    correctAnswerText: 'Correct answer',
    isCorrect: false,
    explanation: null,
  });
  assert.equal(findArgs.where.questionSet.status, 'published');
});

test('PrismaLearningService lists compact paginated question sets', async () => {
  const calls = [];
  const fakePrisma = {
    questionSet: {
      findMany: async (args) => {
        calls.push(args);
        return [
          {
            id: 'question_set_2',
            subjectId: 'subject_1',
            topicId: 'topic_1',
            title: 'Second set',
            description: 'Second description',
            createdAt: new Date('2026-02-02T00:00:00.000Z'),
            updatedAt: new Date('2026-02-02T00:00:00.000Z'),
            _count: { questions: 7 },
          },
          {
            id: 'question_set_1',
            subjectId: 'subject_1',
            topicId: 'topic_1',
            title: 'First set',
            description: 'First description',
            createdAt: new Date('2026-02-01T00:00:00.000Z'),
            updatedAt: new Date('2026-02-01T00:00:00.000Z'),
            _count: { questions: 3 },
          },
        ];
      },
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const page = await service.listQuestionSets({
    subjectId: 'subject_1',
    topicId: 'topic_1',
    q: 'set',
    limit: 1,
  });

  assert.equal(calls[0].take, 2);
  assert.equal(calls[0].where.status, 'published');
  assert.deepEqual(calls[0].orderBy, [
    { createdAt: 'desc' },
    { id: 'desc' },
  ]);
  assert.equal(page.items.length, 1);
  assert.equal(page.items[0].id, 'question_set_2');
  assert.equal(page.items[0].questionCount, 7);
  assert.equal(page.items[0].difficulty, 'medium');
  assert.equal(page.hasMore, true);
  assert.equal(typeof page.nextCursor, 'string');
  assert.equal(JSON.stringify(page).includes('questions'), false);
});

test('PrismaLearningService lists only compact material metadata', async () => {
  const calls = [];
  const fakePrisma = {
    studyMaterial: {
      findMany: async (args) => {
        calls.push(args);
        return [
          {
            id: 'material_2',
            subjectId: 'subject_1',
            topicId: 'topic_1',
            title: 'Second material',
            description: 'Second description',
            materialType: 'link',
            sourceType: 'externalLink',
            sourceUrl: 'https://example.com/private-from-list',
            fileName: null,
            mimeType: null,
            fileSizeBytes: null,
            language: 'en',
            status: 'published',
            createdAt: new Date('2026-04-02T00:00:00.000Z'),
            updatedAt: new Date('2026-04-02T00:00:00.000Z'),
          },
          {
            id: 'material_1',
            subjectId: 'subject_1',
            topicId: null,
            title: 'First material',
            description: 'First description',
            materialType: 'notes',
            sourceType: 'uploadedFile',
            sourceUrl: null,
            fileName: 'notes.pdf',
            mimeType: 'application/pdf',
            fileSizeBytes: 1024,
            language: 'en',
            status: 'published',
            createdAt: new Date('2026-04-01T00:00:00.000Z'),
            updatedAt: new Date('2026-04-01T00:00:00.000Z'),
          },
        ];
      },
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const page = await service.listStudyMaterials({
    subjectId: 'subject_1',
    materialType: 'link',
    limit: 1,
  });

  assert.equal(calls[0].where.status, 'published');
  assert.equal(calls[0].take, 2);
  assert.equal(page.items.length, 1);
  assert.equal(page.hasMore, true);
  assert.equal(typeof page.nextCursor, 'string');
  assert.equal(JSON.stringify(page).includes('sourceUrl'), false);
  assert.equal(JSON.stringify(page).includes('status'), false);
});

test('PrismaLearningService creates a nested pending-review submission transaction', async () => {
  let createArgs;
  const createdAt = new Date('2026-07-15T00:00:00.000Z');
  const row = {
    id: 'submission_1',
    subjectId: 'subject_1',
    topicId: null,
    title: 'Community set',
    description: 'Description',
    status: 'pendingReview',
    sourceType: 'community',
    createdByUserId: null,
    submittedAt: createdAt,
    reviewedAt: null,
    publishedAt: null,
    rejectionReason: null,
    createdAt,
    updatedAt: createdAt,
    questions: [
      {
        text: 'Question?',
        explanation: null,
        answerOptions: [
          { text: 'Wrong', isCorrect: false },
          { text: 'Correct', isCorrect: true },
        ],
      },
    ],
  };
  const transaction = {
    questionSet: {
      create: async (args) => {
        createArgs = args;
        return row;
      },
    },
  };
  const fakePrisma = {
    subject: { findUnique: async () => ({ id: 'subject_1' }) },
    questionSet: { findUnique: async () => null },
    $transaction: async (callback) => callback(transaction),
  };
  const service = createPrismaLearningService(fakePrisma);

  const result = await service.createQuestionSetSubmissionForReview(
    'demo-user',
    'client-submission-1',
    {
    subjectId: 'subject_1',
    title: 'Community set',
    description: 'Description',
    questions: [
      {
        text: 'Question?',
        answerOptions: [
          { text: 'Wrong', isCorrect: false },
          { text: 'Correct', isCorrect: true },
        ],
      },
    ],
    },
  );

  assert.equal(createArgs.data.status, 'pendingReview');
  assert.equal(createArgs.data.sourceType, 'community');
  assert.equal(createArgs.data.createdByUserId, 'demo-user');
  assert.equal(createArgs.data.clientSubmissionId, 'client-submission-1');
  assert.equal(typeof createArgs.data.submissionFingerprint, 'string');
  assert.equal(createArgs.data.questions.create[0].position, 1);
  assert.equal(
    createArgs.data.questions.create[0].answerOptions.create[1].position,
    2,
  );
  assert.equal(result.created, true);
  assert.equal(result.submission.status, 'pendingReview');
  assert.equal(
    result.submission.questions[0].answerOptions[1].isCorrect,
    true,
  );
});

test('PrismaLearningService reuses only matching contribution retries', async () => {
  const input = {
    subjectId: 'subject_1',
    title: 'Community set',
    description: 'Description',
    questions: [{
      text: 'Question?',
      answerOptions: [
        { text: 'Wrong', isCorrect: false },
        { text: 'Correct', isCorrect: true },
      ],
    }],
  };
  const createdAt = new Date('2026-07-15T00:00:00.000Z');
  const existing = {
    id: 'submission_1',
    ...input,
    topicId: null,
    status: 'pendingReview',
    sourceType: 'community',
    createdByUserId: 'demo-user',
    clientSubmissionId: 'client-submission-1',
    submissionFingerprint: createQuestionSetSubmissionFingerprint(input),
    submittedAt: createdAt,
    reviewedAt: null,
    publishedAt: null,
    rejectionReason: null,
    createdAt,
    updatedAt: createdAt,
    questions: [{
      text: 'Question?',
      explanation: null,
      answerOptions: [
        { text: 'Wrong', isCorrect: false },
        { text: 'Correct', isCorrect: true },
      ],
    }],
  };
  const fakePrisma = {
    subject: { findUnique: async () => ({ id: 'subject_1' }) },
    questionSet: { findUnique: async () => existing },
    $transaction: async () => {
      throw new Error('matching retry must not create another row');
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const replay = await service.createQuestionSetSubmissionForReview(
    'demo-user',
    'client-submission-1',
    input,
  );
  assert.equal(replay.created, false);
  assert.equal(replay.submission.id, 'submission_1');

  await assert.rejects(
    service.createQuestionSetSubmissionForReview(
      'demo-user',
      'client-submission-1',
      { ...input, title: 'Changed title' },
    ),
    /different contribution data/,
  );
});

test('PrismaLearningService atomically guards draft submit transition', async () => {
  const createdAt = new Date('2026-07-15T00:00:00.000Z');
  const draft = {
    id: 'submission_1',
    subjectId: 'subject_1',
    topicId: null,
    title: 'Community set',
    description: 'Description',
    status: 'draft',
    sourceType: 'community',
    createdByUserId: null,
    submittedAt: null,
    reviewedAt: null,
    publishedAt: null,
    rejectionReason: null,
    createdAt,
    updatedAt: createdAt,
    questions: [{
      text: 'Question?',
      explanation: null,
      answerOptions: [
        { text: 'Wrong', isCorrect: false },
        { text: 'Correct', isCorrect: true },
      ],
    }],
  };
  let transitionArgs;
  const fakePrisma = {
    questionSet: { findFirst: async () => draft },
    $transaction: async (callback) => callback({
      questionSet: {
        updateMany: async (args) => {
          transitionArgs = args;
          return { count: 1 };
        },
        findUniqueOrThrow: async () => ({
          ...draft,
          status: 'pendingReview',
          submittedAt: createdAt,
        }),
      },
    }),
  };
  const service = createPrismaLearningService(fakePrisma);

  const result = await service.submitQuestionSetForReview('submission_1');

  assert.deepEqual(transitionArgs.where, {
    id: 'submission_1',
    sourceType: 'community',
    status: 'draft',
  });
  assert.equal(result.status, 'pendingReview');
});

test('PrismaLearningService saves attempt and answer snapshots in one transaction', async () => {
  const now = new Date('2026-07-17T02:00:00.000Z');
  let createArgs;
  let transactionCalls = 0;
  const questionSet = {
    id: 'question_set_1',
    subjectId: 'subject_1',
    topicId: null,
    title: 'Snapshot title',
    description: 'Description',
    status: 'published',
    createdAt: now,
    updatedAt: now,
    questions: [{
      id: 'question_1',
      questionSetId: 'question_set_1',
      text: 'Snapshot question?',
      explanation: 'Snapshot explanation.',
      position: 1,
      createdAt: now,
      updatedAt: now,
      answerOptions: [
        { id: 'answer_1', questionId: 'question_1', text: 'Correct', position: 1, isCorrect: true, createdAt: now, updatedAt: now },
        { id: 'answer_2', questionId: 'question_1', text: 'Wrong', position: 2, isCorrect: false, createdAt: now, updatedAt: now },
      ],
    }],
  };
  const fakePrisma = {
    questionSet: { findFirst: async () => questionSet },
    examAttempt: { findUnique: async () => null },
    $transaction: async (callback) => {
      transactionCalls++;
      return callback({
        examAttempt: {
          create: async (args) => {
            createArgs = args;
            const answer = args.data.answers.create[0];
            return {
              id: 'attempt_1',
              userId: args.data.userId,
              submissionId: args.data.submissionId,
              requestFingerprint: args.data.requestFingerprint,
              questionSetId: args.data.questionSetId,
              sourceQuestionSetId: args.data.sourceQuestionSetId,
              questionSetTitle: args.data.questionSetTitle,
              startedAt: args.data.startedAt,
              completedAt: now,
              totalQuestions: args.data.totalQuestions,
              correctAnswers: args.data.correctAnswers,
              wrongAnswers: args.data.wrongAnswers,
              unansweredAnswers: args.data.unansweredAnswers,
              percentageScore: args.data.percentageScore,
              createdAt: now,
              answers: [{ id: 'attempt_answer_1', attemptId: 'attempt_1', createdAt: now, ...answer }],
            };
          },
        },
      });
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const outcome = await service.saveExamAttempt('demo-user', 'question_set_1', {
    submissionId: 'stable-key',
    startedAt: '2026-07-17T01:55:00.000Z',
    selectedAnswerOptionIdsByQuestionId: { question_1: 'answer_1' },
  });

  assert.equal(outcome.created, true);
  assert.equal(outcome.attempt.correctAnswers, 1);
  assert.equal(outcome.attempt.result.answerReviews[0].questionText, 'Snapshot question?');
  assert.equal(transactionCalls, 1);
  assert.equal(createArgs.data.answers.create.length, 1);
  assert.equal(createArgs.data.sourceQuestionSetId, 'question_set_1');
  assert.match(createArgs.data.requestFingerprint, /^[a-f0-9]{64}$/);
});

test('PrismaLearningService scopes history by owner and reuses idempotent attempts', async () => {
  const now = new Date('2026-07-17T02:00:00.000Z');
  const row = {
    id: 'attempt_1',
    userId: 'owner-a',
    submissionId: 'stable-key',
    requestFingerprint: createExamAttemptFingerprint(
      'question_set_1',
      {
        submissionId: 'stable-key',
        selectedAnswerOptionIdsByQuestionId: {},
      },
      null,
    ),
    questionSetId: 'question_set_1',
    sourceQuestionSetId: 'question_set_1',
    questionSetTitle: 'Snapshot title',
    startedAt: null,
    completedAt: now,
    totalQuestions: 1,
    correctAnswers: 1,
    wrongAnswers: 0,
    unansweredAnswers: 0,
    percentageScore: 100,
    createdAt: now,
    answers: [{
      id: 'answer_snapshot_1',
      attemptId: 'attempt_1',
      questionId: 'question_1',
      questionText: 'Question?',
      answerOptions: [{ id: 'answer_1', text: 'Correct' }],
      selectedAnswerOptionId: 'answer_1',
      selectedAnswerText: 'Correct',
      correctAnswerOptionId: 'answer_1',
      correctAnswerText: 'Correct',
      isCorrect: true,
      explanation: null,
      position: 1,
      createdAt: now,
    }],
  };
  let listArgs;
  let detailArgs;
  let transactionCalled = false;
  const fakePrisma = {
    examAttempt: {
      findUnique: async () => row,
      findMany: async (args) => {
        listArgs = args;
        return [row];
      },
      findFirst: async (args) => {
        detailArgs = args;
        return args.where.userId === 'owner-a' ? row : null;
      },
    },
    $transaction: async () => {
      transactionCalled = true;
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const duplicate = await service.saveExamAttempt('owner-a', 'question_set_1', {
    submissionId: 'stable-key',
    selectedAnswerOptionIdsByQuestionId: {},
  });
  const history = await service.listExamAttempts('owner-a');
  const detail = await service.getExamAttempt('owner-a', 'attempt_1');
  const hidden = await service.getExamAttempt('owner-b', 'attempt_1');

  assert.equal(duplicate.created, false);
  assert.equal(transactionCalled, false);
  assert.deepEqual(listArgs.where, { userId: 'owner-a' });
  assert.deepEqual(listArgs.orderBy, [
    { completedAt: 'desc' },
    { id: 'desc' },
  ]);
  assert.equal(listArgs.take, 100);
  assert.deepEqual(detailArgs.where, { id: 'attempt_1', userId: 'owner-b' });
  assert.equal(history.length, 1);
  assert.equal(detail.id, 'attempt_1');
  assert.equal(hidden, null);
});

test('PrismaLearningService surfaces a failed transactional attempt write', async () => {
  const now = new Date('2026-07-17T02:00:00.000Z');
  const questionSet = {
    id: 'question_set_1',
    subjectId: 'subject_1',
    topicId: null,
    title: 'Transactional set',
    description: 'Description',
    status: 'published',
    createdAt: now,
    updatedAt: now,
    questions: [{
      id: 'question_1',
      questionSetId: 'question_set_1',
      text: 'Question?',
      explanation: null,
      position: 1,
      createdAt: now,
      updatedAt: now,
      answerOptions: [
        { id: 'answer_1', questionId: 'question_1', text: 'Correct', position: 1, isCorrect: true, createdAt: now, updatedAt: now },
      ],
    }],
  };
  let transactionCalls = 0;
  const fakePrisma = {
    questionSet: { findFirst: async () => questionSet },
    examAttempt: { findUnique: async () => null },
    $transaction: async (callback) => {
      transactionCalls++;
      return callback({
        examAttempt: {
          create: async () => {
            throw new Error('snapshot write failed');
          },
        },
      });
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  await assert.rejects(
    service.saveExamAttempt('demo-user', 'question_set_1', {
      submissionId: 'failed-write',
      selectedAnswerOptionIdsByQuestionId: { question_1: 'answer_1' },
    }),
    /snapshot write failed/,
  );
  assert.equal(transactionCalls, 1);
});
