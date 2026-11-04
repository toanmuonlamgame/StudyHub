import type { Prisma, PrismaClient, User } from '@prisma/client';

import { getPrismaClient } from '../db/prisma.js';
import type { AuthSessionResult, AuthUser, LoginInput, RegisterInput } from '../types/auth.js';
import {
  AuthConflictError,
  AccountDisabledError,
  type AuthService,
  AuthenticationRequiredError,
  InvalidCredentialsError,
  validateDisplayName,
  validateAvatarUrl,
  validateLogin,
  validateRegistration,
  validateNewPassword,
} from './authService.js';
import {
  createAccessToken,
  hashAccessToken,
  hashPassword,
  verifyPassword,
  missingAccountHash,
} from './authCrypto.js';

const sessionDurationMs = 30 * 24 * 60 * 60 * 1000;

export class PrismaAuthService implements AuthService {
  constructor(private readonly prisma: PrismaClient) {}

  async register(input: RegisterInput): Promise<AuthSessionResult> {
    const normalized = validateRegistration(input);
    const existing = await this.prisma.user.findUnique({ where: { email: normalized.email } });
    if (existing !== null) {
      throw new AuthConflictError('An account with this email already exists.');
    }
    const passwordHash = await hashPassword(normalized.password);
    try {
      return await this.prisma.$transaction(async (transaction) => {
        const user = await transaction.user.create({
          data: {
            email: normalized.email,
            displayName: normalized.displayName,
            passwordHash,
          },
        });
        return this.createSession(user, transaction);
      });
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        throw new AuthConflictError('An account with this email already exists.');
      }
      throw error;
    }
  }

  async login(input: LoginInput): Promise<AuthSessionResult> {
    const normalized = validateLogin(input);
    const user = await this.prisma.user.findUnique({ where: { email: normalized.email } });
    const valid = await verifyPassword(normalized.password, user?.passwordHash ?? missingAccountHash);
    if (user === null || !valid) {
      throw new InvalidCredentialsError('Email or password is incorrect.');
    }
    if (user.status === 'disabled') {
      throw new AccountDisabledError('This account is disabled.');
    }
    return this.prisma.$transaction(async (tx) => {
      // Serialize issuing a session against password changes on this user.
      const stillCurrent = await tx.user.updateMany({
        where: { id: user.id, passwordHash: user.passwordHash, status: 'active' },
        data: { passwordHash: user.passwordHash },
      });
      if (stillCurrent.count !== 1) {
        throw new InvalidCredentialsError('Email or password is incorrect.');
      }
      return this.createSession(user, tx);
    });
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
    validateNewPassword(currentPassword, newPassword);
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || !(await verifyPassword(currentPassword, user.passwordHash))) {
      throw new InvalidCredentialsError('Current password is incorrect.');
    }
    const passwordHash = await hashPassword(newPassword);
    await this.prisma.$transaction(async (tx) => {
      const changed = await tx.user.updateMany({
        where: { id: userId, passwordHash: user.passwordHash, status: 'active' },
        data: { passwordHash },
      });
      if (changed.count !== 1) throw new InvalidCredentialsError('Current password is incorrect.');
      await tx.authSession.deleteMany({ where: { userId } });
    });
  }

  async authenticate(accessToken: string): Promise<AuthUser | null> {
    const tokenHash = hashAccessToken(accessToken);
    const session = await this.prisma.authSession.findUnique({
      where: { tokenHash },
      include: { user: true },
    });
    if (session === null) return null;
    if (session.expiresAt.getTime() <= Date.now()) {
      await this.prisma.authSession.deleteMany({ where: { id: session.id } });
      return null;
    }
    return session.user.status === 'disabled' ? null : toAuthUser(session.user);
  }

  async logout(accessToken: string): Promise<void> {
    await this.prisma.authSession.deleteMany({
      where: { tokenHash: hashAccessToken(accessToken) },
    });
  }

  async updateDisplayName(userId: string, displayName: string): Promise<AuthUser> {
    const normalized = validateDisplayName(displayName);
    const result = await this.prisma.user.updateMany({
      where: { id: userId },
      data: { displayName: normalized },
    });
    if (result.count !== 1) {
      throw new AuthenticationRequiredError('Authentication required.');
    }
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    return toAuthUser(user);
  }

  async updateAvatar(userId: string, avatarUrl: string | null): Promise<AuthUser> {
    const result = await this.prisma.user.updateMany({
      where: { id: userId },
      data: { avatarUrl: validateAvatarUrl(avatarUrl) },
    });
    if (result.count !== 1) {
      throw new AuthenticationRequiredError('Authentication required.');
    }
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    return toAuthUser(user);
  }

  private async createSession(
    user: User,
    client: PrismaClient | Prisma.TransactionClient = this.prisma,
  ): Promise<AuthSessionResult> {
    const accessToken = createAccessToken();
    const expiresAt = new Date(Date.now() + sessionDurationMs);
    await client.authSession.create({
      data: { userId: user.id, tokenHash: hashAccessToken(accessToken), expiresAt },
    });
    return { user: toAuthUser(user), accessToken, expiresAt: expiresAt.toISOString() };
  }
}

export function createPrismaAuthService(): PrismaAuthService {
  return new PrismaAuthService(getPrismaClient());
}

function toAuthUser(user: User): AuthUser {
  return {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    avatarUrl: user.avatarUrl,
    role: user.role,
    status: user.status,
    createdAt: user.createdAt.toISOString(),
  };
}

function isUniqueConstraintError(error: unknown): boolean {
  return typeof error === 'object' && error !== null && 'code' in error && error.code === 'P2002';
}
