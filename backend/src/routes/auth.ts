import type { FastifyPluginAsync, FastifyReply, FastifyRequest } from 'fastify';

import {
  AuthConflictError,
  AccountDisabledError,
  type AuthService,
  AuthValidationError,
  AuthenticationRequiredError,
  InvalidCredentialsError,
} from '../services/authService.js';
import type { AuthUser, LoginInput, RegisterInput } from '../types/auth.js';

interface UpdateProfileBody {
  displayName: string;
}

interface UpdateAvatarBody {
  avatarUrl: string;
}

const registerBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['email', 'password', 'displayName'],
  properties: {
    email: { type: 'string', minLength: 1, maxLength: 254 },
    password: { type: 'string', minLength: 1, maxLength: 128 },
    displayName: { type: 'string', minLength: 1, maxLength: 80 },
  },
} as const;

const loginBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['email', 'password'],
  properties: {
    email: { type: 'string', minLength: 1, maxLength: 254 },
    password: { type: 'string', minLength: 1, maxLength: 128 },
  },
} as const;

const updateProfileBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['displayName'],
  properties: { displayName: { type: 'string', minLength: 1, maxLength: 80 } },
} as const;

const updateAvatarBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['avatarUrl'],
  properties: { avatarUrl: { type: 'string', minLength: 1, maxLength: 2048 } },
} as const;

export type RequireUser = (request: FastifyRequest) => Promise<AuthUser>;

export function createAuthRoutes(authService: AuthService): FastifyPluginAsync {
  return async function authRoutes(app): Promise<void> {
    // Bound memory and reject excess work before password hashing.
    const windows = new Map<string, { count: number; until: number }>();
    let nextCleanup = 0;
    const limit = (action: string, maximum: number) =>
      async (request: FastifyRequest, reply: FastifyReply) => {
        const now = Date.now();
        if (now >= nextCleanup) {
          for (const [key, window] of windows) {
            if (window.until <= now) windows.delete(key);
          }
          nextCleanup = now + 60_000;
        }
        const key = `${action}:${request.ip}`;
        let window = windows.get(key);
        if (!window || window.until <= now) {
          if (!window && windows.size >= 10_000) {
            return rejectAuthRate(reply, 60);
          }
          window = { count: 0, until: now + 60_000 };
          windows.set(key, window);
        }
        if (window.count >= maximum) {
          return rejectAuthRate(reply, Math.ceil((window.until - now) / 1000));
        }
        window.count++;
      };

    app.post<{ Body: RegisterInput }>(
      '/register',
      { onRequest: limit('register', 5), schema: { body: registerBodySchema } },
      async (request, reply) => {
        try {
          return reply.code(201).send(await authService.register(request.body));
        } catch (error) {
          return sendAuthError(error, reply);
        }
      },
    );

    app.post<{ Body: LoginInput }>(
      '/login',
      { onRequest: limit('login', 10), schema: { body: loginBodySchema } },
      async (request, reply) => {
        try {
          return await authService.login(request.body);
        } catch (error) {
          return sendAuthError(error, reply);
        }
      },
    );

    app.get('/me', async (request, reply) => {
      try {
        const token = requireBearerToken(request);
        const user = await authService.authenticate(token);
        if (user === null) throw new AuthenticationRequiredError('Authentication required.');
        return { user };
      } catch (error) {
        return sendAuthError(error, reply);
      }
    });

    app.patch<{ Body: UpdateProfileBody }>(
      '/me',
      { schema: { body: updateProfileBodySchema } },
      async (request, reply) => {
        try {
          const token = requireBearerToken(request);
          const user = await authService.authenticate(token);
          if (user === null) throw new AuthenticationRequiredError('Authentication required.');
          return {
            user: await authService.updateDisplayName(user.id, request.body.displayName),
          };
        } catch (error) {
          return sendAuthError(error, reply);
        }
      },
    );

    app.put<{ Body: UpdateAvatarBody }>(
      '/me/avatar',
      { schema: { body: updateAvatarBodySchema } },
      async (request, reply) => {
        try {
          const token = requireBearerToken(request);
          const user = await authService.authenticate(token);
          if (user === null) throw new AuthenticationRequiredError('Authentication required.');
          return {
            user: await authService.updateAvatar(user.id, request.body.avatarUrl),
          };
        } catch (error) {
          return sendAuthError(error, reply);
        }
      },
    );

    app.delete('/me/avatar', async (request, reply) => {
      try {
        const token = requireBearerToken(request);
        const user = await authService.authenticate(token);
        if (user === null) throw new AuthenticationRequiredError('Authentication required.');
        return { user: await authService.updateAvatar(user.id, null) };
      } catch (error) {
        return sendAuthError(error, reply);
      }
    });

    app.put<{ Body: { currentPassword: string; newPassword: string } }>(
      '/me/password',
      {
        onRequest: limit('password', 5),
        schema: { body: {
          type: 'object',
          additionalProperties: false,
          required: ['currentPassword', 'newPassword'],
          properties: {
            currentPassword: { type: 'string', minLength: 1, maxLength: 128 },
            newPassword: { type: 'string', minLength: 8, maxLength: 128 },
          },
        } },
      },
      async (request, reply) => {
        try {
          const user = await createRequireUser(authService)(request);
          await authService.changePassword(user.id, request.body.currentPassword, request.body.newPassword);
          return reply.code(204).send();
        } catch (error) {
          return sendAuthError(error, reply);
        }
      },
    );

    app.post('/logout', async (request, reply) => {
      try {
        const token = requireBearerToken(request);
        await authService.logout(token);
        return reply.code(204).send();
      } catch (error) {
        return sendAuthError(error, reply);
      }
    });
  };
}

function rejectAuthRate(reply: FastifyReply, retryAfter: number): FastifyReply {
  return reply.header('Retry-After', retryAfter).code(429).send({
    error: { code: 'AUTH_RATE_LIMITED', message: 'Try again later.' },
  });
}

export function createRequireUser(authService: AuthService): RequireUser {
  return async (request) => {
    const token = requireBearerToken(request);
    const user = await authService.authenticate(token);
    if (user === null) throw new AuthenticationRequiredError('Authentication required.');
    return user;
  };
}

export function sendAuthError(error: unknown, reply: FastifyReply): FastifyReply {
  if (error instanceof AuthValidationError) {
    return reply.code(400).send({
      error: { code: 'AUTH_VALIDATION_FAILED', message: error.message, field: error.field },
    });
  }
  if (error instanceof AuthConflictError) {
    return reply.code(409).send({ error: { code: 'ACCOUNT_EXISTS', message: error.message } });
  }
  if (error instanceof InvalidCredentialsError) {
    return reply.code(401).send({ error: { code: 'INVALID_CREDENTIALS', message: error.message } });
  }
  if (error instanceof AuthenticationRequiredError) {
    return reply.code(401).send({ error: { code: 'AUTHENTICATION_REQUIRED', message: error.message } });
  }
  if (error instanceof AccountDisabledError) {
    return reply.code(403).send({
      error: { code: 'ACCOUNT_DISABLED', message: error.message },
    });
  }
  throw error;
}

function requireBearerToken(request: FastifyRequest): string {
  const authorization = request.headers.authorization;
  if (authorization === undefined || !authorization.startsWith('Bearer ')) {
    throw new AuthenticationRequiredError('Authentication required.');
  }
  const token = authorization.slice('Bearer '.length).trim();
  if (token.length === 0) throw new AuthenticationRequiredError('Authentication required.');
  return token;
}
