import {
  getCorrectAnswerOptionId,
  getQuestionExplanation,
  questions,
  questionSets,
  subjects,
  topics,
} from '../data/mockLearningData.js';
import { studyMaterials } from '../data/mockStudyMaterials.js';
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
  CreateQuestionSetSubmissionOutcome,
  QuestionSetSubmissionInput,
} from '../types/questionSetSubmission.js';
import {
  InvalidQuizSubmissionError,
  ExamAttemptIdempotencyConflictError,
  LearningDataIntegrityError,
  LearningResourceNotFoundError,
  QuestionSetSubmissionStateError,
  QuestionSetSubmissionIdempotencyConflictError,
  QuestionSetSubmissionValidationError,
  type LearningService,
} from './learningService.js';
import { validateQuestionSetSubmission } from './questionSetSubmissionValidation.js';
import { createQuestionSetSubmissionFingerprint } from './questionSetSubmissionIdempotency.js';
import {
  createQuestionSetListItem,
  decodeQuestionSetCursor,
  encodeQuestionSetCursor,
} from './questionSetPagination.js';
import {
  decodeStudyMaterialCursor,
  encodeStudyMaterialCursor,
  toPublicStudyMaterial,
  toStudyMaterialListItem,
} from './studyMaterialPagination.js';
import { calculateRoundedPercentage } from './quizScoring.js';
import {
  createExamAttemptFingerprint,
  validateExamAttemptInput,
} from './examAttemptValidation.js';

const questionSetCreatedAtById = new Map(
  questionSets.map((questionSet, index) => [
    questionSet.id,
    new Date(Date.UTC(2026, 0, index + 1)),
  ]),
);

export class InMemoryLearningService implements LearningService {
  private readonly submissions = new Map<string, QuestionSetSubmission>();
  private readonly atomicSubmissions = new Map<
    string,
    { userId: string; fingerprint: string; submissionId: string }
  >();
  private readonly examAttempts = new Map<string, StoredExamAttempt>();
  private nextSubmissionNumber = 1;
  private nextAttemptNumber = 1;

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

  async listQuestionSets(
    params: ListQuestionSetsParams,
  ): Promise<PaginatedQuestionSets> {
    const search = params.q?.trim().toLocaleLowerCase();
    const cursor =
      params.cursor === undefined
        ? undefined
        : decodeQuestionSetCursor(params.cursor);

    const filteredItems = questionSets
      .map((questionSet) =>
        createQuestionSetListItem(
          questionSet,
          questionSetCreatedAtById.get(questionSet.id)!,
        ),
      )
      .filter(
        (questionSet) =>
          (params.subjectId === undefined ||
            questionSet.subjectId === params.subjectId) &&
          (params.topicId === undefined ||
            questionSet.topicId === params.topicId) &&
          (search === undefined ||
            search.length === 0 ||
            questionSet.title.toLocaleLowerCase().includes(search)),
      )
      .sort(
        (left, right) =>
          right.createdAt.localeCompare(left.createdAt) ||
          right.id.localeCompare(left.id),
      )
      .filter(
        (questionSet) =>
          cursor === undefined ||
          questionSet.createdAt < cursor.createdAt ||
          (questionSet.createdAt === cursor.createdAt &&
            questionSet.id < cursor.id),
      );

    const items = filteredItems.slice(0, params.limit);
    const hasMore = filteredItems.length > params.limit;
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
    return questionSets.find(({ id }) => id === questionSetId) ?? null;
  }

  async listStudyMaterials(
    params: ListStudyMaterialsParams,
  ): Promise<PaginatedStudyMaterials> {
    const search = params.q?.trim().toLocaleLowerCase();
    const cursor =
      params.cursor === undefined
        ? undefined
        : decodeStudyMaterialCursor(params.cursor);
    const filteredItems = studyMaterials
      .filter(({ status }) => status === 'published')
      .filter(
        (material) =>
          (params.subjectId === undefined ||
            material.subjectId === params.subjectId) &&
          (params.topicId === undefined ||
            material.topicId === params.topicId) &&
          (params.materialType === undefined ||
            material.materialType === params.materialType) &&
          (params.language === undefined ||
            material.language === params.language) &&
          (search === undefined ||
            search.length === 0 ||
            material.title.toLocaleLowerCase().includes(search) ||
            material.description.toLocaleLowerCase().includes(search)),
      )
      .map(toStudyMaterialListItem)
      .sort(
        (left, right) =>
          right.createdAt.localeCompare(left.createdAt) ||
          right.id.localeCompare(left.id),
      )
      .filter(
        (material) =>
          cursor === undefined ||
          material.createdAt < cursor.createdAt ||
          (material.createdAt === cursor.createdAt && material.id < cursor.id),
      );

    const items = filteredItems.slice(0, params.limit);
    const hasMore = filteredItems.length > params.limit;
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
    const material = studyMaterials.find(
      ({ id, status }) => id === materialId && status === 'published',
    );
    return material === undefined ? null : toPublicStudyMaterial(material);
  }

  async getQuestionsByQuestionSetId(
    questionSetId: string,
  ): Promise<Question[]> {
    this.requireQuestionSet(questionSetId);
    return questions.filter(
      (question) => question.questionSetId === questionSetId,
    );
  }

  async checkAnswer(
    questionId: string,
    selectedAnswerOptionId: string,
  ): Promise<AnswerCheckResult> {
    const question = questions.find(({ id }) => id === questionId);
    if (question === undefined) {
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

    const correctAnswerOptionId = getCorrectAnswerOptionId(questionId);
    if (correctAnswerOptionId === undefined) {
      throw new LearningDataIntegrityError(
        `Answer key is missing for question ${questionId}.`,
      );
    }

    const correctAnswer = question.answerOptions.find(
      ({ id }) => id === correctAnswerOptionId,
    );
    if (correctAnswer === undefined) {
      throw new LearningDataIntegrityError(
        `Answer key is invalid for question ${questionId}.`,
      );
    }

    return {
      questionId,
      selectedAnswerOptionId: selectedAnswer.id,
      selectedAnswerText: selectedAnswer.text,
      correctAnswerOptionId: correctAnswer.id,
      correctAnswerText: correctAnswer.text,
      isCorrect: selectedAnswer.id === correctAnswer.id,
      explanation: getQuestionExplanation(questionId) ?? null,
    };
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
        const selectedAnswer = selectedAnswerOptionId
          ? question.answerOptions.find(({ id }) => id === selectedAnswerOptionId)
          : undefined;
        if (selectedAnswerOptionId !== undefined && selectedAnswer === undefined) {
          throw new InvalidQuizSubmissionError(
            `Answer option ${selectedAnswerOptionId} does not belong to question ${question.id}.`,
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
          answerOptions: question.answerOptions.map(({ id, text }) => ({ id, text })),
          selectedAnswerOptionId: selectedAnswer?.id ?? null,
          selectedAnswerText: selectedAnswer?.text ?? null,
          correctAnswerOptionId: correctAnswer.id,
          correctAnswerText: correctAnswer.text,
          isCorrect: selectedAnswer?.id === correctAnswer.id,
          explanation: getQuestionExplanation(question.id) ?? null,
        };
      },
    );

    const correctAnswers = answerReviews.filter(
      ({ isCorrect }) => isCorrect,
    ).length;
    const totalQuestions = questionSetQuestions.length;
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
    const parsedStartedAt = validateExamAttemptInput(input);
    const requestFingerprint = createExamAttemptFingerprint(
      questionSetId,
      input,
      parsedStartedAt,
    );
    const idempotencyKey = `${userId}\u0000${input.submissionId}`;
    const existing = this.examAttempts.get(idempotencyKey);
    if (existing !== undefined) {
      if (existing.requestFingerprint !== requestFingerprint) {
        throw new ExamAttemptIdempotencyConflictError(
          'Submission ID was already used with different attempt data.',
        );
      }
      return { attempt: cloneExamAttempt(existing.attempt), created: false };
    }

    const result = await this.submitQuiz(
      questionSetId,
      input.selectedAnswerOptionIdsByQuestionId,
    );
    const completedAt = new Date().toISOString();
    const startedAt = parsedStartedAt?.toISOString() ?? null;
    const attempt: ExamAttemptDetail = {
      id: `attempt_${this.nextAttemptNumber++}`,
      questionSetId: result.questionSetId,
      questionSetTitle: result.questionSetTitle,
      startedAt,
      completedAt,
      totalQuestions: result.totalQuestions,
      correctAnswers: result.correctAnswers,
      wrongAnswers: result.wrongAnswers,
      unansweredAnswers: result.unansweredAnswers,
      percentageScore: result.percentageScore,
      result: cloneQuizResult(result),
    };
    this.examAttempts.set(idempotencyKey, {
      userId,
      requestFingerprint,
      attempt,
    });
    return { attempt: cloneExamAttempt(attempt), created: true };
  }

  async listExamAttempts(userId: string): Promise<ExamAttemptSummary[]> {
    return [...this.examAttempts.values()]
      .filter((stored) => stored.userId === userId)
      .map(({ attempt }) => toAttemptSummary(attempt))
      .sort(
        (left, right) =>
          right.completedAt.localeCompare(left.completedAt) ||
          right.id.localeCompare(left.id),
      )
      .slice(0, 100);
  }

  async getExamAttempt(
    userId: string,
    attemptId: string,
  ): Promise<ExamAttemptDetail | null> {
    const stored = [...this.examAttempts.values()].find(
      ({ userId: ownerId, attempt }) =>
        ownerId === userId && attempt.id === attemptId,
    );
    return stored === undefined ? null : cloneExamAttempt(stored.attempt);
  }

  async createQuestionSetSubmission(
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    this.assertValidSubmission(input, false);
    this.validateSubmissionReferences(input);
    const now = new Date().toISOString();
    const submission: QuestionSetSubmission = {
      ...cloneSubmissionInput(input),
      id: `submission_${this.nextSubmissionNumber++}`,
      status: 'draft',
      sourceType: 'community',
      createdAt: now,
      updatedAt: now,
    };
    this.submissions.set(submission.id, submission);
    return cloneSubmission(submission);
  }

  async createQuestionSetSubmissionForReview(
    userId: string,
    clientSubmissionId: string,
    input: QuestionSetSubmissionInput,
  ): Promise<CreateQuestionSetSubmissionOutcome> {
    this.assertValidSubmission(input, true);
    this.validateSubmissionReferences(input);
    const fingerprint = createQuestionSetSubmissionFingerprint(input);
    const existing = this.atomicSubmissions.get(clientSubmissionId);
    if (existing !== undefined) {
      if (existing.userId !== userId || existing.fingerprint !== fingerprint) {
        throw new QuestionSetSubmissionIdempotencyConflictError(
          'Submission ID was already used with different contribution data.',
        );
      }
      return {
        submission: cloneSubmission(
          this.requireSubmission(existing.submissionId),
        ),
        created: false,
      };
    }
    const now = new Date().toISOString();
    const submission: QuestionSetSubmission = {
      ...cloneSubmissionInput(input),
      id: `submission_${this.nextSubmissionNumber++}`,
      status: 'pendingReview',
      sourceType: 'community',
      createdByUserId: userId,
      submittedAt: now,
      createdAt: now,
      updatedAt: now,
    };
    this.submissions.set(submission.id, submission);
    this.atomicSubmissions.set(clientSubmissionId, {
      userId,
      fingerprint,
      submissionId: submission.id,
    });
    return { submission: cloneSubmission(submission), created: true };
  }

  async updateQuestionSetSubmission(
    submissionId: string,
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    const current = this.requireSubmission(submissionId);
    if (current.status !== 'draft') {
      throw new QuestionSetSubmissionStateError(
        'Only draft submissions can be edited.',
      );
    }
    this.assertValidSubmission(input, false);
    this.validateSubmissionReferences(input);
    const updated: QuestionSetSubmission = {
      ...current,
      ...cloneSubmissionInput(input),
      updatedAt: new Date().toISOString(),
    };
    this.submissions.set(submissionId, updated);
    return cloneSubmission(updated);
  }

  async getQuestionSetSubmission(
    submissionId: string,
  ): Promise<QuestionSetSubmission | null> {
    const submission = this.submissions.get(submissionId);
    return submission === undefined ? null : cloneSubmission(submission);
  }

  async submitQuestionSetForReview(
    submissionId: string,
  ): Promise<QuestionSetSubmission> {
    const current = this.requireSubmission(submissionId);
    if (current.status !== 'draft') {
      throw new QuestionSetSubmissionStateError(
        'Only draft submissions can be submitted for review.',
      );
    }
    this.validateSubmissionReferences(current);
    this.assertValidSubmission(current, true);
    const now = new Date().toISOString();
    const submitted: QuestionSetSubmission = {
      ...current,
      status: 'pendingReview',
      submittedAt: now,
      updatedAt: now,
    };
    this.submissions.set(submissionId, submitted);
    return cloneSubmission(submitted);
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

  private validateSubmissionReferences(input: QuestionSetSubmissionInput): void {
    const subject = subjects.find(({ id }) => id === input.subjectId);
    if (subject === undefined) {
      throw new QuestionSetSubmissionValidationError([
        { path: 'subjectId', message: 'Subject does not exist.' },
      ]);
    }
    if (input.topicId !== undefined) {
      const topic = topics.find(({ id }) => id === input.topicId);
      if (topic === undefined || topic.subjectId !== input.subjectId) {
        throw new QuestionSetSubmissionValidationError([
          {
            path: 'topicId',
            message: 'Topic must belong to the selected subject.',
          },
        ]);
      }
    }
  }

  private requireSubmission(submissionId: string): QuestionSetSubmission {
    const submission = this.submissions.get(submissionId);
    if (submission === undefined) {
      throw new LearningResourceNotFoundError('Submission not found.');
    }
    return submission;
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

interface StoredExamAttempt {
  userId: string;
  requestFingerprint: string;
  attempt: ExamAttemptDetail;
}

function toAttemptSummary(attempt: ExamAttemptDetail): ExamAttemptSummary {
  const { result: _result, ...summary } = attempt;
  return { ...summary };
}

function cloneQuizResult(result: QuizResult): QuizResult {
  return {
    ...result,
    answerReviews: result.answerReviews.map((review) => ({
      ...review,
      answerOptions: review.answerOptions.map((option) => ({ ...option })),
    })),
  };
}

function cloneExamAttempt(attempt: ExamAttemptDetail): ExamAttemptDetail {
  return { ...attempt, result: cloneQuizResult(attempt.result) };
}

function cloneSubmissionInput(
  input: QuestionSetSubmissionInput,
): QuestionSetSubmissionInput {
  return {
    subjectId: input.subjectId,
    ...(input.topicId === undefined ? {} : { topicId: input.topicId }),
    title: input.title.trim(),
    description: input.description.trim(),
    questions: input.questions.map((question) => ({
      text: question.text.trim(),
      ...(question.explanation?.trim()
        ? { explanation: question.explanation.trim() }
        : {}),
      answerOptions: question.answerOptions.map((option) => ({
        text: option.text.trim(),
        isCorrect: option.isCorrect,
      })),
    })),
  };
}

function cloneSubmission(
  submission: QuestionSetSubmission,
): QuestionSetSubmission {
  return { ...submission, ...cloneSubmissionInput(submission) };
}
