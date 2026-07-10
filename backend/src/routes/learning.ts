import type { FastifyInstance } from 'fastify';

import {
  getCorrectAnswerOptionId,
  questions,
  questionSets,
  subjects,
  topics,
} from '../data/mockLearningData.js';
import type {
  AnswerReview,
  QuizResult,
  SubmitQuizBody,
} from '../types/learning.js';

interface SubjectParams {
  subjectId: string;
}

interface QuestionSetParams {
  questionSetId: string;
}

const submitQuizBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['selectedAnswerOptionIdsByQuestionId'],
  properties: {
    selectedAnswerOptionIdsByQuestionId: {
      type: 'object',
      additionalProperties: { type: 'string' },
    },
  },
} as const;

export async function learningRoutes(app: FastifyInstance): Promise<void> {
  app.get('/subjects', async () => ({ subjects }));

  app.get<{ Params: SubjectParams }>(
    '/subjects/:subjectId/topics',
    async (request, reply) => {
      const subject = subjects.find(({ id }) => id === request.params.subjectId);
      if (subject === undefined) {
        return reply.code(404).send({ error: 'Subject not found.' });
      }

      return {
        topics: topics.filter(({ subjectId }) => subjectId === subject.id),
      };
    },
  );

  app.get<{ Params: SubjectParams }>(
    '/subjects/:subjectId/question-sets',
    async (request, reply) => {
      const subject = subjects.find(({ id }) => id === request.params.subjectId);
      if (subject === undefined) {
        return reply.code(404).send({ error: 'Subject not found.' });
      }

      return {
        questionSets: questionSets.filter(
          ({ subjectId }) => subjectId === subject.id,
        ),
      };
    },
  );

  app.get<{ Params: QuestionSetParams }>(
    '/question-sets/:questionSetId',
    async (request, reply) => {
      const questionSet = questionSets.find(
        ({ id }) => id === request.params.questionSetId,
      );
      if (questionSet === undefined) {
        return reply.code(404).send({ error: 'Question set not found.' });
      }

      return { questionSet };
    },
  );

  app.get<{ Params: QuestionSetParams }>(
    '/question-sets/:questionSetId/questions',
    async (request, reply) => {
      const questionSet = questionSets.find(
        ({ id }) => id === request.params.questionSetId,
      );
      if (questionSet === undefined) {
        return reply.code(404).send({ error: 'Question set not found.' });
      }

      return {
        questions: questions.filter(
          ({ questionSetId }) => questionSetId === questionSet.id,
        ),
      };
    },
  );

  app.post<{ Params: QuestionSetParams; Body: SubmitQuizBody }>(
    '/question-sets/:questionSetId/submit',
    { schema: { body: submitQuizBodySchema } },
    async (request, reply) => {
      const questionSet = questionSets.find(
        ({ id }) => id === request.params.questionSetId,
      );
      if (questionSet === undefined) {
        return reply.code(404).send({ error: 'Question set not found.' });
      }

      const questionSetQuestions = questions.filter(
        ({ questionSetId }) => questionSetId === questionSet.id,
      );
      const selections = request.body.selectedAnswerOptionIdsByQuestionId;
      const questionIds = new Set(
        questionSetQuestions.map(({ id }) => id),
      );

      for (const questionId of Object.keys(selections)) {
        if (!questionIds.has(questionId)) {
          return reply.code(400).send({
            error: `Question ${questionId} does not belong to this question set.`,
          });
        }
      }

      const answerReviews: AnswerReview[] = [];

      for (const question of questionSetQuestions) {
        const selectedAnswerOptionId = selections[question.id];
        const selectedAnswer = question.answerOptions.find(
          ({ id }) => id === selectedAnswerOptionId,
        );
        if (selectedAnswer === undefined) {
          return reply.code(400).send({
            error: `A valid answer is required for question ${question.id}.`,
          });
        }

        const correctAnswerOptionId = getCorrectAnswerOptionId(question.id);
        if (correctAnswerOptionId === undefined) {
          return reply.code(500).send({
            error: `Answer key is missing for question ${question.id}.`,
          });
        }

        const correctAnswer = question.answerOptions.find(
          ({ id }) => id === correctAnswerOptionId,
        );
        if (correctAnswer === undefined) {
          return reply.code(500).send({
            error: `Answer key is invalid for question ${question.id}.`,
          });
        }

        answerReviews.push({
          questionId: question.id,
          questionText: question.text,
          selectedAnswerOptionId: selectedAnswer.id,
          selectedAnswerText: selectedAnswer.text,
          correctAnswerOptionId: correctAnswer.id,
          correctAnswerText: correctAnswer.text,
          isCorrect: selectedAnswer.id === correctAnswer.id,
        });
      }

      const correctAnswers = answerReviews.filter(
        ({ isCorrect }) => isCorrect,
      ).length;
      const totalQuestions = questionSetQuestions.length;
      const result: QuizResult = {
        questionSetId: questionSet.id,
        questionSetTitle: questionSet.title,
        totalQuestions,
        correctAnswers,
        wrongAnswers: totalQuestions - correctAnswers,
        percentageScore:
          totalQuestions === 0 ? 0 : (correctAnswers / totalQuestions) * 100,
        answerReviews,
      };

      return { result };
    },
  );
}
