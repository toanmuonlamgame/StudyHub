import { createHash } from 'node:crypto';

import type { StudyMaterialSubmissionInput } from '../types/studyMaterialSubmission.js';

export function createStudyMaterialSubmissionFingerprint(
  input: StudyMaterialSubmissionInput,
): string {
  const normalized = {
    subjectId: input.subjectId.trim(),
    topicId: input.topicId?.trim() || null,
    title: input.title.trim(),
    description: input.description.trim(),
    materialType: input.materialType,
    sourceType: input.sourceType,
    sourceUrl: input.sourceUrl?.trim() || null,
    language: input.language?.trim().toLowerCase() || null,
  };
  return createHash('sha256').update(JSON.stringify(normalized)).digest('hex');
}
