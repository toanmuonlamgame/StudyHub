import type {
  AdminUser,
  AuthSession,
  ContributionDetail,
  ContributionItem,
  DashboardSummary,
  MediaItem,
  Page,
  QuestionSetDetail,
  QuestionSetItem,
  Subject,
  Topic,
} from './types';

const baseUrl = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.replace(/\/$/, '') || 'http://localhost:3000';
const sessionKey = 'studyhub_admin_session';

export class ApiError extends Error {
  constructor(message: string, readonly status: number) { super(message); }
}

export function readStoredSession(): AuthSession | null {
  try {
    const value = localStorage.getItem(sessionKey);
    if (!value) return null;
    const session = JSON.parse(value) as AuthSession;
    if (!session.accessToken || new Date(session.expiresAt).getTime() <= Date.now()) {
      clearStoredSession();
      return null;
    }
    return session;
  } catch {
    clearStoredSession();
    return null;
  }
}

export function storeSession(session: AuthSession): void {
  localStorage.setItem(sessionKey, JSON.stringify(session));
}

export function clearStoredSession(): void { localStorage.removeItem(sessionKey); }

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const session = readStoredSession();
  const response = await fetch(`${baseUrl}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(session ? { Authorization: `Bearer ${session.accessToken}` } : {}),
      ...init.headers,
    },
  });
  if (response.status === 401) {
    clearStoredSession();
    window.dispatchEvent(new Event('studyhub:unauthorized'));
  }
  if (!response.ok) {
    let message = `Request failed (${response.status}).`;
    try {
      const body = await response.json() as { error?: string | { message?: string } };
      message = typeof body.error === 'string' ? body.error : body.error?.message || message;
    } catch { /* keep stable fallback */ }
    throw new ApiError(message, response.status);
  }
  return response.status === 204 ? undefined as T : response.json() as Promise<T>;
}

function query(params: Record<string, string | number | boolean | undefined>): string {
  const value = new URLSearchParams();
  for (const [key, item] of Object.entries(params)) if (item !== undefined && item !== '') value.set(key, String(item));
  const encoded = value.toString();
  return encoded ? `?${encoded}` : '';
}

export const api = {
  login: (email: string, password: string) => request<AuthSession>('/auth/login', {
    method: 'POST', body: JSON.stringify({ email, password }),
  }),
  me: () => request<{ user: AuthSession['user'] }>('/auth/me'),
  logout: () => request<void>('/auth/logout', { method: 'POST' }),
  dashboard: () => request<{ summary: DashboardSummary }>('/admin/dashboard'),
  contributions: (params: Record<string, string | number | undefined>) =>
    request<{ page: Page<ContributionItem> }>(`/admin/contributions${query(params)}`),
  contribution: (id: string) => request<{ contribution: ContributionDetail }>(`/admin/contributions/${id}`),
  approveContribution: (id: string) => request<{ contribution: ContributionDetail }>(`/admin/contributions/${id}/approve`, { method: 'POST' }),
  rejectContribution: (id: string, reason: string) => request<{ contribution: ContributionDetail }>(`/admin/contributions/${id}/reject`, { method: 'POST', body: JSON.stringify({ reason }) }),
  questionSets: (params: Record<string, string | number | boolean | undefined>) =>
    request<{ page: Page<QuestionSetItem> }>(`/admin/question-sets${query(params)}`),
  questionSet: (id: string) => request<{ questionSet: QuestionSetDetail }>(`/admin/question-sets/${id}`),
  updateQuestionSet: (id: string, input: Record<string, unknown>) => request<{ questionSet: QuestionSetDetail }>(`/admin/question-sets/${id}`, { method: 'PATCH', body: JSON.stringify(input) }),
  subjects: () => request<{ subjects: Subject[] }>('/admin/subjects'),
  createSubject: (input: { name: string; description?: string }) => request<{ subject: Subject }>('/admin/subjects', { method: 'POST', body: JSON.stringify(input) }),
  updateSubject: (id: string, input: Record<string, unknown>) => request<{ subject: Subject }>(`/admin/subjects/${id}`, { method: 'PATCH', body: JSON.stringify(input) }),
  topics: (subjectId?: string) => request<{ topics: Topic[] }>(`/admin/topics${query({ subjectId })}`),
  createTopic: (input: { subjectId: string; name: string }) => request<{ topic: Topic }>('/admin/topics', { method: 'POST', body: JSON.stringify(input) }),
  updateTopic: (id: string, input: Record<string, unknown>) => request<{ topic: Topic }>(`/admin/topics/${id}`, { method: 'PATCH', body: JSON.stringify(input) }),
  users: (params: Record<string, string | number | undefined>) => request<{ page: Page<AdminUser> }>(`/admin/users${query(params)}`),
  user: (id: string) => request<{ user: AdminUser }>(`/admin/users/${id}`),
  updateUser: (id: string, input: Record<string, unknown>) => request<{ user: AdminUser }>(`/admin/users/${id}`, { method: 'PATCH', body: JSON.stringify(input) }),
  media: (params: Record<string, string | number | boolean | undefined>) => request<{ page: Page<MediaItem> }>(`/admin/media${query(params)}`),
  mediaUrl: (path: string) => path.startsWith('http') ? path : `${baseUrl}${path}`,
};
