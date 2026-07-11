import type {
  QuestionSet,
  QuestionSetListItem,
} from '../types/learning.js';
import { InvalidLearningListQueryError } from './learningService.js';

export interface QuestionSetCursor {
  createdAt: string;
  id: string;
}

export function encodeQuestionSetCursor(
  cursor: QuestionSetCursor,
): string {
  return Buffer.from(
    JSON.stringify({ createdAt: cursor.createdAt, id: cursor.id }),
  ).toString('base64url');
}

export function decodeQuestionSetCursor(value: string): QuestionSetCursor {
  try {
    const decoded: unknown = JSON.parse(
      Buffer.from(value, 'base64url').toString('utf8'),
    );
    if (
      typeof decoded !== 'object' ||
      decoded === null ||
      !('createdAt' in decoded) ||
      !('id' in decoded) ||
      typeof decoded.createdAt !== 'string' ||
      Number.isNaN(Date.parse(decoded.createdAt)) ||
      typeof decoded.id !== 'string' ||
      decoded.id.length === 0
    ) {
      throw new Error('Invalid cursor fields.');
    }
    return { createdAt: decoded.createdAt, id: decoded.id };
  } catch {
    throw new InvalidLearningListQueryError('Invalid question set cursor.');
  }
}

export function createQuestionSetListItem(
  questionSet: QuestionSet,
  createdAt: Date,
): QuestionSetListItem {
  const questionCount = questionSet.questionCount;
  return {
    ...questionSet,
    estimatedMinutes: Math.max(1, Math.ceil(questionCount * 1.5)),
    difficulty:
      questionCount <= 5 ? 'easy' : questionCount <= 15 ? 'medium' : 'hard',
    createdAt: createdAt.toISOString(),
  };
}
