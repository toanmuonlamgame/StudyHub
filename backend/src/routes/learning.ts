import type {
  FastifyPluginAsync,
  FastifyReply,
} from 'fastify';

import { sendAuthError, type RequireUser } from './auth.js';
import { AuthenticationRequiredError } from '../services/authService.js';

import {
  ExamAttemptIdempotencyConflictError,
  InvalidQuizSubmissionError,
  InvalidLearningListQueryError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  QuestionSetSubmissionStateError,
  QuestionSetSubmissionIdempotencyConflictError,
  QuestionSetSubmissionValidationError,
  type LearningService,
} from '../services/learningService.js';
import type {
  CheckAnswerBody,
  SaveExamAttemptInput,
  StudyMaterialType,
  SubmitQuizBody,
} from '../types/learning.js';
import type { QuestionSetSubmissionInput } from '../types/questionSetSubmission.js';

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

interface SubmissionParams {
  submissionId: string;
}

interface AttemptParams {
  attemptId: string;
}

interface AtomicQuestionSetSubmissionBody extends QuestionSetSubmissionInput {
  submissionId: string;
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

const saveExamAttemptBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['submissionId', 'selectedAnswerOptionIdsByQuestionId'],
  properties: {
    submissionId: { type: 'string', minLength: 1, maxLength: 128 },
    startedAt: { type: 'string', format: 'date-time' },
    selectedAnswerOptionIdsByQuestionId: {
      type: 'object',
      additionalProperties: { type: 'string', minLength: 1 },
    },
  },
} as const;

const answerOptionSubmissionSchema = {
  type: 'object',
  additionalProperties: false,
  required: ['text', 'isCorrect'],
  properties: {
    text: { type: 'string' },
    isCorrect: { type: 'boolean' },
  },
} as const;

const questionSetSubmissionBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['subjectId', 'title', 'description', 'questions'],
  properties: {
    subjectId: { type: 'string' },
    topicId: { type: 'string' },
    title: { type: 'string' },
    description: { type: 'string' },
    questions: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['text', 'answerOptions'],
        properties: {
          text: { type: 'string' },
          explanation: { type: 'string' },
          answerOptions: { type: 'array', items: answerOptionSubmissionSchema },
        },
      },
    },
  },
} as const;

const atomicQuestionSetSubmissionBodySchema = {
  ...questionSetSubmissionBodySchema,
  required: [...questionSetSubmissionBodySchema.required, 'submissionId'],
  properties: {
    ...questionSetSubmissionBodySchema.properties,
    submissionId: { type: 'string', minLength: 1, maxLength: 128 },
  },
} as const;

function sendLearningError(error: unknown, reply: FastifyReply): FastifyReply {
  if (error instanceof AuthenticationRequiredError) {
    return sendAuthError(error, reply);
  }
  if (error instanceof LearningResourceNotFoundError) {
    return reply.code(404).send({ error: error.message });
  }
  if (error instanceof InvalidQuizSubmissionError) {
    return reply.code(400).send({ error: error.message });
  }
  if (error instanceof InvalidLearningListQueryError) {
    return reply.code(400).send({ error: error.message });
  }
  if (error instanceof ExamAttemptIdempotencyConflictError) {
    return reply.code(409).send({ error: error.message });
  }
  if (error instanceof QuestionSetSubmissionIdempotencyConflictError) {
    return reply.code(409).send({
      error: {
        code: 'SUBMISSION_IDEMPOTENCY_CONFLICT',
        message: error.message,
        fields: [],
      },
    });
  }
  if (error instanceof LearningDataIntegrityError) {
    return reply
      .code(500)
      .send({ error: 'Learning data is temporarily unavailable.' });
  }
  if (error instanceof QuestionSetSubmissionValidationError) {
    return reply.code(400).send({
      error: {
        code: 'SUBMISSION_VALIDATION_FAILED',
        message: error.message,
        fields: error.fields,
      },
    });
  }
  if (error instanceof QuestionSetSubmissionStateError) {
    return reply.code(409).send({
      error: { code: 'SUBMISSION_STATE_CONFLICT', message: error.message, fields: [] },
    });
  }
  throw error;
}

export function createLearningRoutes(
  service: LearningService,
  requireUser: RequireUser,
): FastifyPluginAsync {
  return async function learningRoutes(app): Promise<void> {
    app.post<{ Body: QuestionSetSubmissionInput }>(
      '/question-set-submissions',
      { schema: { body: questionSetSubmissionBodySchema } },
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          const submission = await service.createQuestionSetSubmission(user.id, request.body);
          return reply.code(201).send({ submission });
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.post<{ Body: AtomicQuestionSetSubmissionBody }>(
      '/question-set-submissions/submit',
      { schema: { body: atomicQuestionSetSubmissionBodySchema } },
      async (request, reply) => {
        try {
          const { submissionId, ...input } = request.body;
          const normalizedSubmissionId = submissionId.trim();
          if (normalizedSubmissionId.length === 0) {
            return reply.code(400).send({
              error: {
                code: 'SUBMISSION_VALIDATION_FAILED',
                message: 'Submission validation failed.',
                fields: [
                  {
                    path: 'submissionId',
                    message: 'Submission ID is required.',
                  },
                ],
              },
            });
          }
          const user = await requireUser(request);
          const outcome = await service.createQuestionSetSubmissionForReview(
            user.id,
            normalizedSubmissionId,
            input,
          );
          return reply
            .code(outcome.created ? 201 : 200)
            .send({ submission: outcome.submission });
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.get('/question-set-submissions', async (request, reply) => {
      try {
        const user = await requireUser(request);
        return { submissions: await service.listQuestionSetSubmissions(user.id) };
      } catch (error) {
        return sendLearningError(error, reply);
      }
    });

    app.get<{ Params: SubmissionParams }>(
      '/question-set-submissions/:submissionId',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          const submission = await service.getQuestionSetSubmission(
            user.id,
            request.params.submissionId,
          );
          return submission === null
            ? reply.code(404).send({ error: 'Submission not found.' })
            : { submission };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.put<{ Params: SubmissionParams; Body: QuestionSetSubmissionInput }>(
      '/question-set-submissions/:submissionId',
      { schema: { body: questionSetSubmissionBodySchema } },
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          return {
            submission: await service.updateQuestionSetSubmission(
              user.id,
              request.params.submissionId,
              request.body,
            ),
          };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.delete<{ Params: SubmissionParams }>(
      '/question-set-submissions/:submissionId',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          await service.deleteQuestionSetSubmission(user.id, request.params.submissionId);
          return reply.code(204).send();
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.post<{ Params: SubmissionParams }>(
      '/question-set-submissions/:submissionId/submit',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          return {
            submission: await service.submitQuestionSetForReview(
              user.id,
              request.params.submissionId,
            ),
          };
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );
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

    app.post<{ Params: QuestionSetParams; Body: SaveExamAttemptInput }>(
      '/question-sets/:questionSetId/attempts',
      { schema: { body: saveExamAttemptBodySchema } },
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          const outcome = await service.saveExamAttempt(
            user.id,
            request.params.questionSetId,
            request.body,
          );
          return reply
            .code(outcome.created ? 201 : 200)
            .send({ attempt: outcome.attempt });
        } catch (error) {
          if (
            error instanceof LearningResourceNotFoundError ||
            error instanceof InvalidQuizSubmissionError ||
            error instanceof LearningDataIntegrityError ||
            error instanceof ExamAttemptIdempotencyConflictError ||
            error instanceof AuthenticationRequiredError
          ) {
            return sendLearningError(error, reply);
          }
          request.log.error(error, 'Unable to save exam attempt.');
          return reply.code(500).send({ error: 'Unable to save exam attempt.' });
        }
      },
    );

    app.get('/attempts', async (request, reply) => {
      try {
        const user = await requireUser(request);
        return {
          attempts: await service.listExamAttempts(user.id),
        };
      } catch (error) {
        request.log.error(error, 'Unable to load exam attempts.');
        return reply.code(500).send({ error: 'Unable to load exam attempts.' });
      }
    });

    app.get<{ Params: AttemptParams }>(
      '/attempts/:attemptId',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          const attempt = await service.getExamAttempt(
            user.id,
            request.params.attemptId,
          );
          return attempt === null
            ? reply.code(404).send({ error: 'Exam attempt not found.' })
            : { attempt };
        } catch (error) {
          request.log.error(error, 'Unable to load exam attempt.');
          return reply.code(500).send({ error: 'Unable to load exam attempt.' });
        }
      },
    );

    app.get('/bookmarks', async (request, reply) => {
      try {
        const user = await requireUser(request);
        return { items: await service.listBookmarkedQuestionSets(user.id) };
      } catch (error) {
        return sendLearningError(error, reply);
      }
    });

    app.put<{ Params: QuestionSetParams }>(
      '/bookmarks/:questionSetId',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          const questionSet = await service.bookmarkQuestionSet(
            user.id,
            request.params.questionSetId,
          );
          return reply.code(200).send({ questionSet });
        } catch (error) {
          return sendLearningError(error, reply);
        }
      },
    );

    app.delete<{ Params: QuestionSetParams }>(
      '/bookmarks/:questionSetId',
      async (request, reply) => {
        try {
          const user = await requireUser(request);
          await service.removeQuestionSetBookmark(user.id, request.params.questionSetId);
          return reply.code(204).send();
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
