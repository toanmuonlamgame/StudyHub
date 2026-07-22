import type {
  AdminContributionDetail,
  AdminContributionListItem,
  AdminContributionListParams,
  AdminDashboardSummary,
  AdminMediaItem,
  AdminMediaListParams,
  AdminPage,
  AdminQuestionSetDetail,
  AdminQuestionSetListItem,
  AdminQuestionSetListParams,
  AdminSubject,
  AdminTopic,
  AdminUser,
  AdminUserListParams,
  UpdateAdminQuestionSetInput,
} from '../types/admin.js';

export class AdminValidationError extends Error {
  readonly statusCode = 400;
}

export class AdminNotFoundError extends Error {
  readonly statusCode = 404;
}

export class AdminConflictError extends Error {
  readonly statusCode = 409;
}

export class AdminForbiddenError extends Error {
  readonly statusCode = 403;
}

export interface AdminService {
  getDashboard(): Promise<AdminDashboardSummary>;
  listContributions(params: AdminContributionListParams): Promise<AdminPage<AdminContributionListItem>>;
  getContribution(id: string): Promise<AdminContributionDetail | null>;
  approveContribution(id: string, adminUserId: string): Promise<AdminContributionDetail>;
  rejectContribution(id: string, adminUserId: string, reason: string): Promise<AdminContributionDetail>;
  listQuestionSets(params: AdminQuestionSetListParams): Promise<AdminPage<AdminQuestionSetListItem>>;
  getQuestionSet(id: string): Promise<AdminQuestionSetDetail | null>;
  updateQuestionSet(id: string, input: UpdateAdminQuestionSetInput): Promise<AdminQuestionSetDetail>;
  listSubjects(): Promise<AdminSubject[]>;
  createSubject(input: { name: string; description?: string }): Promise<AdminSubject>;
  updateSubject(id: string, input: { name?: string; description?: string | null; isArchived?: boolean }): Promise<AdminSubject>;
  listTopics(subjectId?: string): Promise<AdminTopic[]>;
  createTopic(input: { subjectId: string; name: string }): Promise<AdminTopic>;
  updateTopic(id: string, input: { subjectId?: string; name?: string; isArchived?: boolean }): Promise<AdminTopic>;
  listUsers(params: AdminUserListParams): Promise<AdminPage<AdminUser>>;
  getUser(id: string): Promise<AdminUser | null>;
  updateUser(id: string, actorId: string, input: { role?: 'user' | 'admin'; status?: 'active' | 'disabled' }): Promise<AdminUser>;
  listMedia(params: AdminMediaListParams): Promise<AdminPage<AdminMediaItem>>;
}

export function normalizeAdminName(value: string, label: string): string {
  const normalized = value.trim();
  if (normalized.length < 1 || normalized.length > 120) {
    throw new AdminValidationError(`${label} must contain between 1 and 120 characters.`);
  }
  return normalized;
}

export function normalizeRejectionReason(value: string): string {
  const normalized = value.trim();
  if (normalized.length < 3 || normalized.length > 1000) {
    throw new AdminValidationError('Rejection reason must contain between 3 and 1000 characters.');
  }
  return normalized;
}

export function createAdminPage<T>(items: T[], page: number, limit: number, total: number): AdminPage<T> {
  return { items, page, limit, total, totalPages: Math.max(1, Math.ceil(total / limit)) };
}
