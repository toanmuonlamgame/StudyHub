import {
  getCorrectAnswerOptionId,
  questions,
  questionSets,
  subjects,
  topics,
} from '../data/mockLearningData.js';
import type {
  AnswerReview,
  Question,
  QuestionSet,
  QuizResult,
  Subject,
  Topic,
} from '../types/learning.js';
import {
  InvalidQuizSubmissionError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  type LearningService,
} from './learningService.js';

export class InMemoryLearningService implements LearningService {
  async getSubjects(): Promise<Subject[]> {
    return subjects;
  }

  async getTopicsBySubjectId(subjectId: string): Promise<Topic[]> {
    this.requireSubject(subjectId);
    return topics.filter((topic) => topic.subjectId === subjectId);
  }

  async getQuestionSetsBySubjectId(subjectId: string): Promise<QuestionSet[]> {
    this.requireSubject(subjectId);
    return questionSets.filter(
      (questionSet) => questionSet.subjectId === subjectId,
    );
  }

  async getQuestionSetById(questionSetId: string): Promise<QuestionSet | null> {
    return questionSets.find(({ id }) => id === questionSetId) ?? null;
  }

  async getQuestionsByQuestionSetId(
    questionSetId: string,
  ): Promise<Question[]> {
    this.requireQuestionSet(questionSetId);
    return questions.filter(
      (question) => question.questionSetId === questionSetId,
    );
  }

  async submitQuiz(
    questionSetId: string,
    selectedAnswerOptionIdsByQuestionId: Record<string, string>,
  ): Promise<QuizResult> {
    const questionSet = this.requireQuestionSet(questionSetId);
    const questionSetQuestions = questions.filter(
      (question) => question.questionSetId === questionSet.id,
    );
    const questionIds = new Set(questionSetQuestions.map(({ id }) => id));

    for (const questionId of Object.keys(
      selectedAnswerOptionIdsByQuestionId,
    )) {
      if (!questionIds.has(questionId)) {
        throw new InvalidQuizSubmissionError(
          `Question ${questionId} does not belong to this question set.`,
        );
      }
    }

    const answerReviews: AnswerReview[] = questionSetQuestions.map(
      (question) => {
        const selectedAnswerOptionId =
          selectedAnswerOptionIdsByQuestionId[question.id];
        const selectedAnswer = question.answerOptions.find(
          ({ id }) => id === selectedAnswerOptionId,
        );
        if (selectedAnswer === undefined) {
          throw new InvalidQuizSubmissionError(
            `A valid answer is required for question ${question.id}.`,
          );
        }

        const correctAnswerOptionId = getCorrectAnswerOptionId(question.id);
        if (correctAnswerOptionId === undefined) {
          throw new LearningDataIntegrityError(
            `Answer key is missing for question ${question.id}.`,
          );
        }

        const correctAnswer = question.answerOptions.find(
          ({ id }) => id === correctAnswerOptionId,
        );
        if (correctAnswer === undefined) {
          throw new LearningDataIntegrityError(
            `Answer key is invalid for question ${question.id}.`,
          );
        }

        return {
          questionId: question.id,
          questionText: question.text,
          selectedAnswerOptionId: selectedAnswer.id,
          selectedAnswerText: selectedAnswer.text,
          correctAnswerOptionId: correctAnswer.id,
          correctAnswerText: correctAnswer.text,
          isCorrect: selectedAnswer.id === correctAnswer.id,
        };
      },
    );

    const correctAnswers = answerReviews.filter(
      ({ isCorrect }) => isCorrect,
    ).length;
    const totalQuestions = questionSetQuestions.length;

    return {
      questionSetId: questionSet.id,
      questionSetTitle: questionSet.title,
      totalQuestions,
      correctAnswers,
      wrongAnswers: totalQuestions - correctAnswers,
      percentageScore:
        totalQuestions === 0 ? 0 : (correctAnswers / totalQuestions) * 100,
      answerReviews,
    };
  }

  private requireSubject(subjectId: string): Subject {
    const subject = subjects.find(({ id }) => id === subjectId);
    if (subject === undefined) {
      throw new LearningResourceNotFoundError('Subject not found.');
    }
    return subject;
  }

  private requireQuestionSet(questionSetId: string): QuestionSet {
    const questionSet = questionSets.find(({ id }) => id === questionSetId);
    if (questionSet === undefined) {
      throw new LearningResourceNotFoundError('Question set not found.');
    }
    return questionSet;
  }
}
