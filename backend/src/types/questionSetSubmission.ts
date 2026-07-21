export type QuestionSetModerationStatus =
  | 'draft'
  | 'pendingReview'
  | 'published'
  | 'rejected';

export type QuestionSetSourceType = 'system' | 'community';

export interface AnswerOptionSubmissionInput {
  text: string;
  isCorrect: boolean;
}

export interface QuestionSubmissionInput {
  text: string;
  explanation?: string;
  answerOptions: AnswerOptionSubmissionInput[];
}

export interface QuestionSetSubmissionInput {
  subjectId: string;
  topicId?: string;
  title: string;
  description: string;
  questions: QuestionSubmissionInput[];
}

export interface QuestionSetSubmission extends QuestionSetSubmissionInput {
  id: string;
  status: QuestionSetModerationStatus;
  sourceType: QuestionSetSourceType;
  createdByUserId?: string;
  submittedAt?: string;
  reviewedAt?: string;
  publishedAt?: string;
  rejectionReason?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateQuestionSetSubmissionOutcome {
  submission: QuestionSetSubmission;
  created: boolean;
}

export interface SubmissionValidationFieldError {
  path: string;
  message: string;
}

export interface SubmissionValidationErrorBody {
  error: {
    code: 'SUBMISSION_VALIDATION_FAILED';
    message: string;
    fields: SubmissionValidationFieldError[];
  };
}
