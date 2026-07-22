import type { AuthSessionResult, AuthUser, LoginInput, RegisterInput } from '../types/auth.js';
import {
  AuthConflictError,
  AccountDisabledError,
  type AuthService,
  AuthenticationRequiredError,
  InvalidCredentialsError,
  validateDisplayName,
  validateLogin,
  validateRegistration,
} from './authService.js';
import {
  createAccessToken,
  hashAccessToken,
  hashPassword,
  verifyPassword,
} from './authCrypto.js';

const sessionDurationMs = 30 * 24 * 60 * 60 * 1000;

interface StoredUser extends AuthUser {
  passwordHash: string;
}

export class InMemoryAuthService implements AuthService {
  private readonly usersById = new Map<string, StoredUser>();
  private readonly userIdByEmail = new Map<string, string>();
  private readonly sessions = new Map<string, { userId: string; expiresAt: Date }>();
  private nextUserNumber = 1;

  async register(input: RegisterInput): Promise<AuthSessionResult> {
    const normalized = validateRegistration(input);
    if (this.userIdByEmail.has(normalized.email)) {
      throw new AuthConflictError('An account with this email already exists.');
    }
    const user: StoredUser = {
      id: `user_${this.nextUserNumber++}`,
      email: normalized.email,
      displayName: normalized.displayName,
      passwordHash: await hashPassword(normalized.password),
      role: 'user',
      status: 'active',
      createdAt: new Date().toISOString(),
    };
    this.usersById.set(user.id, user);
    this.userIdByEmail.set(user.email, user.id);
    return this.createSession(user);
  }

  async login(input: LoginInput): Promise<AuthSessionResult> {
    const normalized = validateLogin(input);
    const userId = this.userIdByEmail.get(normalized.email);
    const user = userId === undefined ? undefined : this.usersById.get(userId);
    if (user === undefined || !(await verifyPassword(normalized.password, user.passwordHash))) {
      throw new InvalidCredentialsError('Email or password is incorrect.');
    }
    if (user.status === 'disabled') {
      throw new AccountDisabledError('This account is disabled.');
    }
    return this.createSession(user);
  }

  async authenticate(accessToken: string): Promise<AuthUser | null> {
    const tokenHash = hashAccessToken(accessToken);
    const session = this.sessions.get(tokenHash);
    if (session === undefined) return null;
    if (session.expiresAt.getTime() <= Date.now()) {
      this.sessions.delete(tokenHash);
      return null;
    }
    const user = this.usersById.get(session.userId);
    return user === undefined || user.status === 'disabled' ? null : toAuthUser(user);
  }

  async logout(accessToken: string): Promise<void> {
    this.sessions.delete(hashAccessToken(accessToken));
  }

  async updateDisplayName(userId: string, displayName: string): Promise<AuthUser> {
    const user = this.usersById.get(userId);
    if (user === undefined) throw new AuthenticationRequiredError('Authentication required.');
    const updated = { ...user, displayName: validateDisplayName(displayName) };
    this.usersById.set(userId, updated);
    return toAuthUser(updated);
  }

  private createSession(user: StoredUser): AuthSessionResult {
    const accessToken = createAccessToken();
    const expiresAt = new Date(Date.now() + sessionDurationMs);
    this.sessions.set(hashAccessToken(accessToken), { userId: user.id, expiresAt });
    return { user: toAuthUser(user), accessToken, expiresAt: expiresAt.toISOString() };
  }
}

function toAuthUser(user: StoredUser): AuthUser {
  return {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    role: user.role,
    status: user.status,
    createdAt: user.createdAt,
  };
}
