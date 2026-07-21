import assert from 'node:assert/strict';
import test from 'node:test';

import { validateQuestionSetSubmission } from '../dist/services/questionSetSubmissionValidation.js';

const valid = {
  subjectId: 'subject_database',
  title: 'Media set',
  description: '',
  questions: [{
    text: 'Read the diagram',
    media: { mediaType: 'image', mediaUrl: '/media/images/123e4567-e89b-12d3-a456-426614174000.png' },
    answerOptions: [{ text: 'A', isCorrect: true }, { text: 'B', isCorrect: false }],
  }],
};

test('question submission accepts safe optional image metadata', () => {
  assert.deepEqual(validateQuestionSetSubmission(valid, { requireComplete: true }), []);
});

test('question submission rejects unsupported media and local paths', () => {
  const unsafe = structuredClone(valid);
  unsafe.questions[0].media = { mediaType: 'video', mediaUrl: 'file:///C:/private/video.mp4' };
  const errors = validateQuestionSetSubmission(unsafe, { requireComplete: true });
  assert.deepEqual(errors.map(({ path }) => path), [
    'questions[0].media.mediaType',
    'questions[0].media.mediaUrl',
  ]);
});
