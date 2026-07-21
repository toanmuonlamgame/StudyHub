import cors from '@fastify/cors';
import Fastify, { type FastifyInstance } from 'fastify';

import { createAuthRoutes, createRequireUser, type RequireUser } from './routes/auth.js';
import { createLearningRoutes } from './routes/learning.js';
import type { AuthService } from './services/authService.js';
import { InMemoryAuthService } from './services/inMemoryAuthService.js';
import { InMemoryLearningService } from './services/inMemoryLearningService.js';
import type { LearningService } from './services/learningService.js';
import { createPrismaAuthService } from './services/prismaAuthService.js';
import { createPrismaLearningService } from './services/prismaLearningService.js';

export interface BuildAppOptions {
  learningService?: LearningService;
  authService?: AuthService;
  learningDataSource?: string;
  isProduction?: boolean;
  corsOrigins?: string[];
  requireUser?: RequireUser;
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
  app.register(
    createLearningRoutes(
      learningService,
      options.requireUser ?? createRequireUser(authService),
    ),
    { prefix: '/learning' },
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
