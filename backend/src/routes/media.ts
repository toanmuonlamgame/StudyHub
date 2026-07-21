import multipart from '@fastify/multipart';
import type { FastifyPluginAsync } from 'fastify';

import { sendAuthError, type RequireUser } from './auth.js';
import {
  MediaUploadError,
  mediaUploadMaxBytes,
  type MediaStorage,
} from '../services/mediaStorage.js';

export function createMediaRoutes(storage: MediaStorage, requireUser: RequireUser): FastifyPluginAsync {
  return async function mediaRoutes(app): Promise<void> {
    await app.register(multipart, {
      limits: { files: 1, fileSize: mediaUploadMaxBytes, fields: 1 },
    });

    app.post('/images', async (request, reply) => {
      try {
        await requireUser(request);
        const file = await request.file();
        if (file === undefined) return reply.code(400).send({ error: 'Image file is required.' });
        const chunks: Buffer[] = [];
        var size = 0;
        for await (const chunk of file.file) {
          const bytes = Buffer.from(chunk);
          size += bytes.length;
          if (size > mediaUploadMaxBytes) throw new MediaUploadError('Image must be 5 MiB or smaller.', 413);
          chunks.push(bytes);
        }
        if (file.file.truncated) throw new MediaUploadError('Image must be 5 MiB or smaller.', 413);
        const media = await storage.saveImage({ bytes: Buffer.concat(chunks), mimeType: file.mimetype });
        return reply.code(201).send({ media });
      } catch (error) {
        if (error instanceof MediaUploadError) return reply.code(error.statusCode).send({ error: error.message });
        return sendAuthError(error, reply);
      }
    });

    app.get<{ Params: { fileName: string } }>('/images/:fileName', async (request, reply) => {
      const file = await storage.readImage(request.params.fileName);
      if (file === null) return reply.code(404).send({ error: 'Image not found.' });
      return reply.header('Cache-Control', 'public, max-age=86400').type(file.mimeType).send(file.bytes);
    });
  };
}
