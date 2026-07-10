import Fastify, { type FastifyInstance } from 'fastify';

export function buildApp(): FastifyInstance {
  const app = Fastify({ logger: true });

  app.get('/health', async () => ({
    status: 'ok',
    service: 'studyhub-backend',
  }));

  return app;
}
