import type {
  AuthSessionResult,
  AuthUser,
  LoginInput,
  RegisterInput,
} from '../types/auth.js';

export interface AuthService {
  register(input: RegisterInput): Promise<AuthSessionResult>;
  login(input: LoginInput): Promise<AuthSessionResult>;
  authenticate(accessToken: string): Promise<AuthUser | null>;
  logout(accessToken: string): Promise<void>;
  updateDisplayName(userId: string, displayName: string): Promise<AuthUser>;
}

export class AuthValidationError extends Error {
  constructor(
    message: string,
    public readonly field?: 'email' | 'password' | 'displayName',
  ) {
    super(message);
  }
}

export class AuthConflictError extends Error {}

export class InvalidCredentialsError extends Error {}

export class AuthenticationRequiredError extends Error {}

export class AccountDisabledError extends Error {}

export function validateRegistration(input: RegisterInput): RegisterInput {
  const email = normalizeEmail(input.email);
  const displayName = input.displayName.trim();
  if (!isValidEmail(email)) {
    throw new AuthValidationError('Enter a valid email address.', 'email');
  }
  if (input.password.length < 8 || input.password.length > 128) {
    throw new AuthValidationError(
      'Password must contain between 8 and 128 characters.',
      'password',
    );
  }
  if (displayName.length < 1 || displayName.length > 80) {
    throw new AuthValidationError(
      'Display name must contain between 1 and 80 characters.',
      'displayName',
    );
  }
  return { email, password: input.password, displayName };
}

export function validateLogin(input: LoginInput): LoginInput {
  const email = normalizeEmail(input.email);
  if (!isValidEmail(email) || input.password.length === 0) {
    throw new InvalidCredentialsError('Email or password is incorrect.');
  }
  return { email, password: input.password };
}

export function validateDisplayName(displayName: string): string {
  const normalized = displayName.trim();
  if (normalized.length < 1 || normalized.length > 80) {
    throw new AuthValidationError(
      'Display name must contain between 1 and 80 characters.',
      'displayName',
    );
  }
  return normalized;
}

function normalizeEmail(email: string): string {
  return email.trim().toLocaleLowerCase('en-US');
}

function isValidEmail(email: string): boolean {
  return (
    email.length <= 254 &&
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  );
}
