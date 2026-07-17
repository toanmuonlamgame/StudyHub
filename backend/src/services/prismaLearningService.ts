import type { Prisma, PrismaClient } from '@prisma/client';

import { getPrismaClient } from '../db/prisma.js';
import type {
  AnswerCheckResult,
  AnswerReview,
  ExamAttemptDetail,
  ExamAttemptSummary,
  ListQuestionSetsParams,
  ListStudyMaterialsParams,
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
  QuestionSetSubmissionInput,
} from '../types/questionSetSubmission.js';
import {
  mapQuestion,
  mapQuestionSet,
  mapStudyMaterial,
  mapStudyMaterialListItem,
  mapSubject,
  mapTopic,
} from './learningMappers.js';
import {
  ExamAttemptIdempotencyConflictError,
  InvalidQuizSubmissionError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  QuestionSetSubmissionStateError,
  QuestionSetSubmissionValidationError,
  type LearningService,
} from './learningService.js';
import { validateQuestionSetSubmission } from './questionSetSubmissionValidation.js';
import {
  createQuestionSetListItem,
  decodeQuestionSetCursor,
  encodeQuestionSetCursor,
} from './questionSetPagination.js';
import {
  decodeStudyMaterialCursor,
  encodeStudyMaterialCursor,
} from './studyMaterialPagination.js';
import { calculateRoundedPercentage } from './quizScoring.js';
import {
  createExamAttemptFingerprint,
  validateExamAttemptInput,
} from './examAttemptValidation.js';

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
      where: { subjectId, status: 'published' },
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
        status: 'published',
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
    const questionSet = await this.prisma.questionSet.findFirst({
      where: { id: questionSetId, status: 'published' },
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
    const question = await this.prisma.question.findFirst({
      where: { id: questionId, questionSet: { status: 'published' } },
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
      explanation: question.explanation,
    };
  }

  async submitQuiz(
    questionSetId: string,
    selectedAnswerOptionIdsByQuestionId: Record<string, string>,
  ): Promise<QuizResult> {
    const questionSet = await this.prisma.questionSet.findFirst({
      where: { id: questionSetId, status: 'published' },
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
        const selectedAnswer = selectedAnswerOptionId
          ? question.answerOptions.find(({ id }) => id === selectedAnswerOptionId)
          : undefined;
        if (selectedAnswerOptionId !== undefined && selectedAnswer === undefined) {
          throw new InvalidQuizSubmissionError(
            `Answer option ${selectedAnswerOptionId} does not belong to question ${question.id}.`,
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
          answerOptions: question.answerOptions.map(({ id, text }) => ({ id, text })),
          selectedAnswerOptionId: selectedAnswer?.id ?? null,
          selectedAnswerText: selectedAnswer?.text ?? null,
          correctAnswerOptionId: correctAnswer.id,
          correctAnswerText: correctAnswer.text,
          isCorrect: selectedAnswer?.id === correctAnswer.id,
          explanation: question.explanation,
        };
      },
    );

    const correctAnswers = answerReviews.filter(
      ({ isCorrect }) => isCorrect,
    ).length;
    const totalQuestions = questionSet.questions.length;
    const unansweredAnswers = answerReviews.filter(
      ({ selectedAnswerOptionId }) => selectedAnswerOptionId === null,
    ).length;

    return {
      questionSetId: questionSet.id,
      questionSetTitle: questionSet.title,
      totalQuestions,
      correctAnswers,
      wrongAnswers: totalQuestions - correctAnswers - unansweredAnswers,
      unansweredAnswers,
      percentageScore: calculateRoundedPercentage(correctAnswers, totalQuestions),
      answerReviews,
    };
  }

  async saveExamAttempt(
    userId: string,
    questionSetId: string,
    input: SaveExamAttemptInput,
  ): Promise<SaveExamAttemptOutcome> {
    const startedAt = validateExamAttemptInput(input);
    const requestFingerprint = createExamAttemptFingerprint(
      questionSetId,
      input,
      startedAt,
    );
    const existing = await this.findExamAttemptBySubmissionId(
      userId,
      input.submissionId,
    );
    if (existing !== null) {
      if (existing.requestFingerprint !== requestFingerprint) {
        throw new ExamAttemptIdempotencyConflictError(
          'Submission ID was already used with different attempt data.',
        );
      }
      return { attempt: mapExamAttemptDetail(existing), created: false };
    }

    const result = await this.submitQuiz(
      questionSetId,
      input.selectedAnswerOptionIdsByQuestionId,
    );
    try {
      const row = await this.prisma.$transaction((transaction) =>
        transaction.examAttempt.create({
          data: {
            userId,
            submissionId: input.submissionId,
            requestFingerprint,
            questionSetId: result.questionSetId,
            sourceQuestionSetId: result.questionSetId,
            questionSetTitle: result.questionSetTitle,
            startedAt,
            totalQuestions: result.totalQuestions,
            correctAnswers: result.correctAnswers,
            wrongAnswers: result.wrongAnswers,
            unansweredAnswers: result.unansweredAnswers,
            percentageScore: result.percentageScore,
            answers: {
              create: result.answerReviews.map((review, index) => ({
                questionId: review.questionId,
                questionText: review.questionText,
                answerOptions: review.answerOptions.map(({ id, text }) => ({
                  id,
                  text,
                })) as Prisma.InputJsonValue,
                selectedAnswerOptionId: review.selectedAnswerOptionId,
                selectedAnswerText: review.selectedAnswerText,
                correctAnswerOptionId: review.correctAnswerOptionId,
                correctAnswerText: review.correctAnswerText,
                isCorrect: review.isCorrect,
                explanation: review.explanation,
                position: index + 1,
              })),
            },
          },
          include: attemptAnswersInclude,
        }),
      );
      return { attempt: mapExamAttemptDetail(row), created: true };
    } catch (error) {
      if (!isUniqueConstraintError(error)) {
        throw error;
      }
      const duplicate = await this.findExamAttemptBySubmissionId(
        userId,
        input.submissionId,
      );
      if (
        duplicate === null ||
        duplicate.requestFingerprint !== requestFingerprint
      ) {
        throw new ExamAttemptIdempotencyConflictError(
          'Submission ID conflicts with another attempt.',
        );
      }
      return { attempt: mapExamAttemptDetail(duplicate), created: false };
    }
  }

  async listExamAttempts(userId: string): Promise<ExamAttemptSummary[]> {
    const rows = await this.prisma.examAttempt.findMany({
      where: { userId },
      orderBy: [{ completedAt: 'desc' }, { id: 'desc' }],
      take: 100,
    });
    return rows.map(mapExamAttemptSummary);
  }

  async getExamAttempt(
    userId: string,
    attemptId: string,
  ): Promise<ExamAttemptDetail | null> {
    const row = await this.prisma.examAttempt.findFirst({
      where: { id: attemptId, userId },
      include: attemptAnswersInclude,
    });
    return row === null ? null : mapExamAttemptDetail(row);
  }

  private findExamAttemptBySubmissionId(
    userId: string,
    submissionId: string,
  ): Promise<ExamAttemptWithAnswers | null> {
    return this.prisma.examAttempt.findUnique({
      where: { userId_submissionId: { userId, submissionId } },
      include: attemptAnswersInclude,
    });
  }

  async createQuestionSetSubmission(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    this.assertValidSubmission(input, false);
    await this.validateSubmissionReferences(input);
    const row = await this.prisma.$transaction(async (transaction) =>
      transaction.questionSet.create({
        data: {
          subjectId: input.subjectId,
          ...(input.topicId === undefined ? {} : { topicId: input.topicId }),
          title: input.title.trim(),
          description: input.description.trim(),
          status: 'draft',
          sourceType: 'community',
          questions: { create: questionCreateData(input) },
        },
        include: submissionInclude,
      }),
    );
    return mapQuestionSetSubmission(row);
  }

  async createQuestionSetSubmissionForReview(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    this.assertValidSubmission(input, true);
    await this.validateSubmissionReferences(input);
    const row = await this.prisma.$transaction(async (transaction) =>
      transaction.questionSet.create({
        data: {
          subjectId: input.subjectId,
          ...(input.topicId === undefined ? {} : { topicId: input.topicId }),
          title: input.title.trim(),
          description: input.description.trim(),
          status: 'pendingReview',
          sourceType: 'community',
          submittedAt: new Date(),
          questions: { create: questionCreateData(input) },
        },
        include: submissionInclude,
      }),
    );
    return mapQuestionSetSubmission(row);
  }

  async updateQuestionSetSubmission(
    submissionId: string,
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    const current = await this.requireSubmission(submissionId);
    if (current.status !== 'draft') {
      throw new QuestionSetSubmissionStateError(
        'Only draft submissions can be edited.',
      );
    }
    this.assertValidSubmission(input, false);
    await this.validateSubmissionReferences(input);
    const row = await this.prisma.$transaction(async (transaction) => {
      const lockedDraft = await transaction.questionSet.updateMany({
        where: {
          id: submissionId,
          sourceType: 'community',
          status: 'draft',
        },
        data: {
          subjectId: input.subjectId,
          topicId: input.topicId ?? null,
          title: input.title.trim(),
          description: input.description.trim(),
        },
      });
      if (lockedDraft.count !== 1) {
        throw new QuestionSetSubmissionStateError(
          'Only draft submissions can be edited.',
        );
      }
      await transaction.question.deleteMany({ where: { questionSetId: submissionId } });
      return transaction.questionSet.update({
        where: { id: submissionId },
        data: {
          questions: { create: questionCreateData(input) },
        },
        include: submissionInclude,
      });
    });
    return mapQuestionSetSubmission(row);
  }

  async getQuestionSetSubmission(
    submissionId: string,
  ): Promise<QuestionSetSubmission | null> {
    const row = await this.prisma.questionSet.findFirst({
      where: { id: submissionId, sourceType: 'community' },
      include: submissionInclude,
    });
    return row === null ? null : mapQuestionSetSubmission(row);
  }

  async submitQuestionSetForReview(
    submissionId: string,
  ): Promise<QuestionSetSubmission> {
    const current = await this.requireSubmission(submissionId);
    if (current.status !== 'draft') {
      throw new QuestionSetSubmissionStateError(
        'Only draft submissions can be submitted for review.',
      );
    }
    const mapped = mapQuestionSetSubmission(current);
    this.assertValidSubmission(mapped, true);
    const row = await this.prisma.$transaction(async (transaction) => {
      const transitioned = await transaction.questionSet.updateMany({
        where: {
          id: submissionId,
          sourceType: 'community',
          status: 'draft',
        },
        data: { status: 'pendingReview', submittedAt: new Date() },
      });
      if (transitioned.count !== 1) {
        throw new QuestionSetSubmissionStateError(
          'Only draft submissions can be submitted for review.',
        );
      }
      return transaction.questionSet.findUniqueOrThrow({
        where: { id: submissionId },
        include: submissionInclude,
      });
    });
    return mapQuestionSetSubmission(row);
  }

  private assertValidSubmission(
    input: QuestionSetSubmissionInput,
    requireComplete: boolean,
  ): void {
    const fields = validateQuestionSetSubmission(input, { requireComplete });
    if (fields.length > 0) {
      throw new QuestionSetSubmissionValidationError(fields);
    }
  }

  private async validateSubmissionReferences(
    input: QuestionSetSubmissionInput,
  ): Promise<void> {
    const subject = await this.prisma.subject.findUnique({
      where: { id: input.subjectId },
      select: { id: true },
    });
    if (subject === null) {
      throw new QuestionSetSubmissionValidationError([
        { path: 'subjectId', message: 'Subject does not exist.' },
      ]);
    }
    if (input.topicId !== undefined) {
      const topic = await this.prisma.topic.findFirst({
        where: { id: input.topicId, subjectId: input.subjectId },
        select: { id: true },
      });
      if (topic === null) {
        throw new QuestionSetSubmissionValidationError([
          { path: 'topicId', message: 'Topic must belong to the selected subject.' },
        ]);
      }
    }
  }

  private async requireSubmission(submissionId: string) {
    const submission = await this.prisma.questionSet.findFirst({
      where: { id: submissionId, sourceType: 'community' },
      include: submissionInclude,
    });
    if (submission === null) {
      throw new LearningResourceNotFoundError('Submission not found.');
    }
    return submission;
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
    const questionSet = await this.prisma.questionSet.findFirst({
      where: { id: questionSetId, status: 'published' },
      select: { id: true },
    });
    if (questionSet === null) {
      throw new LearningResourceNotFoundError('Question set not found.');
    }
  }
}

type ExamAttemptWithAnswers = Prisma.ExamAttemptGetPayload<{
  include: { answers: { orderBy: { position: 'asc' } } };
}>;

const attemptAnswersInclude = {
  answers: { orderBy: { position: 'asc' as const } },
} satisfies Prisma.ExamAttemptInclude;

function mapExamAttemptSummary(
  row: Omit<ExamAttemptWithAnswers, 'answers'> | ExamAttemptWithAnswers,
): ExamAttemptSummary {
  return {
    id: row.id,
    questionSetId: row.questionSetId,
    questionSetTitle: row.questionSetTitle,
    startedAt: row.startedAt?.toISOString() ?? null,
    completedAt: row.completedAt.toISOString(),
    totalQuestions: row.totalQuestions,
    correctAnswers: row.correctAnswers,
    wrongAnswers: row.wrongAnswers,
    unansweredAnswers: row.unansweredAnswers,
    percentageScore: row.percentageScore,
  };
}

function mapExamAttemptDetail(row: ExamAttemptWithAnswers): ExamAttemptDetail {
  const summary = mapExamAttemptSummary(row);
  const answerReviews: AnswerReview[] = row.answers.map((answer) => ({
    questionId: answer.questionId,
    questionText: answer.questionText,
    answerOptions: readStoredAnswerOptions(answer.answerOptions),
    selectedAnswerOptionId: answer.selectedAnswerOptionId,
    selectedAnswerText: answer.selectedAnswerText,
    correctAnswerOptionId: answer.correctAnswerOptionId,
    correctAnswerText: answer.correctAnswerText,
    isCorrect: answer.isCorrect,
    explanation: answer.explanation,
  }));
  return {
    ...summary,
    result: {
      questionSetId: summary.questionSetId,
      questionSetTitle: summary.questionSetTitle,
      totalQuestions: summary.totalQuestions,
      correctAnswers: summary.correctAnswers,
      wrongAnswers: summary.wrongAnswers,
      unansweredAnswers: summary.unansweredAnswers,
      percentageScore: summary.percentageScore,
      answerReviews,
    },
  };
}

function readStoredAnswerOptions(value: Prisma.JsonValue): AnswerReview['answerOptions'] {
  if (!Array.isArray(value)) {
    throw new LearningDataIntegrityError('Stored answer options are invalid.');
  }
  return value.map((option) => {
    if (
      option === null ||
      Array.isArray(option) ||
      typeof option !== 'object' ||
      typeof option.id !== 'string' ||
      typeof option.text !== 'string'
    ) {
      throw new LearningDataIntegrityError('Stored answer options are invalid.');
    }
    return { id: option.id, text: option.text };
  });
}

function isUniqueConstraintError(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    error.code === 'P2002'
  );
}

const submissionInclude = {
  questions: {
    include: { answerOptions: { orderBy: { position: 'asc' as const } } },
    orderBy: { position: 'asc' as const },
  },
} as const;

function questionCreateData(input: QuestionSetSubmissionInput) {
  return input.questions.map((question, questionIndex) => ({
    text: question.text.trim(),
    explanation: question.explanation?.trim() || null,
    position: questionIndex + 1,
    answerOptions: {
      create: question.answerOptions.map((option, optionIndex) => ({
        text: option.text.trim(),
        isCorrect: option.isCorrect,
        position: optionIndex + 1,
      })),
    },
  }));
}

function mapQuestionSetSubmission(row: any): QuestionSetSubmission {
  return {
    id: row.id,
    subjectId: row.subjectId,
    ...(row.topicId === null ? {} : { topicId: row.topicId }),
    title: row.title,
    description: row.description,
    status: row.status,
    sourceType: row.sourceType,
    ...(row.createdByUserId === null ? {} : { createdByUserId: row.createdByUserId }),
    ...(row.submittedAt === null ? {} : { submittedAt: row.submittedAt.toISOString() }),
    ...(row.reviewedAt === null ? {} : { reviewedAt: row.reviewedAt.toISOString() }),
    ...(row.publishedAt === null ? {} : { publishedAt: row.publishedAt.toISOString() }),
    ...(row.rejectionReason === null ? {} : { rejectionReason: row.rejectionReason }),
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
    questions: row.questions.map((question: any) => ({
      text: question.text,
      ...(question.explanation === null ? {} : { explanation: question.explanation }),
      answerOptions: question.answerOptions.map((option: any) => ({
        text: option.text,
        isCorrect: option.isCorrect,
      })),
    })),
  };
}

export function createPrismaLearningService(
  prisma: PrismaClient = getPrismaClient(),
): PrismaLearningService {
  return new PrismaLearningService(prisma);
}
