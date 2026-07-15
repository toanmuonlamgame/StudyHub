import cors from '@fastify/cors';
import Fastify, { type FastifyInstance } from 'fastify';

import { createLearningRoutes } from './routes/learning.js';
import { InMemoryLearningService } from './services/inMemoryLearningService.js';
import type { LearningService } from './services/learningService.js';
import { createPrismaLearningService } from './services/prismaLearningService.js';

export interface BuildAppOptions {
  learningService?: LearningService;
  learningDataSource?: string;
}

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

export function buildApp(options: BuildAppOptions = {}): FastifyInstance {
  const dataSource =
    options.learningDataSource ??
    process.env.STUDYHUB_LEARNING_DATA_SOURCE ??
    'memory';
  const learningService =
    options.learningService ?? createConfiguredLearningService(dataSource);
  const app = Fastify({
    logger: true,
    ajv: { customOptions: { removeAdditional: false } },
  });

  app.register(cors, {
    origin: (origin, callback) => {
      callback(
        null,
        origin === undefined || isAllowedDevelopmentOrigin(origin),
      );
    },
  });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'studyhub-backend',
  }));

  app.register(createLearningRoutes(learningService), { prefix: '/learning' });

  return app;
}
