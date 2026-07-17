import { createHash } from 'node:crypto';

import type { SaveExamAttemptInput } from '../types/learning.js';
import { InvalidQuizSubmissionError } from './learningService.js';

export function validateExamAttemptInput(
  input: SaveExamAttemptInput,
): Date | null {
  if (input.submissionId.trim().length === 0 || input.submissionId.length > 128) {
    throw new InvalidQuizSubmissionError(
      'submissionId must contain between 1 and 128 characters.',
    );
  }
  if (input.startedAt === undefined) {
    return null;
  }
  const startedAt = new Date(input.startedAt);
  if (Number.isNaN(startedAt.getTime())) {
    throw new InvalidQuizSubmissionError('startedAt must be a valid date.');
  }
  return startedAt;
}

export function createExamAttemptFingerprint(
  questionSetId: string,
  input: SaveExamAttemptInput,
  startedAt: Date | null,
): string {
  const selectedAnswers = Object.entries(
    input.selectedAnswerOptionIdsByQuestionId,
  ).sort(([leftQuestionId], [rightQuestionId]) =>
    leftQuestionId.localeCompare(rightQuestionId),
  );
  const canonicalRequest = JSON.stringify({
    questionSetId,
    startedAt: startedAt?.toISOString() ?? null,
    selectedAnswers,
  });
  return createHash('sha256').update(canonicalRequest).digest('hex');
}
