import { createHash } from 'node:crypto';

import type { QuestionSetSubmissionInput } from '../types/questionSetSubmission.js';

export function createQuestionSetSubmissionFingerprint(
  input: QuestionSetSubmissionInput,
): string {
  const canonicalInput = JSON.stringify({
    subjectId: input.subjectId.trim(),
    topicId: input.topicId?.trim() || null,
    title: input.title.trim(),
    description: input.description.trim(),
    questions: input.questions.map((question) => ({
      text: question.text.trim(),
      explanation: question.explanation?.trim() || null,
      answerOptions: question.answerOptions.map((option) => ({
        text: option.text.trim(),
        isCorrect: option.isCorrect,
      })),
    })),
  });
  return createHash('sha256').update(canonicalInput).digest('hex');
}
