import {
  getCorrectAnswerOptionId,
  questionSets,
  questions,
  subjects,
  topics,
} from '../data/mockLearningData.js';
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
import type { QuestionSetModerationStatus } from '../types/questionSetSubmission.js';
import {
  AdminConflictError,
  AdminNotFoundError,
  type AdminService,
  AdminValidationError,
  createAdminPage,
  normalizeAdminName,
  normalizeRejectionReason,
} from './adminService.js';

type StoredSet = AdminQuestionSetDetail;

export class InMemoryAdminService implements AdminService {
  private readonly storedSubjects: AdminSubject[];
  private readonly storedTopics: AdminTopic[];
  private readonly storedSets: StoredSet[];
  private readonly users: AdminUser[];

  constructor() {
    const now = new Date().toISOString();
    this.storedSubjects = subjects.map((subject) => ({
      ...subject,
      isArchived: false,
      topicCount: topics.filter((topic) => topic.subjectId === subject.id).length,
      questionSetCount: questionSets.filter((set) => set.subjectId === subject.id).length,
      createdAt: now,
      updatedAt: now,
    }));
    this.storedTopics = topics.map((topic) => ({
      ...topic,
      subjectName: subjects.find((subject) => subject.id === topic.subjectId)?.name ?? '',
      isArchived: false,
      questionSetCount: questionSets.filter((set) => set.topicId === topic.id).length,
      createdAt: now,
      updatedAt: now,
    }));
    this.users = [
      {
        id: 'admin_1',
        email: 'admin@example.invalid',
        displayName: 'Development Admin',
        role: 'admin',
        status: 'active',
        attemptCount: 0,
        contributionCount: 1,
        createdAt: now,
        updatedAt: now,
      },
      {
        id: 'user_1',
        email: 'learner@example.invalid',
        displayName: 'Demo Learner',
        role: 'user',
        status: 'active',
        attemptCount: 0,
        contributionCount: 1,
        createdAt: now,
        updatedAt: now,
      },
    ];
    this.storedSets = questionSets.map((set) => this.createStoredSet(set, now));
    this.storedSets.push({
      id: 'submission_pending_demo',
      subjectId: subjects[0].id,
      subjectName: subjects[0].name,
      topicId: topics[0].id,
      topicName: topics[0].name,
      title: 'Community JavaScript Review',
      description: 'A pending contribution used by memory-mode admin tests.',
      status: 'pendingReview',
      sourceType: 'community',
      createdByUserId: 'user_1',
      contributor: { id: 'user_1', displayName: 'Demo Learner', email: 'learner@example.invalid' },
      submittedAt: now,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
      attemptCount: 0,
      questions: [
        {
          text: 'Which keyword creates a constant?',
          explanation: 'const prevents reassignment.',
          answerOptions: [
            { text: 'let', isCorrect: false },
            { text: 'const', isCorrect: true },
          ],
        },
      ],
    });
  }

  async getDashboard(): Promise<AdminDashboardSummary> {
    const community = this.storedSets.filter((set) => set.sourceType === 'community');
    return {
      totalUsers: this.users.length,
      totalQuestionSets: this.storedSets.length,
      pendingContributions: community.filter((set) => set.status === 'pendingReview').length,
      approvedContributions: community.filter((set) => set.status === 'published').length,
      rejectedContributions: community.filter((set) => set.status === 'rejected').length,
      totalAttempts: this.storedSets.reduce((sum, set) => sum + set.attemptCount, 0),
      recentContributions: community.slice(-5).reverse().map(toContributionItem),
    };
  }

  async listContributions(params: AdminContributionListParams): Promise<AdminPage<AdminContributionListItem>> {
    const items = this.storedSets
      .filter((set) => set.sourceType === 'community')
      .filter((set) => matchesSet(set, params));
    return page(items.map(toContributionItem), params.page, params.limit);
  }

  async getContribution(id: string): Promise<AdminContributionDetail | null> {
    const set = this.storedSets.find((item) => item.id === id && item.sourceType === 'community');
    return set ?? null;
  }

  async approveContribution(id: string, adminUserId: string): Promise<AdminContributionDetail> {
    return this.moderate(id, adminUserId, 'published');
  }

  async rejectContribution(id: string, adminUserId: string, reason: string): Promise<AdminContributionDetail> {
    return this.moderate(id, adminUserId, 'rejected', normalizeRejectionReason(reason));
  }

  async listQuestionSets(params: AdminQuestionSetListParams): Promise<AdminPage<AdminQuestionSetListItem>> {
    return page(this.storedSets.filter((set) => matchesSet(set, params)).map(toSetItem), params.page, params.limit);
  }

  async getQuestionSet(id: string): Promise<AdminQuestionSetDetail | null> {
    return this.storedSets.find((set) => set.id === id) ?? null;
  }

  async updateQuestionSet(id: string, input: UpdateAdminQuestionSetInput): Promise<AdminQuestionSetDetail> {
    const set = this.requireSet(id);
    const subjectId = input.subjectId ?? set.subjectId;
    const subject = this.storedSubjects.find((item) => item.id === subjectId);
    if (subject === undefined) throw new AdminValidationError('Subject does not exist.');
    const topicId = input.topicId === undefined ? set.topicId : input.topicId ?? undefined;
    const topic = topicId === undefined ? undefined : this.storedTopics.find((item) => item.id === topicId && item.subjectId === subjectId);
    if (topicId !== undefined && topic === undefined) throw new AdminValidationError('Topic does not belong to the selected subject.');
    Object.assign(set, {
      ...(input.title === undefined ? {} : { title: normalizeAdminName(input.title, 'Title') }),
      ...(input.description === undefined ? {} : { description: input.description.trim().slice(0, 2000) }),
      subjectId,
      subjectName: subject.name,
      topicId,
      topicName: topic?.name,
      ...(input.isArchived === undefined ? {} : { isArchived: input.isArchived }),
      updatedAt: new Date().toISOString(),
    });
    return set;
  }

  async listSubjects(): Promise<AdminSubject[]> { return [...this.storedSubjects]; }

  async createSubject(input: { name: string; description?: string }): Promise<AdminSubject> {
    const name = normalizeAdminName(input.name, 'Subject name');
    this.assertUniqueSubject(name);
    const now = new Date().toISOString();
    const subject: AdminSubject = {
      id: `subject_${Date.now()}`,
      name,
      ...(input.description?.trim() ? { description: input.description.trim() } : {}),
      isArchived: false,
      topicCount: 0,
      questionSetCount: 0,
      createdAt: now,
      updatedAt: now,
    };
    this.storedSubjects.push(subject);
    return subject;
  }

  async updateSubject(id: string, input: { name?: string; description?: string | null; isArchived?: boolean }): Promise<AdminSubject> {
    const subject = this.storedSubjects.find((item) => item.id === id);
    if (subject === undefined) throw new AdminNotFoundError('Subject not found.');
    if (input.name !== undefined) {
      const name = normalizeAdminName(input.name, 'Subject name');
      this.assertUniqueSubject(name, id);
      subject.name = name;
    }
    if (input.description !== undefined) subject.description = input.description?.trim() || undefined;
    if (input.isArchived !== undefined) subject.isArchived = input.isArchived;
    subject.updatedAt = new Date().toISOString();
    return subject;
  }

  async listTopics(subjectId?: string): Promise<AdminTopic[]> {
    return this.storedTopics.filter((topic) => subjectId === undefined || topic.subjectId === subjectId);
  }

  async createTopic(input: { subjectId: string; name: string }): Promise<AdminTopic> {
    const subject = this.storedSubjects.find((item) => item.id === input.subjectId);
    if (subject === undefined) throw new AdminValidationError('Subject does not exist.');
    const name = normalizeAdminName(input.name, 'Topic name');
    this.assertUniqueTopic(input.subjectId, name);
    const now = new Date().toISOString();
    const topic: AdminTopic = {
      id: `topic_${Date.now()}`,
      subjectId: subject.id,
      subjectName: subject.name,
      name,
      isArchived: false,
      questionSetCount: 0,
      createdAt: now,
      updatedAt: now,
    };
    this.storedTopics.push(topic);
    subject.topicCount += 1;
    return topic;
  }

  async updateTopic(id: string, input: { subjectId?: string; name?: string; isArchived?: boolean }): Promise<AdminTopic> {
    const topic = this.storedTopics.find((item) => item.id === id);
    if (topic === undefined) throw new AdminNotFoundError('Topic not found.');
    const subjectId = input.subjectId ?? topic.subjectId;
    const subject = this.storedSubjects.find((item) => item.id === subjectId);
    if (subject === undefined) throw new AdminValidationError('Subject does not exist.');
    const name = input.name === undefined ? topic.name : normalizeAdminName(input.name, 'Topic name');
    this.assertUniqueTopic(subjectId, name, id);
    Object.assign(topic, {
      subjectId,
      subjectName: subject.name,
      name,
      ...(input.isArchived === undefined ? {} : { isArchived: input.isArchived }),
      updatedAt: new Date().toISOString(),
    });
    return topic;
  }

  async listUsers(params: AdminUserListParams): Promise<AdminPage<AdminUser>> {
    const q = params.q?.trim().toLowerCase();
    const users = this.users.filter((user) =>
      (params.role === undefined || user.role === params.role) &&
      (params.status === undefined || user.status === params.status) &&
      (q === undefined || user.email.toLowerCase().includes(q) || user.displayName.toLowerCase().includes(q))
    );
    return page(users, params.page, params.limit);
  }

  async getUser(id: string): Promise<AdminUser | null> { return this.users.find((user) => user.id === id) ?? null; }

  async updateUser(id: string, actorId: string, input: { role?: 'user' | 'admin'; status?: 'active' | 'disabled' }): Promise<AdminUser> {
    const user = this.users.find((item) => item.id === id);
    if (user === undefined) throw new AdminNotFoundError('User not found.');
    if (id === actorId && (input.role === 'user' || input.status === 'disabled')) {
      throw new AdminConflictError('You cannot disable or demote your own admin account.');
    }
    Object.assign(user, input, { updatedAt: new Date().toISOString() });
    return user;
  }

  async listMedia(params: AdminMediaListParams): Promise<AdminPage<AdminMediaItem>> {
    const all = this.storedSets.flatMap((set) => set.questions.flatMap((question, index) => {
      const result: AdminMediaItem[] = [];
      if (question.media) result.push(mediaItem(set, question.text, index, 'question', question.media));
      if (question.explanationMedia) result.push(mediaItem(set, question.text, index, 'explanation', question.explanationMedia));
      return result;
    }));
    const q = params.q?.trim().toLowerCase();
    const filtered = all.filter((item) =>
      (params.broken === undefined || item.brokenReference === params.broken) &&
      (q === undefined || item.questionSetTitle.toLowerCase().includes(q) || item.questionText.toLowerCase().includes(q)),
    );
    return page(filtered, params.page, params.limit);
  }

  private moderate(id: string, adminUserId: string, status: 'published' | 'rejected', reason?: string): AdminContributionDetail {
    const set = this.requireSet(id);
    if (set.sourceType !== 'community' || set.status !== 'pendingReview') {
      throw new AdminConflictError('Contribution is no longer pending review.');
    }
    const now = new Date().toISOString();
    set.status = status;
    set.reviewedAt = now;
    set.reviewedByUserId = adminUserId;
    set.rejectionReason = reason;
    if (status === 'published') set.publishedAt = now;
    return set;
  }

  private requireSet(id: string): StoredSet {
    const set = this.storedSets.find((item) => item.id === id);
    if (set === undefined) throw new AdminNotFoundError('Question set not found.');
    return set;
  }

  private assertUniqueSubject(name: string, exceptId?: string): void {
    if (this.storedSubjects.some((item) => item.id !== exceptId && item.name.toLowerCase() === name.toLowerCase())) {
      throw new AdminConflictError('A subject with this name already exists.');
    }
  }

  private assertUniqueTopic(subjectId: string, name: string, exceptId?: string): void {
    if (this.storedTopics.some((item) => item.id !== exceptId && item.subjectId === subjectId && item.name.toLowerCase() === name.toLowerCase())) {
      throw new AdminConflictError('A topic with this name already exists in this subject.');
    }
  }

  private createStoredSet(set: (typeof questionSets)[number], now: string): StoredSet {
    const subject = subjects.find((item) => item.id === set.subjectId)!;
    const topic = topics.find((item) => item.id === set.topicId);
    return {
      ...set,
      subjectName: subject.name,
      ...(topic ? { topicName: topic.name } : {}),
      status: 'published',
      sourceType: 'system',
      isArchived: false,
      attemptCount: 0,
      createdAt: now,
      updatedAt: now,
      questions: questions.filter((question) => question.questionSetId === set.id).map((question) => ({
        text: question.text,
        answerOptions: question.answerOptions.map((option) => ({
          text: option.text,
          isCorrect: option.id === getCorrectAnswerOptionId(question.id),
        })),
      })),
    };
  }
}

function matchesSet(set: StoredSet, params: AdminQuestionSetListParams): boolean {
  const q = params.q?.trim().toLowerCase();
  return (params.status === undefined || set.status === params.status) &&
    (params.subjectId === undefined || set.subjectId === params.subjectId) &&
    (params.topicId === undefined || set.topicId === params.topicId) &&
    (params.archived === undefined || set.isArchived === params.archived) &&
    (q === undefined || set.title.toLowerCase().includes(q));
}

function toContributionItem(set: StoredSet): AdminContributionListItem {
  return {
    id: set.id,
    title: set.title,
    status: set.status,
    subjectId: set.subjectId,
    subjectName: set.subjectName,
    ...(set.topicId ? { topicId: set.topicId, topicName: set.topicName } : {}),
    ...(set.createdByUserId ? { contributorId: set.createdByUserId, contributorName: set.contributor?.displayName } : {}),
    questionCount: set.questions.length,
    ...(set.submittedAt ? { submittedAt: set.submittedAt } : {}),
    ...(set.reviewedAt ? { reviewedAt: set.reviewedAt } : {}),
    ...(set.rejectionReason ? { rejectionReason: set.rejectionReason } : {}),
    updatedAt: set.updatedAt,
  };
}

function toSetItem(set: StoredSet): AdminQuestionSetListItem {
  return { ...toContributionItem(set), sourceType: set.sourceType, isArchived: set.isArchived, attemptCount: set.attemptCount };
}

function page<T>(items: T[], pageNumber: number, limit: number): AdminPage<T> {
  return createAdminPage(items.slice((pageNumber - 1) * limit, pageNumber * limit), pageNumber, limit, items.length);
}

function mediaItem(set: StoredSet, questionText: string, index: number, usage: 'question' | 'explanation', media: NonNullable<StoredSet['questions'][number]['media']>): AdminMediaItem {
  return {
    id: `${set.id}:${index}:${usage}`,
    media,
    usage,
    questionId: `${set.id}:${index}`,
    questionText,
    questionSetId: set.id,
    questionSetTitle: set.title,
    submissionStatus: set.status as QuestionSetModerationStatus,
    brokenReference: !media.mediaUrl.startsWith('/media/images/'),
  };
}
