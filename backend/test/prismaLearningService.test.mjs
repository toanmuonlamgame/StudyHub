import assert from 'node:assert/strict';
import test from 'node:test';

import { mapQuestion } from '../dist/services/learningMappers.js';
import { createPrismaLearningService } from '../dist/services/prismaLearningService.js';

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
  const fakePrisma = {
    questionSet: {
      findUnique: async () => ({
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
      }),
    },
  };
  const service = createPrismaLearningService(fakePrisma);

  const result = await service.submitQuiz('question_set_1', {
    question_1: 'answer_1',
  });

  assert.equal(result.totalQuestions, 1);
  assert.equal(result.correctAnswers, 0);
  assert.equal(result.wrongAnswers, 1);
  assert.equal(result.percentageScore, 0);
  assert.deepEqual(result.answerReviews, [
    {
      questionId: 'question_1',
      questionText: 'First question?',
      selectedAnswerOptionId: 'answer_1',
      selectedAnswerText: 'Wrong answer',
      correctAnswerOptionId: 'answer_2',
      correctAnswerText: 'Correct answer',
      isCorrect: false,
    },
  ]);
});

test('PrismaLearningService checkAnswer uses internal correctness data', async () => {
  const fakePrisma = {
    question: {
      findUnique: async () => ({
        id: 'question_1',
        questionSetId: 'question_set_1',
        text: 'First question?',
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
      }),
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
  });
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
