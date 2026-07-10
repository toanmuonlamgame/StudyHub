import type {
  FastifyPluginAsync,
  FastifyReply,
} from 'fastify';

import {
  InvalidQuizSubmissionError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  type LearningService,
} from '../services/learningService.js';
import type { SubmitQuizBody } from '../types/learning.js';

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

function sendLearningError(error: unknown, reply: FastifyReply): FastifyReply {
  if (error instanceof LearningResourceNotFoundError) {
    return reply.code(404).send({ error: error.message });
  }
  if (error instanceof InvalidQuizSubmissionError) {
    return reply.code(400).send({ error: error.message });
  }
  if (error instanceof LearningDataIntegrityError) {
    return reply.code(500).send({ error: error.message });
  }
  throw error;
}

export function createLearningRoutes(
  service: LearningService,
): FastifyPluginAsync {
  return async function learningRoutes(app): Promise<void> {
    app.get('/subjects', async (_request, reply) => {
      try {
        return { subjects: await service.getSubjects() };
      } catch (error) {
        return sendLearningError(error, reply);
      }
    });

    app.get<{ Params: SubjectParams }>(
      '/subjects/:subjectId/topics',
      async (request, reply) => {
        try {
          return {
            topics: await service.getTopicsBySubjectId(
              request.params.subjectId,
            ),
          };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get<{ Params: SubjectParams }>(
      '/subjects/:subjectId/question-sets',
      async (request, reply) => {
        try {
          return {
            questionSets: await service.getQuestionSetsBySubjectId(
              request.params.subjectId,
            ),
          };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get<{ Params: QuestionSetParams }>(
      '/question-sets/:questionSetId',
      async (request, reply) => {
        try {
          const questionSet = await service.getQuestionSetById(
            request.params.questionSetId,
          );
          if (questionSet === null) {
            return reply.code(404).send({ error: 'Question set not found.' });
          }
          return { questionSet };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get<{ Params: QuestionSetParams }>(
      '/question-sets/:questionSetId/questions',
      async (request, reply) => {
        try {
          return {
            questions: await service.getQuestionsByQuestionSetId(
              request.params.questionSetId,
            ),
          };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.post<{ Params: QuestionSetParams; Body: SubmitQuizBody }>(
      '/question-sets/:questionSetId/submit',
      { schema: { body: submitQuizBodySchema } },
      async (request, reply) => {
        try {
          const result = await service.submitQuiz(
            request.params.questionSetId,
            request.body.selectedAnswerOptionIdsByQuestionId,
          );
          return { result };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );
  };
}
