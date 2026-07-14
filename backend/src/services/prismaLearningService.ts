import type { PrismaClient } from '@prisma/client';

import { getPrismaClient } from '../db/prisma.js';
import type {
  AnswerCheckResult,
  AnswerReview,
  ListQuestionSetsParams,
  ListStudyMaterialsParams,
  PaginatedQuestionSets,
  PaginatedStudyMaterials,
  Question,
  QuestionSet,
  QuizResult,
  Subject,
  StudyMaterial,
  Topic,
} from '../types/learning.js';
import {
  mapQuestion,
  mapQuestionSet,
  mapStudyMaterial,
  mapStudyMaterialListItem,
  mapSubject,
  mapTopic,
} from './learningMappers.js';
import {
  InvalidQuizSubmissionError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  type LearningService,
} from './learningService.js';
import {
  createQuestionSetListItem,
  decodeQuestionSetCursor,
  encodeQuestionSetCursor,
} from './questionSetPagination.js';
import {
  decodeStudyMaterialCursor,
  encodeStudyMaterialCursor,
} from './studyMaterialPagination.js';

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

  async listQuestionSets(
    params: ListQuestionSetsParams,
  ): Promise<PaginatedQuestionSets> {
    const cursor =
      params.cursor === undefined
        ? undefined
        : decodeQuestionSetCursor(params.cursor);
    const search = params.q?.trim();
    const questionSets = await this.prisma.questionSet.findMany({
      where: {
        ...(params.subjectId === undefined
          ? {}
          : { subjectId: params.subjectId }),
        ...(params.topicId === undefined ? {} : { topicId: params.topicId }),
        ...(search === undefined || search.length === 0
          ? {}
          : { title: { contains: search, mode: 'insensitive' } }),
        ...(cursor === undefined
          ? {}
          : {
              OR: [
                { createdAt: { lt: new Date(cursor.createdAt) } },
                {
                  createdAt: new Date(cursor.createdAt),
                  id: { lt: cursor.id },
                },
              ],
            }),
      },
      include: { _count: { select: { questions: true } } },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });

    const hasMore = questionSets.length > params.limit;
    const pageRows = questionSets.slice(0, params.limit);
    const items = pageRows.map((questionSet) =>
      createQuestionSetListItem(
        mapQuestionSet(questionSet),
        questionSet.createdAt,
      ),
    );
    const lastItem = items.at(-1);

    return {
      items,
      nextCursor:
        hasMore && lastItem !== undefined
          ? encodeQuestionSetCursor(lastItem)
          : null,
      hasMore,
    };
  }

  async getQuestionSetById(questionSetId: string): Promise<QuestionSet | null> {
    const questionSet = await this.prisma.questionSet.findUnique({
      where: { id: questionSetId },
      include: { _count: { select: { questions: true } } },
    });

    return questionSet === null ? null : mapQuestionSet(questionSet);
  }

  async listStudyMaterials(
    params: ListStudyMaterialsParams,
  ): Promise<PaginatedStudyMaterials> {
    const cursor =
      params.cursor === undefined
        ? undefined
        : decodeStudyMaterialCursor(params.cursor);
    const search = params.q?.trim();
    const materials = await this.prisma.studyMaterial.findMany({
      where: {
        status: 'published',
        ...(params.subjectId === undefined
          ? {}
          : { subjectId: params.subjectId }),
        ...(params.topicId === undefined ? {} : { topicId: params.topicId }),
        ...(params.materialType === undefined
          ? {}
          : { materialType: params.materialType }),
        ...(params.language === undefined
          ? {}
          : { language: params.language }),
        ...(search === undefined || search.length === 0
          ? {}
          : {
              OR: [
                { title: { contains: search, mode: 'insensitive' } },
                { description: { contains: search, mode: 'insensitive' } },
              ],
            }),
        ...(cursor === undefined
          ? {}
          : {
              AND: [
                {
                  OR: [
                    { createdAt: { lt: new Date(cursor.createdAt) } },
                    {
                      createdAt: new Date(cursor.createdAt),
                      id: { lt: cursor.id },
                    },
                  ],
                },
              ],
            }),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });

    const hasMore = materials.length > params.limit;
    const items = materials.slice(0, params.limit).map(mapStudyMaterialListItem);
    const lastItem = items.at(-1);
    return {
      items,
      nextCursor:
        hasMore && lastItem !== undefined
          ? encodeStudyMaterialCursor(lastItem)
          : null,
      hasMore,
    };
  }

  async getStudyMaterialById(materialId: string): Promise<StudyMaterial | null> {
    const material = await this.prisma.studyMaterial.findFirst({
      where: { id: materialId, status: 'published' },
    });
    return material === null ? null : mapStudyMaterial(material);
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

  async checkAnswer(
    questionId: string,
    selectedAnswerOptionId: string,
  ): Promise<AnswerCheckResult> {
    const question = await this.prisma.question.findUnique({
      where: { id: questionId },
      include: { answerOptions: { orderBy: { position: 'asc' } } },
    });

    if (question === null) {
      throw new LearningResourceNotFoundError('Question not found.');
    }

    const selectedAnswer = question.answerOptions.find(
      ({ id }) => id === selectedAnswerOptionId,
    );
    if (selectedAnswer === undefined) {
      throw new InvalidQuizSubmissionError(
        `Answer option ${selectedAnswerOptionId} does not belong to question ${questionId}.`,
      );
    }

    const correctAnswers = question.answerOptions.filter(
      ({ isCorrect }) => isCorrect,
    );
    if (correctAnswers.length !== 1) {
      throw new LearningDataIntegrityError(
        `Question ${questionId} must have exactly one correct answer.`,
      );
    }

    const correctAnswer = correctAnswers[0];
    return {
      questionId,
      selectedAnswerOptionId: selectedAnswer.id,
      selectedAnswerText: selectedAnswer.text,
      correctAnswerOptionId: correctAnswer.id,
      correctAnswerText: correctAnswer.text,
      isCorrect: selectedAnswer.id === correctAnswer.id,
    };
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
