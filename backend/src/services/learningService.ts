import type {
  AnswerCheckResult,
  ListStudyMaterialsParams,
  ListQuestionSetsParams,
  PaginatedQuestionSets,
  PaginatedStudyMaterials,
  Question,
  QuestionSet,
  QuizResult,
  Subject,
  StudyMaterial,
  Topic,
} from '../types/learning.js';
import type {
  QuestionSetSubmission,
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
  createQuestionSetSubmission(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission>;
  createQuestionSetSubmissionForReview(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission>;
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

export class QuestionSetSubmissionValidationError extends Error {
  constructor(public readonly fields: SubmissionValidationFieldError[]) {
    super('Question set submission validation failed.');
  }
}

export class QuestionSetSubmissionStateError extends Error {}
