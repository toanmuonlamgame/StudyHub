import type { FastifyPluginAsync, FastifyReply, FastifyRequest } from 'fastify';

import {
  AuthConflictError,
  type AuthService,
  AuthValidationError,
  AuthenticationRequiredError,
  InvalidCredentialsError,
} from '../services/authService.js';
import type { LoginInput, RegisterInput } from '../types/auth.js';

interface UpdateProfileBody {
  displayName: string;
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

export type RequireUser = (request: FastifyRequest) => Promise<{ id: string }>;

export function createAuthRoutes(authService: AuthService): FastifyPluginAsync {
  return async function authRoutes(app): Promise<void> {
    app.post<{ Body: RegisterInput }>(
      '/register',
      { schema: { body: registerBodySchema } },
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
      { schema: { body: loginBodySchema } },
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
