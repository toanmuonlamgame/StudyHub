import type {
  StudyMaterialSourceType,
  StudyMaterialStatus,
  StudyMaterialType,
} from './learning.js';

export interface StudyMaterialSubmissionInput {
  subjectId: string;
  topicId?: string;
  title: string;
  description: string;
  materialType: StudyMaterialType;
  sourceType: StudyMaterialSourceType;
  sourceUrl?: string;
  language?: string;
}

export interface StudyMaterialSubmission extends StudyMaterialSubmissionInput {
  id: string;
  status: StudyMaterialStatus;
  createdByUserId: string;
  submittedAt?: string;
  reviewedAt?: string;
  rejectionReason?: string;
  createdAt: string;
  updatedAt: string;
}
