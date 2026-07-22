import type { FastifyPluginAsync, FastifyRequest } from 'fastify';

import type { RequireUser } from './auth.js';
import {
  AdminForbiddenError,
  type AdminService,
  AdminValidationError,
} from '../services/adminService.js';
import type { AdminContributionListParams, AdminQuestionSetListParams, AdminUserListParams } from '../types/admin.js';

const moderationStatuses = ['draft', 'pendingReview', 'published', 'rejected'] as const;
const pageQuerySchema = {
  type: 'object',
  additionalProperties: false,
  properties: {
    page: { type: 'string', pattern: '^[1-9][0-9]*$' },
    limit: { type: 'string', pattern: '^[1-9][0-9]*$' },
    q: { type: 'string', maxLength: 120 },
    status: { type: 'string' },
    subjectId: { type: 'string', maxLength: 120 },
    topicId: { type: 'string', maxLength: 120 },
    archived: { type: 'string', enum: ['true', 'false'] },
    role: { type: 'string', enum: ['user', 'admin'] },
    broken: { type: 'string', enum: ['true', 'false'] },
  },
} as const;

const rejectBodySchema = objectSchema(
  { reason: { type: 'string', minLength: 3, maxLength: 1000 } },
  ['reason'],
);
const updateSetBodySchema = objectSchema({
  title: { type: 'string', minLength: 1, maxLength: 120 },
  description: { type: 'string', maxLength: 2000 },
  subjectId: { type: 'string', minLength: 1, maxLength: 120 },
  topicId: { anyOf: [{ type: 'string', minLength: 1, maxLength: 120 }, { type: 'null' }] },
  isArchived: { type: 'boolean' },
});
const createSubjectBodySchema = objectSchema(
  {
    name: { type: 'string', minLength: 1, maxLength: 120 },
    description: { type: 'string', maxLength: 1000 },
  },
  ['name'],
);
const updateSubjectBodySchema = objectSchema({
  name: { type: 'string', minLength: 1, maxLength: 120 },
  description: { anyOf: [{ type: 'string', maxLength: 1000 }, { type: 'null' }] },
  isArchived: { type: 'boolean' },
});
const createTopicBodySchema = objectSchema(
  {
    subjectId: { type: 'string', minLength: 1, maxLength: 120 },
    name: { type: 'string', minLength: 1, maxLength: 120 },
  },
  ['subjectId', 'name'],
);
const updateTopicBodySchema = objectSchema({
  subjectId: { type: 'string', minLength: 1, maxLength: 120 },
  name: { type: 'string', minLength: 1, maxLength: 120 },
  isArchived: { type: 'boolean' },
});
const updateUserBodySchema = objectSchema({
  role: { type: 'string', enum: ['user', 'admin'] },
  status: { type: 'string', enum: ['active', 'disabled'] },
});

export function createAdminRoutes(service: AdminService, requireUser: RequireUser): FastifyPluginAsync {
  return async function adminRoutes(app): Promise<void> {
    app.addHook('preHandler', async (request) => {
      const user = await requireUser(request);
      if (user.role !== 'admin' || user.status !== 'active') {
        throw new AdminForbiddenError('Administrator access is required.');
      }
      request.adminUser = user;
    });

    app.get('/dashboard', async () => ({ summary: await service.getDashboard() }));

    app.get('/contributions', { schema: { querystring: pageQuerySchema } }, async (request) => ({
      page: await service.listContributions(readContributionParams(request.query)),
    }));
    app.get<{ Params: { id: string } }>('/contributions/:id', async (request, reply) => {
      const contribution = await service.getContribution(request.params.id);
      return contribution === null
        ? reply.code(404).send({ error: 'Contribution not found.' })
        : { contribution };
    });
    app.post<{ Params: { id: string } }>('/contributions/:id/approve', async (request) => ({
      contribution: await service.approveContribution(request.params.id, request.adminUser.id),
    }));
    app.post<{ Params: { id: string }; Body: { reason: string } }>(
      '/contributions/:id/reject',
      { schema: { body: rejectBodySchema } },
      async (request) => ({
        contribution: await service.rejectContribution(request.params.id, request.adminUser.id, request.body.reason),
      }),
    );

    app.get('/question-sets', { schema: { querystring: pageQuerySchema } }, async (request) => ({
      page: await service.listQuestionSets(readQuestionSetParams(request.query)),
    }));
    app.get<{ Params: { id: string } }>('/question-sets/:id', async (request, reply) => {
      const questionSet = await service.getQuestionSet(request.params.id);
      return questionSet === null
        ? reply.code(404).send({ error: 'Question set not found.' })
        : { questionSet };
    });
    app.patch<{ Params: { id: string }; Body: Parameters<AdminService['updateQuestionSet']>[1] }>(
      '/question-sets/:id',
      { schema: { body: updateSetBodySchema } },
      async (request) => ({ questionSet: await service.updateQuestionSet(request.params.id, request.body) }),
    );

    app.get('/subjects', async () => ({ subjects: await service.listSubjects() }));
    app.post<{ Body: { name: string; description?: string } }>(
      '/subjects',
      { schema: { body: createSubjectBodySchema } },
      async (request, reply) => reply.code(201).send({ subject: await service.createSubject(request.body) }),
    );
    app.patch<{ Params: { id: string }; Body: Parameters<AdminService['updateSubject']>[1] }>(
      '/subjects/:id',
      { schema: { body: updateSubjectBodySchema } },
      async (request) => ({ subject: await service.updateSubject(request.params.id, request.body) }),
    );

    app.get('/topics', { schema: { querystring: pageQuerySchema } }, async (request) => {
      const query = request.query as Record<string, string | undefined>;
      return { topics: await service.listTopics(query.subjectId) };
    });
    app.post<{ Body: { subjectId: string; name: string } }>(
      '/topics',
      { schema: { body: createTopicBodySchema } },
      async (request, reply) => reply.code(201).send({ topic: await service.createTopic(request.body) }),
    );
    app.patch<{ Params: { id: string }; Body: Parameters<AdminService['updateTopic']>[1] }>(
      '/topics/:id',
      { schema: { body: updateTopicBodySchema } },
      async (request) => ({ topic: await service.updateTopic(request.params.id, request.body) }),
    );

    app.get('/users', { schema: { querystring: pageQuerySchema } }, async (request) => ({
      page: await service.listUsers(readUserParams(request.query)),
    }));
    app.get<{ Params: { id: string } }>('/users/:id', async (request, reply) => {
      const user = await service.getUser(request.params.id);
      return user === null ? reply.code(404).send({ error: 'User not found.' }) : { user };
    });
    app.patch<{ Params: { id: string }; Body: Parameters<AdminService['updateUser']>[2] }>(
      '/users/:id',
      { schema: { body: updateUserBodySchema } },
      async (request) => ({
        user: await service.updateUser(request.params.id, request.adminUser.id, request.body),
      }),
    );

    app.get('/media', { schema: { querystring: pageQuerySchema } }, async (request) => {
      const query = request.query as Record<string, string | undefined>;
      return {
        page: await service.listMedia({
          ...readPage(query),
          ...(query.q ? { q: query.q } : {}),
          ...(query.broken === undefined ? {} : { broken: query.broken === 'true' }),
        }),
      };
    });
  };
}

declare module 'fastify' {
  interface FastifyRequest {
    adminUser: Awaited<ReturnType<RequireUser>>;
  }
}

function readContributionParams(value: unknown): AdminContributionListParams {
  const query = value as Record<string, string | undefined>;
  const status = readStatus(query.status);
  return {
    ...readPage(query),
    ...(query.q ? { q: query.q } : {}),
    ...(status ? { status } : {}),
    ...(query.subjectId ? { subjectId: query.subjectId } : {}),
    ...(query.topicId ? { topicId: query.topicId } : {}),
  };
}

function readQuestionSetParams(value: unknown): AdminQuestionSetListParams {
  const query = value as Record<string, string | undefined>;
  return {
    ...readContributionParams(query),
    ...(query.archived === undefined ? {} : { archived: query.archived === 'true' }),
  };
}

function readUserParams(value: unknown): AdminUserListParams {
  const query = value as Record<string, string | undefined>;
  return {
    ...readPage(query),
    ...(query.q ? { q: query.q } : {}),
    ...(query.role === 'user' || query.role === 'admin' ? { role: query.role } : {}),
    ...(query.status === 'active' || query.status === 'disabled' ? { status: query.status } : {}),
  };
}

function readPage(query: Record<string, string | undefined>): { page: number; limit: number } {
  const page = query.page === undefined ? 1 : Number(query.page);
  const limit = query.limit === undefined ? 20 : Number(query.limit);
  if (!Number.isInteger(page) || page < 1) throw new AdminValidationError('page must be a positive integer.');
  if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw new AdminValidationError('limit must be between 1 and 50.');
  return { page, limit };
}

function readStatus(value: string | undefined) {
  if (value === undefined) return undefined;
  if (!moderationStatuses.includes(value as (typeof moderationStatuses)[number])) {
    throw new AdminValidationError('Unsupported moderation status.');
  }
  return value as (typeof moderationStatuses)[number];
}

function objectSchema(properties: Record<string, unknown>, required: string[] = []) {
  return { type: 'object', additionalProperties: false, properties, ...(required.length ? { required } : {}) } as const;
}
