import type { MediaAsset } from './learning.js';
import type {
  QuestionSetModerationStatus,
  QuestionSetSubmission,
} from './questionSetSubmission.js';

export interface AdminPage<T> {
  items: T[];
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface AdminListParams {
  page: number;
  limit: number;
  q?: string;
}

export interface AdminDashboardSummary {
  totalUsers: number;
  totalQuestionSets: number;
  pendingContributions: number;
  approvedContributions: number;
  rejectedContributions: number;
  totalAttempts: number;
  recentContributions: AdminContributionListItem[];
}

export interface AdminContributionListParams extends AdminListParams {
  status?: QuestionSetModerationStatus;
  subjectId?: string;
  topicId?: string;
}

export interface AdminContributionListItem {
  id: string;
  title: string;
  status: QuestionSetModerationStatus;
  subjectId: string;
  subjectName: string;
  topicId?: string;
  topicName?: string;
  contributorId?: string;
  contributorName?: string;
  questionCount: number;
  submittedAt?: string;
  reviewedAt?: string;
  rejectionReason?: string;
  updatedAt: string;
}

export interface AdminContributionDetail extends QuestionSetSubmission {
  subjectName: string;
  topicName?: string;
  contributor?: {
    id: string;
    displayName: string;
    email: string;
  };
  reviewedByUserId?: string;
}

export interface AdminQuestionSetListParams extends AdminListParams {
  subjectId?: string;
  topicId?: string;
  status?: QuestionSetModerationStatus;
  archived?: boolean;
}

export interface AdminQuestionSetListItem extends AdminContributionListItem {
  sourceType: 'system' | 'community';
  isArchived: boolean;
  attemptCount: number;
}

export interface AdminQuestionSetDetail extends AdminContributionDetail {
  sourceType: 'system' | 'community';
  isArchived: boolean;
  attemptCount: number;
}

export interface UpdateAdminQuestionSetInput {
  title?: string;
  description?: string;
  subjectId?: string;
  topicId?: string | null;
  isArchived?: boolean;
}

export interface AdminSubject {
  id: string;
  name: string;
  description?: string;
  isArchived: boolean;
  topicCount: number;
  questionSetCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminTopic {
  id: string;
  subjectId: string;
  subjectName: string;
  name: string;
  isArchived: boolean;
  questionSetCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminUserListParams extends AdminListParams {
  role?: 'user' | 'admin';
  status?: 'active' | 'disabled';
}

export interface AdminUser {
  id: string;
  email: string;
  displayName: string;
  role: 'user' | 'admin';
  status: 'active' | 'disabled';
  attemptCount: number;
  contributionCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminMediaItem {
  id: string;
  media: MediaAsset;
  usage: 'question' | 'explanation';
  questionId: string;
  questionText: string;
  questionSetId: string;
  questionSetTitle: string;
  submissionStatus: QuestionSetModerationStatus;
  brokenReference: boolean;
}

export interface AdminMediaListParams extends AdminListParams {
  broken?: boolean;
}
