import Fastify, { type FastifyInstance } from 'fastify';

import { learningRoutes } from './routes/learning.js';

export function buildApp(): FastifyInstance {
  const app = Fastify({ logger: true });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'studyhub-backend',
  }));

  app.register(learningRoutes, { prefix: '/learning' });

  return app;
}
