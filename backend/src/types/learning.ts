export interface Subject {
  id: string;
  name: string;
  school?: string;
  program?: string;
  major?: string;
  description?: string;
}

export interface Topic {
  id: string;
  subjectId: string;
  name: string;
}

export interface QuestionSet {
  id: string;
  subjectId: string;
  topicId?: string;
  title: string;
  description: string;
  questionCount: number;
}

export type QuestionSetDifficulty = 'easy' | 'medium' | 'hard';

export interface QuestionSetListItem extends QuestionSet {
  estimatedMinutes: number;
  difficulty: QuestionSetDifficulty;
  createdAt: string;
}

export interface ListQuestionSetsParams {
  subjectId?: string;
  topicId?: string;
  q?: string;
  limit: number;
  cursor?: string;
}

export interface PaginatedQuestionSets {
  items: QuestionSetListItem[];
  nextCursor: string | null;
  hasMore: boolean;
}

export type StudyMaterialType =
  | 'pdf'
  | 'slides'
  | 'notes'
  | 'document'
  | 'link'
  | 'other';

export type StudyMaterialSourceType = 'externalLink' | 'uploadedFile';

export type StudyMaterialStatus =
  | 'draft'
  | 'pendingReview'
  | 'published'
  | 'rejected';

export interface StudyMaterialListItem {
  id: string;
  subjectId: string;
  topicId?: string;
  title: string;
  description: string;
  materialType: StudyMaterialType;
  language?: string;
  createdAt: string;
}

export interface StudyMaterial extends StudyMaterialListItem {
  sourceType: StudyMaterialSourceType;
  sourceUrl?: string;
  fileName?: string;
  mimeType?: string;
  fileSizeBytes?: number;
  updatedAt: string;
}

export interface InternalStudyMaterial extends StudyMaterial {
  status: StudyMaterialStatus;
}

export interface ListStudyMaterialsParams {
  subjectId?: string;
  topicId?: string;
  q?: string;
  materialType?: StudyMaterialType;
  language?: string;
  limit: number;
  cursor?: string;
}

export interface PaginatedStudyMaterials {
  items: StudyMaterialListItem[];
  nextCursor: string | null;
  hasMore: boolean;
}

export interface AnswerOption {
  id: string;
  text: string;
}

export interface Question {
  id: string;
  questionSetId: string;
  text: string;
  answerOptions: AnswerOption[];
}

export interface AnswerReview {
  questionId: string;
  questionText: string;
  selectedAnswerOptionId: string;
  selectedAnswerText: string;
  correctAnswerOptionId: string;
  correctAnswerText: string;
  isCorrect: boolean;
}

export interface AnswerCheckResult {
  questionId: string;
  selectedAnswerOptionId: string;
  selectedAnswerText: string;
  correctAnswerOptionId: string;
  correctAnswerText: string;
  isCorrect: boolean;
}

export interface QuizResult {
  questionSetId: string;
  questionSetTitle: string;
  totalQuestions: number;
  correctAnswers: number;
  wrongAnswers: number;
  percentageScore: number;
  answerReviews: AnswerReview[];
}

export interface SubmitQuizBody {
  selectedAnswerOptionIdsByQuestionId: Record<string, string>;
}

export interface CheckAnswerBody {
  selectedAnswerOptionId: string;
}
