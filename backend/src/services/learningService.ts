import type {
  AnswerCheckResult,
  ListQuestionSetsParams,
  PaginatedQuestionSets,
  Question,
  QuestionSet,
  QuizResult,
  Subject,
  Topic,
} from '../types/learning.js';

export interface LearningService {
  getSubjects(): Promise<Subject[]>;
  getTopicsBySubjectId(subjectId: string): Promise<Topic[]>;
  getQuestionSetsBySubjectId(subjectId: string): Promise<QuestionSet[]>;
  listQuestionSets(
    params: ListQuestionSetsParams,
  ): Promise<PaginatedQuestionSets>;
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
}

export class LearningResourceNotFoundError extends Error {}

export class InvalidQuizSubmissionError extends Error {}

export class LearningDataIntegrityError extends Error {}

export class InvalidLearningListQueryError extends Error {}
