import type { SubmissionValidationFieldError } from '../types/questionSetSubmission.js';
import type { StudyMaterialSubmissionInput } from '../types/studyMaterialSubmission.js';

const materialTypes = new Set([
  'pdf',
  'slides',
  'notes',
  'document',
  'link',
  'other',
]);

export function validateStudyMaterialSubmission(
  input: StudyMaterialSubmissionInput,
): SubmissionValidationFieldError[] {
  const fields: SubmissionValidationFieldError[] = [];
  validateRequired(fields, 'subjectId', input.subjectId, 100);
  validateRequired(fields, 'title', input.title, 120);
  validateRequired(fields, 'description', input.description, 1000);

  if (!materialTypes.has(input.materialType)) {
    fields.push({ path: 'materialType', message: 'Material type is invalid.' });
  }
  if (input.sourceType !== 'externalLink') {
    fields.push({
      path: 'sourceType',
      message: 'Only external links are supported in this release.',
    });
  }

  const sourceUrl = input.sourceUrl?.trim() ?? '';
  if (sourceUrl.length === 0) {
    fields.push({ path: 'sourceUrl', message: 'Source URL is required.' });
  } else if (sourceUrl.length > 2048 || !isSafeWebUrl(sourceUrl)) {
    fields.push({
      path: 'sourceUrl',
      message: 'Source URL must be a valid HTTP or HTTPS URL.',
    });
  }

  if (input.topicId !== undefined && input.topicId.trim().length === 0) {
    fields.push({ path: 'topicId', message: 'Topic ID cannot be empty.' });
  }
  if (input.language !== undefined && input.language.trim().length > 12) {
    fields.push({ path: 'language', message: 'Language is too long.' });
  }
  return fields;
}

function validateRequired(
  fields: SubmissionValidationFieldError[],
  path: string,
  value: string,
  maximumLength: number,
): void {
  const normalized = value.trim();
  if (normalized.length === 0) {
    fields.push({ path, message: `${labelFor(path)} is required.` });
  } else if (normalized.length > maximumLength) {
    fields.push({
      path,
      message: `${labelFor(path)} must be ${maximumLength} characters or fewer.`,
    });
  }
}

function labelFor(path: string): string {
  return path === 'subjectId'
    ? 'Subject'
    : path[0]!.toUpperCase() + path.slice(1);
}

function isSafeWebUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return (url.protocol === 'http:' || url.protocol === 'https:') && url.hostname.length > 0;
  } catch {
    return false;
  }
}
