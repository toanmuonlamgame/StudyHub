import { Prisma, type PrismaClient } from '@prisma/client';

import { getPrismaClient } from '../db/prisma.js';
import type {
  AdminContributionDetail,
  AdminContributionListItem,
  AdminContributionListParams,
  AdminDashboardSummary,
  AdminMediaItem,
  AdminMediaListParams,
  AdminPage,
  AdminQuestionSetDetail,
  AdminQuestionSetListItem,
  AdminQuestionSetListParams,
  AdminSubject,
  AdminTopic,
  AdminUser,
  AdminUserListParams,
  UpdateAdminQuestionSetInput,
} from '../types/admin.js';
import { readMediaAsset } from './learningMappers.js';
import {
  AdminConflictError,
  AdminNotFoundError,
  type AdminService,
  AdminValidationError,
  createAdminPage,
  normalizeAdminName,
  normalizeRejectionReason,
} from './adminService.js';

const submissionInclude = {
  subject: true,
  topic: true,
  questions: {
    include: { answerOptions: { orderBy: { position: 'asc' as const } } },
    orderBy: { position: 'asc' as const },
  },
  _count: { select: { examAttempts: true } },
} as const;

export class PrismaAdminService implements AdminService {
  constructor(private readonly prisma: PrismaClient) {}

  async getDashboard(): Promise<AdminDashboardSummary> {
    const [totalUsers, totalQuestionSets, pendingContributions, approvedContributions, rejectedContributions, totalAttempts, recent] =
      await Promise.all([
        this.prisma.user.count(),
        this.prisma.questionSet.count(),
        this.prisma.questionSet.count({ where: { sourceType: 'community', status: 'pendingReview' } }),
        this.prisma.questionSet.count({ where: { sourceType: 'community', status: 'published' } }),
        this.prisma.questionSet.count({ where: { sourceType: 'community', status: 'rejected' } }),
        this.prisma.examAttempt.count(),
        this.prisma.questionSet.findMany({
          where: { sourceType: 'community' },
          include: submissionInclude,
          orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
          take: 5,
        }),
      ]);
    return {
      totalUsers,
      totalQuestionSets,
      pendingContributions,
      approvedContributions,
      rejectedContributions,
      totalAttempts,
      recentContributions: await Promise.all(recent.map((row) => this.mapContributionListItem(row))),
    };
  }

  async listContributions(params: AdminContributionListParams): Promise<AdminPage<AdminContributionListItem>> {
    const where: Prisma.QuestionSetWhereInput = {
      sourceType: 'community',
      ...(params.status === undefined ? {} : { status: params.status }),
      ...(params.subjectId === undefined ? {} : { subjectId: params.subjectId }),
      ...(params.topicId === undefined ? {} : { topicId: params.topicId }),
      ...(params.q?.trim() ? { title: { contains: params.q.trim(), mode: 'insensitive' } } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.questionSet.count({ where }),
      this.prisma.questionSet.findMany({
        where,
        include: submissionInclude,
        orderBy: [{ submittedAt: 'desc' }, { updatedAt: 'desc' }, { id: 'desc' }],
        skip: (params.page - 1) * params.limit,
        take: params.limit,
      }),
    ]);
    return createAdminPage(
      await Promise.all(rows.map((row) => this.mapContributionListItem(row))),
      params.page,
      params.limit,
      total,
    );
  }

  async getContribution(id: string): Promise<AdminContributionDetail | null> {
    const row = await this.prisma.questionSet.findFirst({
      where: { id, sourceType: 'community' },
      include: submissionInclude,
    });
    return row === null ? null : this.mapContributionDetail(row);
  }

  async approveContribution(id: string, adminUserId: string): Promise<AdminContributionDetail> {
    const row = await this.prisma.$transaction(async (tx) => {
      const changed = await tx.questionSet.updateMany({
        where: { id, sourceType: 'community', status: 'pendingReview' },
        data: {
          status: 'published',
          reviewedAt: new Date(),
          publishedAt: new Date(),
          rejectionReason: null,
          reviewedByUserId: adminUserId,
          isArchived: false,
        },
      });
      if (changed.count !== 1) throw new AdminConflictError('Contribution is no longer pending review.');
      return tx.questionSet.findUniqueOrThrow({ where: { id }, include: submissionInclude });
    });
    return this.mapContributionDetail(row);
  }

  async rejectContribution(id: string, adminUserId: string, reason: string): Promise<AdminContributionDetail> {
    const normalizedReason = normalizeRejectionReason(reason);
    const row = await this.prisma.$transaction(async (tx) => {
      const changed = await tx.questionSet.updateMany({
        where: { id, sourceType: 'community', status: 'pendingReview' },
        data: {
          status: 'rejected',
          reviewedAt: new Date(),
          rejectionReason: normalizedReason,
          reviewedByUserId: adminUserId,
        },
      });
      if (changed.count !== 1) throw new AdminConflictError('Contribution is no longer pending review.');
      return tx.questionSet.findUniqueOrThrow({ where: { id }, include: submissionInclude });
    });
    return this.mapContributionDetail(row);
  }

  async listQuestionSets(params: AdminQuestionSetListParams): Promise<AdminPage<AdminQuestionSetListItem>> {
    const where: Prisma.QuestionSetWhereInput = {
      ...(params.status === undefined ? {} : { status: params.status }),
      ...(params.subjectId === undefined ? {} : { subjectId: params.subjectId }),
      ...(params.topicId === undefined ? {} : { topicId: params.topicId }),
      ...(params.archived === undefined ? {} : { isArchived: params.archived }),
      ...(params.q?.trim() ? { title: { contains: params.q.trim(), mode: 'insensitive' } } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.questionSet.count({ where }),
      this.prisma.questionSet.findMany({
        where,
        include: submissionInclude,
        orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
        skip: (params.page - 1) * params.limit,
        take: params.limit,
      }),
    ]);
    return createAdminPage(
      await Promise.all(rows.map((row) => this.mapQuestionSetListItem(row))),
      params.page,
      params.limit,
      total,
    );
  }

  async getQuestionSet(id: string): Promise<AdminQuestionSetDetail | null> {
    const row = await this.prisma.questionSet.findUnique({ where: { id }, include: submissionInclude });
    return row === null ? null : this.mapQuestionSetDetail(row);
  }

  async updateQuestionSet(id: string, input: UpdateAdminQuestionSetInput): Promise<AdminQuestionSetDetail> {
    const current = await this.prisma.questionSet.findUnique({ where: { id } });
    if (current === null) throw new AdminNotFoundError('Question set not found.');
    const subjectId = input.subjectId ?? current.subjectId;
    const topicId = input.topicId === undefined ? current.topicId : input.topicId;
    await this.assertSubjectTopic(subjectId, topicId);
    const row = await this.prisma.questionSet.update({
      where: { id },
      data: {
        ...(input.title === undefined ? {} : { title: normalizeAdminName(input.title, 'Title') }),
        ...(input.description === undefined ? {} : { description: input.description.trim().slice(0, 2000) }),
        ...(input.subjectId === undefined ? {} : { subjectId }),
        ...(input.topicId === undefined ? {} : { topicId }),
        ...(input.isArchived === undefined ? {} : { isArchived: input.isArchived }),
      },
      include: submissionInclude,
    });
    return this.mapQuestionSetDetail(row);
  }

  async listSubjects(): Promise<AdminSubject[]> {
    const rows = await this.prisma.subject.findMany({
      include: { _count: { select: { topics: true, questionSets: true } } },
      orderBy: [{ isArchived: 'asc' }, { name: 'asc' }],
    });
    return rows.map(mapSubject);
  }

  async createSubject(input: { name: string; description?: string }): Promise<AdminSubject> {
    const name = normalizeAdminName(input.name, 'Subject name');
    await this.assertSubjectNameAvailable(name);
    const row = await this.prisma.subject.create({
      data: { name, description: input.description?.trim() || null },
      include: { _count: { select: { topics: true, questionSets: true } } },
    });
    return mapSubject(row);
  }

  async updateSubject(id: string, input: { name?: string; description?: string | null; isArchived?: boolean }): Promise<AdminSubject> {
    const current = await this.prisma.subject.findUnique({ where: { id } });
    if (current === null) throw new AdminNotFoundError('Subject not found.');
    const name = input.name === undefined ? undefined : normalizeAdminName(input.name, 'Subject name');
    if (name !== undefined) await this.assertSubjectNameAvailable(name, id);
    const row = await this.prisma.subject.update({
      where: { id },
      data: {
        ...(name === undefined ? {} : { name }),
        ...(input.description === undefined ? {} : { description: input.description?.trim() || null }),
        ...(input.isArchived === undefined ? {} : { isArchived: input.isArchived }),
      },
      include: { _count: { select: { topics: true, questionSets: true } } },
    });
    return mapSubject(row);
  }

  async listTopics(subjectId?: string): Promise<AdminTopic[]> {
    const rows = await this.prisma.topic.findMany({
      where: subjectId === undefined ? {} : { subjectId },
      include: { subject: true, _count: { select: { questionSets: true } } },
      orderBy: [{ isArchived: 'asc' }, { name: 'asc' }],
    });
    return rows.map(mapTopic);
  }

  async createTopic(input: { subjectId: string; name: string }): Promise<AdminTopic> {
    const name = normalizeAdminName(input.name, 'Topic name');
    await this.assertSubjectTopic(input.subjectId, null);
    await this.assertTopicNameAvailable(input.subjectId, name);
    const row = await this.prisma.topic.create({
      data: { subjectId: input.subjectId, name },
      include: { subject: true, _count: { select: { questionSets: true } } },
    });
    return mapTopic(row);
  }

  async updateTopic(id: string, input: { subjectId?: string; name?: string; isArchived?: boolean }): Promise<AdminTopic> {
    const current = await this.prisma.topic.findUnique({ where: { id } });
    if (current === null) throw new AdminNotFoundError('Topic not found.');
    const subjectId = input.subjectId ?? current.subjectId;
    const name = input.name === undefined ? current.name : normalizeAdminName(input.name, 'Topic name');
    await this.assertSubjectTopic(subjectId, null);
    await this.assertTopicNameAvailable(subjectId, name, id);
    const row = await this.prisma.topic.update({
      where: { id },
      data: {
        ...(input.subjectId === undefined ? {} : { subjectId }),
        ...(input.name === undefined ? {} : { name }),
        ...(input.isArchived === undefined ? {} : { isArchived: input.isArchived }),
      },
      include: { subject: true, _count: { select: { questionSets: true } } },
    });
    return mapTopic(row);
  }

  async listUsers(params: AdminUserListParams): Promise<AdminPage<AdminUser>> {
    const where: Prisma.UserWhereInput = {
      ...(params.role === undefined ? {} : { role: params.role }),
      ...(params.status === undefined ? {} : { status: params.status }),
      ...(params.q?.trim()
        ? {
            OR: [
              { email: { contains: params.q.trim(), mode: 'insensitive' } },
              { displayName: { contains: params.q.trim(), mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        include: { _count: { select: { bookmarks: true } } },
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        skip: (params.page - 1) * params.limit,
        take: params.limit,
      }),
    ]);
    const items = await Promise.all(rows.map((row) => this.mapUser(row)));
    return createAdminPage(items, params.page, params.limit, total);
  }

  async getUser(id: string): Promise<AdminUser | null> {
    const row = await this.prisma.user.findUnique({
      where: { id },
      include: { _count: { select: { bookmarks: true } } },
    });
    return row === null ? null : this.mapUser(row);
  }

  async updateUser(id: string, actorId: string, input: { role?: 'user' | 'admin'; status?: 'active' | 'disabled' }): Promise<AdminUser> {
    const current = await this.prisma.user.findUnique({ where: { id } });
    if (current === null) throw new AdminNotFoundError('User not found.');
    if (id === actorId && (input.status === 'disabled' || input.role === 'user')) {
      throw new AdminConflictError('You cannot disable or demote your own admin account.');
    }
    if (current.role === 'admin' && current.status === 'active' &&
        (input.role === 'user' || input.status === 'disabled')) {
      const activeAdmins = await this.prisma.user.count({ where: { role: 'admin', status: 'active' } });
      if (activeAdmins <= 1) throw new AdminConflictError('At least one active admin is required.');
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.user.update({ where: { id }, data: input });
      if (input.status === 'disabled') await tx.authSession.deleteMany({ where: { userId: id } });
    });
    return (await this.getUser(id))!;
  }

  async listMedia(params: AdminMediaListParams): Promise<AdminPage<AdminMediaItem>> {
    const rows = await this.prisma.question.findMany({
      where: {
        OR: [{ media: { not: Prisma.JsonNull } }, { explanationMedia: { not: Prisma.JsonNull } }],
        ...(params.q?.trim()
          ? { questionSet: { title: { contains: params.q.trim(), mode: 'insensitive' } } }
          : {}),
      },
      include: { questionSet: true },
      orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
    });
    let media = rows.flatMap((row) => mapMedia(row));
    if (params.broken !== undefined) media = media.filter((item) => item.brokenReference === params.broken);
    const total = media.length;
    media = media.slice((params.page - 1) * params.limit, params.page * params.limit);
    return createAdminPage(media, params.page, params.limit, total);
  }

  private async mapContributionListItem(row: any): Promise<AdminContributionListItem> {
    const contributor = row.createdByUserId
      ? await this.prisma.user.findUnique({ where: { id: row.createdByUserId }, select: { displayName: true } })
      : null;
    return {
      id: row.id,
      title: row.title,
      status: row.status,
      subjectId: row.subjectId,
      subjectName: row.subject.name,
      ...(row.topicId ? { topicId: row.topicId, topicName: row.topic?.name } : {}),
      ...(row.createdByUserId ? { contributorId: row.createdByUserId } : {}),
      ...(contributor ? { contributorName: contributor.displayName } : {}),
      questionCount: row.questions.length,
      ...(row.submittedAt ? { submittedAt: row.submittedAt.toISOString() } : {}),
      ...(row.reviewedAt ? { reviewedAt: row.reviewedAt.toISOString() } : {}),
      ...(row.rejectionReason ? { rejectionReason: row.rejectionReason } : {}),
      updatedAt: row.updatedAt.toISOString(),
    };
  }

  private async mapContributionDetail(row: any): Promise<AdminContributionDetail> {
    const contributor = row.createdByUserId
      ? await this.prisma.user.findUnique({
          where: { id: row.createdByUserId },
          select: { id: true, displayName: true, email: true },
        })
      : null;
    return {
      id: row.id,
      subjectId: row.subjectId,
      subjectName: row.subject.name,
      ...(row.topicId ? { topicId: row.topicId, topicName: row.topic?.name } : {}),
      title: row.title,
      description: row.description,
      status: row.status,
      sourceType: row.sourceType,
      ...(row.createdByUserId ? { createdByUserId: row.createdByUserId } : {}),
      ...(contributor ? { contributor } : {}),
      ...(row.submittedAt ? { submittedAt: row.submittedAt.toISOString() } : {}),
      ...(row.reviewedAt ? { reviewedAt: row.reviewedAt.toISOString() } : {}),
      ...(row.publishedAt ? { publishedAt: row.publishedAt.toISOString() } : {}),
      ...(row.rejectionReason ? { rejectionReason: row.rejectionReason } : {}),
      ...(row.reviewedByUserId ? { reviewedByUserId: row.reviewedByUserId } : {}),
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      questions: row.questions.map((question: any) => ({
        text: question.text,
        ...(question.explanation ? { explanation: question.explanation } : {}),
        ...(readMediaAsset(question.media) ? { media: readMediaAsset(question.media)! } : {}),
        ...(readMediaAsset(question.explanationMedia)
          ? { explanationMedia: readMediaAsset(question.explanationMedia)! }
          : {}),
        answerOptions: question.answerOptions.map((option: any) => ({ text: option.text, isCorrect: option.isCorrect })),
      })),
    };
  }

  private async mapQuestionSetListItem(row: any): Promise<AdminQuestionSetListItem> {
    return {
      ...(await this.mapContributionListItem(row)),
      sourceType: row.sourceType,
      isArchived: row.isArchived,
      attemptCount: row._count.examAttempts,
    };
  }

  private async mapQuestionSetDetail(row: any): Promise<AdminQuestionSetDetail> {
    return {
      ...(await this.mapContributionDetail(row)),
      sourceType: row.sourceType,
      isArchived: row.isArchived,
      attemptCount: row._count.examAttempts,
    };
  }

  private async mapUser(row: any): Promise<AdminUser> {
    const [attemptCount, contributionCount] = await Promise.all([
      this.prisma.examAttempt.count({ where: { userId: row.id } }),
      this.prisma.questionSet.count({ where: { createdByUserId: row.id, sourceType: 'community' } }),
    ]);
    return {
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      role: row.role,
      status: row.status,
      attemptCount,
      contributionCount,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }

  private async assertSubjectTopic(subjectId: string, topicId: string | null): Promise<void> {
    const subject = await this.prisma.subject.findUnique({ where: { id: subjectId } });
    if (subject === null) throw new AdminValidationError('Subject does not exist.');
    if (topicId === null) return;
    const topic = await this.prisma.topic.findFirst({ where: { id: topicId, subjectId } });
    if (topic === null) throw new AdminValidationError('Topic does not belong to the selected subject.');
  }

  private async assertSubjectNameAvailable(name: string, exceptId?: string): Promise<void> {
    const existing = await this.prisma.subject.findFirst({
      where: { name: { equals: name, mode: 'insensitive' }, ...(exceptId ? { id: { not: exceptId } } : {}) },
    });
    if (existing !== null) throw new AdminConflictError('A subject with this name already exists.');
  }

  private async assertTopicNameAvailable(subjectId: string, name: string, exceptId?: string): Promise<void> {
    const existing = await this.prisma.topic.findFirst({
      where: {
        subjectId,
        name: { equals: name, mode: 'insensitive' },
        ...(exceptId ? { id: { not: exceptId } } : {}),
      },
    });
    if (existing !== null) throw new AdminConflictError('A topic with this name already exists in this subject.');
  }
}

export function createPrismaAdminService(): PrismaAdminService {
  return new PrismaAdminService(getPrismaClient());
}

function mapSubject(row: any): AdminSubject {
  return {
    id: row.id,
    name: row.name,
    ...(row.description ? { description: row.description } : {}),
    isArchived: row.isArchived,
    topicCount: row._count.topics,
    questionSetCount: row._count.questionSets,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function mapTopic(row: any): AdminTopic {
  return {
    id: row.id,
    subjectId: row.subjectId,
    subjectName: row.subject.name,
    name: row.name,
    isArchived: row.isArchived,
    questionSetCount: row._count.questionSets,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function mapMedia(row: any): AdminMediaItem[] {
  const entries: AdminMediaItem[] = [];
  const questionMedia = readMediaAsset(row.media);
  const explanationMedia = readMediaAsset(row.explanationMedia);
  if (row.media !== null) entries.push(createMediaItem(row, 'question', questionMedia));
  if (row.explanationMedia !== null) entries.push(createMediaItem(row, 'explanation', explanationMedia));
  return entries;
}

function createMediaItem(row: any, usage: 'question' | 'explanation', media: ReturnType<typeof readMediaAsset>): AdminMediaItem {
  const fallback = { mediaType: 'image' as const, mediaUrl: '' };
  return {
    id: `${row.id}:${usage}`,
    media: media ?? fallback,
    usage,
    questionId: row.id,
    questionText: row.text,
    questionSetId: row.questionSet.id,
    questionSetTitle: row.questionSet.title,
    submissionStatus: row.questionSet.status,
    brokenReference: media === undefined || !media.mediaUrl.startsWith('/media/images/'),
  };
}
