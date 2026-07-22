import cors from '@fastify/cors';
import Fastify, { type FastifyInstance } from 'fastify';

import { createAuthRoutes, createRequireUser, type RequireUser } from './routes/auth.js';
import { createAdminRoutes } from './routes/admin.js';
import { createLearningRoutes } from './routes/learning.js';
import { createMediaRoutes } from './routes/media.js';
import type { AuthService } from './services/authService.js';
import type { AdminService } from './services/adminService.js';
import { InMemoryAdminService } from './services/inMemoryAdminService.js';
import { InMemoryAuthService } from './services/inMemoryAuthService.js';
import { InMemoryLearningService } from './services/inMemoryLearningService.js';
import type { LearningService } from './services/learningService.js';
import { createPrismaAuthService } from './services/prismaAuthService.js';
import { createPrismaAdminService } from './services/prismaAdminService.js';
import { createPrismaLearningService } from './services/prismaLearningService.js';
import { LocalMediaStorage, type MediaStorage } from './services/mediaStorage.js';

export interface BuildAppOptions {
  learningService?: LearningService;
  authService?: AuthService;
  adminService?: AdminService;
  learningDataSource?: string;
  isProduction?: boolean;
  corsOrigins?: string[];
  requireUser?: RequireUser;
  mediaStorage?: MediaStorage;
}

const requestBodyLimitBytes = 1024 * 1024;

function isAllowedDevelopmentOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    const isLoopbackHost =
      url.hostname === 'localhost' || url.hostname === '127.0.0.1';
    const port = Number(url.port);

    return (
      url.protocol === 'http:' &&
      isLoopbackHost &&
      url.port.length > 0 &&
      Number.isInteger(port) &&
      port >= 1 &&
      port <= 65535 &&
      url.origin === origin
    );
  } catch {
    return false;
  }
}

function createConfiguredLearningService(dataSource: string): LearningService {
  if (dataSource === 'memory') {
    return new InMemoryLearningService();
  }
  if (dataSource === 'prisma') {
    if (!process.env.DATABASE_URL?.trim()) {
      throw new Error(
        'STUDYHUB_LEARNING_DATA_SOURCE=prisma requires DATABASE_URL.',
      );
    }
    return createPrismaLearningService();
  }
  throw new Error(
    `Unsupported STUDYHUB_LEARNING_DATA_SOURCE: ${dataSource}. ` +
      'Use memory or prisma.',
  );
}

function createConfiguredAuthService(dataSource: string): AuthService {
  if (dataSource === 'memory') return new InMemoryAuthService();
  if (dataSource === 'prisma') return createPrismaAuthService();
  throw new Error(`Unsupported STUDYHUB_LEARNING_DATA_SOURCE: ${dataSource}.`);
}

function createConfiguredAdminService(dataSource: string): AdminService {
  if (dataSource === 'memory') return new InMemoryAdminService();
  if (dataSource === 'prisma') return createPrismaAdminService();
  throw new Error(`Unsupported STUDYHUB_LEARNING_DATA_SOURCE: ${dataSource}.`);
}

export function buildApp(options: BuildAppOptions = {}): FastifyInstance {
  const isProduction = options.isProduction ?? process.env.NODE_ENV === 'production';
  const configuredDataSource =
    options.learningDataSource ?? process.env.STUDYHUB_LEARNING_DATA_SOURCE;
  if (isProduction && configuredDataSource === undefined && options.learningService === undefined) {
    throw new Error(
      'Production requires STUDYHUB_LEARNING_DATA_SOURCE=prisma.',
    );
  }
  const dataSource =
    configuredDataSource ?? 'memory';
  if (isProduction && dataSource !== 'prisma' && options.learningService === undefined) {
    throw new Error('Production requires STUDYHUB_LEARNING_DATA_SOURCE=prisma.');
  }
  const learningService =
    options.learningService ?? createConfiguredLearningService(dataSource);
  const authService = options.authService ?? createConfiguredAuthService(dataSource);
  const adminService = options.adminService ?? createConfiguredAdminService(dataSource);
  const requireUser = options.requireUser ?? createRequireUser(authService);
  const configuredCorsOrigins = new Set(
    options.corsOrigins ?? readConfiguredCorsOrigins(),
  );
  const app = Fastify({
    logger: true,
    bodyLimit: requestBodyLimitBytes,
    ajv: { customOptions: { removeAdditional: false } },
  });

  app.setErrorHandler((error, request, reply) => {
    const statusCode = readErrorStatusCode(error);
    if (statusCode !== null && statusCode < 500) {
      const message = error instanceof Error ? error.message : 'Bad request.';
      return reply.code(statusCode).send({ error: message });
    }
    request.log.error({ err: error }, 'Unhandled request error');
    return reply.code(500).send({ error: 'Internal server error.' });
  });

  app.register(cors, {
    origin: (origin, callback) => {
      callback(
        null,
        origin === undefined ||
          configuredCorsOrigins.has(origin) ||
          (!isProduction && isAllowedDevelopmentOrigin(origin)),
      );
    },
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'studyhub-backend',
  }));

  app.register(createAuthRoutes(authService), { prefix: '/auth' });
  app.register(createAdminRoutes(adminService, requireUser), { prefix: '/admin' });
  app.register(
    createLearningRoutes(
      learningService,
      requireUser,
    ),
    { prefix: '/learning' },
  );
  app.register(
    createMediaRoutes(
      options.mediaStorage ?? new LocalMediaStorage(process.env.STUDYHUB_UPLOAD_DIR),
      requireUser,
    ),
    { prefix: '/media' },
  );

  return app;
}

function readConfiguredCorsOrigins(): string[] {
  return (process.env.STUDYHUB_CORS_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}

function readErrorStatusCode(error: unknown): number | null {
  if (
    typeof error !== 'object' ||
    error === null ||
    !('statusCode' in error) ||
    typeof error.statusCode !== 'number'
  ) {
    return null;
  }
  return error.statusCode;
}
