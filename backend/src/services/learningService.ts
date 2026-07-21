import type {
  AnswerCheckResult,
  ExamAttemptDetail,
  ExamAttemptSummary,
  ListStudyMaterialsParams,
  ListQuestionSetsParams,
  PaginatedQuestionSets,
  PaginatedStudyMaterials,
  Question,
  QuestionSet,
  QuizResult,
  SaveExamAttemptInput,
  SaveExamAttemptOutcome,
  Subject,
  StudyMaterial,
  Topic,
} from '../types/learning.js';
import type {
  QuestionSetSubmission,
  CreateQuestionSetSubmissionOutcome,
  QuestionSetSubmissionInput,
  SubmissionValidationFieldError,
} from '../types/questionSetSubmission.js';

export interface LearningService {
  getSubjects(): Promise<Subject[]>;
  getTopicsBySubjectId(subjectId: string): Promise<Topic[]>;
  getQuestionSetsBySubjectId(subjectId: string): Promise<QuestionSet[]>;
  listQuestionSets(
    params: ListQuestionSetsParams,
  ): Promise<PaginatedQuestionSets>;
  listStudyMaterials(
    params: ListStudyMaterialsParams,
  ): Promise<PaginatedStudyMaterials>;
  getStudyMaterialById(materialId: string): Promise<StudyMaterial | null>;
  getQuestionSetById(questionSetId: string): Promise<QuestionSet | null>;
  getQuestionsByQuestionSetId(questionSetId: string): Promise<Question[]>;
  checkAnswer(
    questionId: string,
    selectedAnswerOptionId: string,
  ): Promise<AnswerCheckResult>;
  submitQuiz(
    questionSetId: string,
    selectedAnswerOptionIdsByQuestionId: Record<string, string>,
  ): Promise<QuizResult>;
  saveExamAttempt(
    userId: string,
    questionSetId: string,
    input: SaveExamAttemptInput,
  ): Promise<SaveExamAttemptOutcome>;
  listExamAttempts(userId: string): Promise<ExamAttemptSummary[]>;
  getExamAttempt(
    userId: string,
    attemptId: string,
  ): Promise<ExamAttemptDetail | null>;
  createQuestionSetSubmission(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission>;
  createQuestionSetSubmissionForReview(
    userId: string,
    submissionId: string,
    input: QuestionSetSubmissionInput,
  ): Promise<CreateQuestionSetSubmissionOutcome>;
  updateQuestionSetSubmission(
    submissionId: string,
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission>;
  getQuestionSetSubmission(
    submissionId: string,
  ): Promise<QuestionSetSubmission | null>;
  submitQuestionSetForReview(
    submissionId: string,
  ): Promise<QuestionSetSubmission>;
}

export class LearningResourceNotFoundError extends Error {}

export class InvalidQuizSubmissionError extends Error {}

export class LearningDataIntegrityError extends Error {}

export class InvalidLearningListQueryError extends Error {}

export class ExamAttemptIdempotencyConflictError extends Error {}

export class QuestionSetSubmissionIdempotencyConflictError extends Error {}

export class QuestionSetSubmissionValidationError extends Error {
  constructor(public readonly fields: SubmissionValidationFieldError[]) {
    super('Question set submission validation failed.');
  }
}

export class QuestionSetSubmissionStateError extends Error {}
