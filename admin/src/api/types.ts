export type ModerationStatus = 'draft' | 'pendingReview' | 'published' | 'rejected';
export type UserRole = 'user' | 'admin';
export type UserStatus = 'active' | 'disabled';

export interface AuthUser {
  id: string;
  email: string;
  displayName: string;
  role: UserRole;
  status: UserStatus;
  createdAt: string;
}

export interface AuthSession {
  user: AuthUser;
  accessToken: string;
  expiresAt: string;
}

export interface Page<T> {
  items: T[];
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface ContributionItem {
  id: string;
  title: string;
  status: ModerationStatus;
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

export interface MediaAsset {
  mediaType: 'image' | 'gif' | 'video';
  mediaUrl: string;
  thumbnailUrl?: string;
  altText?: string;
}

export interface ContributionDetail extends ContributionItem {
  description: string;
  sourceType: 'system' | 'community';
  contributor?: { id: string; displayName: string; email: string };
  questions: Array<{
    text: string;
    explanation?: string;
    media?: MediaAsset;
    explanationMedia?: MediaAsset;
    answerOptions: Array<{ text: string; isCorrect: boolean }>;
  }>;
}

export interface QuestionSetItem extends ContributionItem {
  sourceType: 'system' | 'community';
  isArchived: boolean;
  attemptCount: number;
}

export interface QuestionSetDetail extends ContributionDetail {
  isArchived: boolean;
  attemptCount: number;
}

export interface Subject {
  id: string;
  name: string;
  description?: string;
  isArchived: boolean;
  topicCount: number;
  questionSetCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface Topic {
  id: string;
  subjectId: string;
  subjectName: string;
  name: string;
  isArchived: boolean;
  questionSetCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdminUser {
  id: string;
  email: string;
  displayName: string;
  role: UserRole;
  status: UserStatus;
  attemptCount: number;
  contributionCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface MediaItem {
  id: string;
  media: MediaAsset;
  usage: 'question' | 'explanation';
  questionId: string;
  questionText: string;
  questionSetId: string;
  questionSetTitle: string;
  submissionStatus: ModerationStatus;
  brokenReference: boolean;
}

export interface DashboardSummary {
  totalUsers: number;
  totalQuestionSets: number;
  pendingContributions: number;
  approvedContributions: number;
  rejectedContributions: number;
  totalAttempts: number;
  recentContributions: ContributionItem[];
}
