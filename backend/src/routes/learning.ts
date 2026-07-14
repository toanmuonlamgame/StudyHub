import type {
  FastifyPluginAsync,
  FastifyReply,
} from 'fastify';

import {
  InvalidQuizSubmissionError,
  InvalidLearningListQueryError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  type LearningService,
} from '../services/learningService.js';
import type {
  CheckAnswerBody,
  StudyMaterialType,
  SubmitQuizBody,
} from '../types/learning.js';

interface SubjectParams {
  subjectId: string;
}

interface QuestionSetParams {
  questionSetId: string;
}

interface QuestionParams {
  questionId: string;
}

interface MaterialParams {
  materialId: string;
}

interface StudyMaterialListQuery extends QuestionSetListQuery {
  materialType?: string;
  language?: string;
}

interface QuestionSetListQuery {
  subjectId?: string;
  topicId?: string;
  q?: string;
  limit?: string;
  cursor?: string;
}

const DEFAULT_LIST_LIMIT = 20;
const MAX_LIST_LIMIT = 50;
const STUDY_MATERIAL_TYPES = new Set<StudyMaterialType>([
  'pdf',
  'slides',
  'notes',
  'document',
  'link',
  'other',
]);

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

const checkAnswerBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['selectedAnswerOptionId'],
  properties: {
    selectedAnswerOptionId: { type: 'string', minLength: 1 },
  },
} as const;

function sendLearningError(error: unknown, reply: FastifyReply): FastifyReply {
  if (error instanceof LearningResourceNotFoundError) {
    return reply.code(404).send({ error: error.message });
  }
  if (error instanceof InvalidQuizSubmissionError) {
    return reply.code(400).send({ error: error.message });
  }
  if (error instanceof InvalidLearningListQueryError) {
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
    app.get<{ Querystring: StudyMaterialListQuery }>(
      '/materials',
      async (request, reply) => {
        const limit = parseListLimit(request.query.limit);
        if (limit === null) {
          return reply.code(400).send({
            error: `limit must be an integer between 1 and ${MAX_LIST_LIMIT}.`,
          });
        }
        const materialType = request.query.materialType;
        if (
          materialType !== undefined &&
          !STUDY_MATERIAL_TYPES.has(materialType as StudyMaterialType)
        ) {
          return reply.code(400).send({ error: 'materialType is invalid.' });
        }

        try {
          return await service.listStudyMaterials({
            limit,
            ...(request.query.subjectId === undefined
              ? {}
              : { subjectId: request.query.subjectId }),
            ...(request.query.topicId === undefined
              ? {}
              : { topicId: request.query.topicId }),
            ...(request.query.q === undefined ? {} : { q: request.query.q }),
            ...(materialType === undefined
              ? {}
              : { materialType: materialType as StudyMaterialType }),
            ...(request.query.language === undefined
              ? {}
              : { language: request.query.language }),
            ...(request.query.cursor === undefined
              ? {}
              : { cursor: request.query.cursor }),
          });
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get<{ Params: MaterialParams }>(
      '/materials/:materialId',
      async (request, reply) => {
        try {
          const material = await service.getStudyMaterialById(
            request.params.materialId,
          );
          if (material === null) {
            return reply.code(404).send({ error: 'Study material not found.' });
          }
          return { material };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get<{ Querystring: QuestionSetListQuery }>(
      '/question-sets',
      async (request, reply) => {
        const limit = parseListLimit(request.query.limit);
        if (limit === null) {
          return reply.code(400).send({
            error: `limit must be an integer between 1 and ${MAX_LIST_LIMIT}.`,
          });
        }

        try {
          return await service.listQuestionSets({
            limit,
            ...(request.query.subjectId === undefined
              ? {}
              : { subjectId: request.query.subjectId }),
            ...(request.query.topicId === undefined
              ? {}
              : { topicId: request.query.topicId }),
            ...(request.query.q === undefined ? {} : { q: request.query.q }),
            ...(request.query.cursor === undefined
              ? {}
              : { cursor: request.query.cursor }),
          });
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

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

    app.post<{ Params: QuestionParams; Body: CheckAnswerBody }>(
      '/questions/:questionId/check-answer',
      { schema: { body: checkAnswerBodySchema } },
      async (request, reply) => {
        try {
          const result = await service.checkAnswer(
            request.params.questionId,
            request.body.selectedAnswerOptionId,
          );
          return { result };
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

function parseListLimit(value: string | undefined): number | null {
  if (value === undefined) {
    return DEFAULT_LIST_LIMIT;
  }
  if (!/^\d+$/.test(value)) {
    return null;
  }
  const limit = Number(value);
  return Number.isSafeInteger(limit) && limit >= 1 && limit <= MAX_LIST_LIMIT
    ? limit
    : null;
}
