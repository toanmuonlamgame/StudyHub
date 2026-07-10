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
