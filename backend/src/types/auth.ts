export interface AuthUser {
  id: string;
  email: string;
  displayName: string;
  createdAt: string;
}

export interface RegisterInput {
  email: string;
  password: string;
  displayName: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface AuthSessionResult {
  user: AuthUser;
  accessToken: string;
  expiresAt: string;
}
