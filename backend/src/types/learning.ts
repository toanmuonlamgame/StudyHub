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
