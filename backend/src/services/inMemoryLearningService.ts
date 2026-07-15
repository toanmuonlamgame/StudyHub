import {
  getCorrectAnswerOptionId,
  questions,
  questionSets,
  subjects,
  topics,
} from '../data/mockLearningData.js';
import { studyMaterials } from '../data/mockStudyMaterials.js';
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
import type {
  QuestionSetSubmission,
  QuestionSetSubmissionInput,
} from '../types/questionSetSubmission.js';
import {
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
  toPublicStudyMaterial,
  toStudyMaterialListItem,
} from './studyMaterialPagination.js';

const questionSetCreatedAtById = new Map(
  questionSets.map((questionSet, index) => [
    questionSet.id,
    new Date(Date.UTC(2026, 0, index + 1)),
  ]),
);

export class InMemoryLearningService implements LearningService {
  private readonly submissions = new Map<string, QuestionSetSubmission>();
  private nextSubmissionNumber = 1;

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
    input: QuestionSetSubmissionInput,
  ): Promise<QuestionSetSubmission> {
    this.assertValidSubmission(input, true);
    this.validateSubmissionReferences(input);
    const now = new Date().toISOString();
    const submission: QuestionSetSubmission = {
      ...cloneSubmissionInput(input),
      id: `submission_${this.nextSubmissionNumber++}`,
      status: 'pendingReview',
      sourceType: 'community',
      submittedAt: now,
      createdAt: now,
      updatedAt: now,
    };
    this.submissions.set(submission.id, submission);
    return cloneSubmission(submission);
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
