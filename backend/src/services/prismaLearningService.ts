import type { PrismaClient } from '@prisma/client';

import { getPrismaClient } from '../db/prisma.js';
import type {
  AnswerReview,
  Question,
  QuestionSet,
  QuizResult,
  Subject,
  Topic,
} from '../types/learning.js';
import {
  mapQuestion,
  mapQuestionSet,
  mapSubject,
  mapTopic,
} from './learningMappers.js';
import {
  InvalidQuizSubmissionError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  type LearningService,
} from './learningService.js';

export class PrismaLearningService implements LearningService {
  constructor(private readonly prisma: PrismaClient) {}

  async getSubjects(): Promise<Subject[]> {
    const subjects = await this.prisma.subject.findMany({
      orderBy: { name: 'asc' },
    });

    return subjects.map(mapSubject);
  }

  async getTopicsBySubjectId(subjectId: string): Promise<Topic[]> {
    await this.requireSubject(subjectId);

    const topics = await this.prisma.topic.findMany({
      where: { subjectId },
      orderBy: { name: 'asc' },
    });

    return topics.map(mapTopic);
  }

  async getQuestionSetsBySubjectId(subjectId: string): Promise<QuestionSet[]> {
    await this.requireSubject(subjectId);

    const questionSets = await this.prisma.questionSet.findMany({
      where: { subjectId },
      include: { _count: { select: { questions: true } } },
      orderBy: { title: 'asc' },
    });

    return questionSets.map(mapQuestionSet);
  }

  async getQuestionSetById(questionSetId: string): Promise<QuestionSet | null> {
    const questionSet = await this.prisma.questionSet.findUnique({
      where: { id: questionSetId },
      include: { _count: { select: { questions: true } } },
    });

    return questionSet === null ? null : mapQuestionSet(questionSet);
  }

  async getQuestionsByQuestionSetId(
    questionSetId: string,
  ): Promise<Question[]> {
    await this.requireQuestionSet(questionSetId);

    const questions = await this.prisma.question.findMany({
      where: { questionSetId },
      include: { answerOptions: { orderBy: { position: 'asc' } } },
      orderBy: { position: 'asc' },
    });

    return questions.map(mapQuestion);
  }

  async submitQuiz(
    questionSetId: string,
    selectedAnswerOptionIdsByQuestionId: Record<string, string>,
  ): Promise<QuizResult> {
    const questionSet = await this.prisma.questionSet.findUnique({
      where: { id: questionSetId },
      include: {
        questions: {
          include: { answerOptions: { orderBy: { position: 'asc' } } },
          orderBy: { position: 'asc' },
        },
      },
    });

    if (questionSet === null) {
      throw new LearningResourceNotFoundError('Question set not found.');
    }

    const questionIds = new Set(questionSet.questions.map(({ id }) => id));
    for (const questionId of Object.keys(
      selectedAnswerOptionIdsByQuestionId,
    )) {
      if (!questionIds.has(questionId)) {
        throw new InvalidQuizSubmissionError(
          `Question ${questionId} does not belong to this question set.`,
        );
      }
    }

    const answerReviews: AnswerReview[] = questionSet.questions.map(
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

        const correctAnswers = question.answerOptions.filter(
          ({ isCorrect }) => isCorrect,
        );
        if (correctAnswers.length !== 1) {
          throw new LearningDataIntegrityError(
            `Question ${question.id} must have exactly one correct answer.`,
          );
        }

        const correctAnswer = correctAnswers[0];
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
    const totalQuestions = questionSet.questions.length;

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

  private async requireSubject(subjectId: string): Promise<void> {
    const subject = await this.prisma.subject.findUnique({
      where: { id: subjectId },
      select: { id: true },
    });
    if (subject === null) {
      throw new LearningResourceNotFoundError('Subject not found.');
    }
  }

  private async requireQuestionSet(questionSetId: string): Promise<void> {
    const questionSet = await this.prisma.questionSet.findUnique({
      where: { id: questionSetId },
      select: { id: true },
    });
    if (questionSet === null) {
      throw new LearningResourceNotFoundError('Question set not found.');
    }
  }
}

export function createPrismaLearningService(
  prisma: PrismaClient = getPrismaClient(),
): PrismaLearningService {
  return new PrismaLearningService(prisma);
}
