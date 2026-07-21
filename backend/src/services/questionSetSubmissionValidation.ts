import type {
  QuestionSetSubmissionInput,
  SubmissionValidationFieldError,
} from '../types/questionSetSubmission.js';

const TITLE_MAX = 160;
const DESCRIPTION_MAX = 2000;
const QUESTION_MAX = 2000;
const EXPLANATION_MAX = 4000;
const ANSWER_MAX = 1000;
const MEDIA_ALT_TEXT_MAX = 500;
export const QUESTION_COUNT_MAX = 50;
export const ANSWER_OPTION_COUNT_MAX = 8;

export function validateQuestionSetSubmission(
  input: QuestionSetSubmissionInput,
  options: { requireComplete: boolean },
): SubmissionValidationFieldError[] {
  const fields: SubmissionValidationFieldError[] = [];
  requiredText(fields, 'subjectId', input.subjectId, 120);
  requiredText(fields, 'title', input.title, TITLE_MAX);
  maximumText(fields, 'description', input.description, DESCRIPTION_MAX);

  if (options.requireComplete && input.questions.length === 0) {
    fields.push({
      path: 'questions',
      message: 'At least one question is required before submission.',
    });
  }
  if (input.questions.length > QUESTION_COUNT_MAX) {
    fields.push({
      path: 'questions',
      message: `No more than ${QUESTION_COUNT_MAX} questions are allowed.`,
    });
  }

  input.questions.forEach((question, questionIndex) => {
    const questionPath = `questions[${questionIndex}]`;
    requiredText(fields, `${questionPath}.text`, question.text, QUESTION_MAX);
    maximumText(
      fields,
      `${questionPath}.explanation`,
      question.explanation ?? '',
      EXPLANATION_MAX,
    );
    validateMedia(fields, `${questionPath}.media`, question.media);
    validateMedia(
      fields,
      `${questionPath}.explanationMedia`,
      question.explanationMedia,
    );

    if (options.requireComplete && question.answerOptions.length < 2) {
      fields.push({
        path: `${questionPath}.answerOptions`,
        message: 'At least two answer options are required.',
      });
    }
    if (question.answerOptions.length > ANSWER_OPTION_COUNT_MAX) {
      fields.push({
        path: `${questionPath}.answerOptions`,
        message: `No more than ${ANSWER_OPTION_COUNT_MAX} answer options are allowed.`,
      });
    }

    const normalizedOptions = new Set<string>();
    question.answerOptions.forEach((option, optionIndex) => {
      const optionPath = `${questionPath}.answerOptions[${optionIndex}].text`;
      requiredText(fields, optionPath, option.text, ANSWER_MAX);
      const normalized = option.text.trim().toLowerCase();
      if (normalized.length > 0) {
        if (normalizedOptions.has(normalized)) {
          fields.push({
            path: optionPath,
            message: 'Answer options must be unique within a question.',
          });
        }
        normalizedOptions.add(normalized);
      }
    });

    if (
      options.requireComplete &&
      question.answerOptions.filter(({ isCorrect }) => isCorrect).length !== 1
    ) {
      fields.push({
        path: `${questionPath}.answerOptions`,
        message: 'Exactly one answer must be correct.',
      });
    }
  });

  return fields;
}

function validateMedia(
  fields: SubmissionValidationFieldError[],
  path: string,
  media: QuestionSetSubmissionInput['questions'][number]['media'],
): void {
  if (media === undefined) return;
  if (media.mediaType !== 'image') {
    fields.push({ path: `${path}.mediaType`, message: 'Only image media is supported.' });
  }
  if (!/^\/media\/images\/[a-zA-Z0-9-]+\.(?:jpe?g|png|webp)$/.test(media.mediaUrl)) {
    fields.push({ path: `${path}.mediaUrl`, message: 'Media URL is invalid.' });
  }
  if (media.thumbnailUrl !== undefined &&
      !/^\/media\/images\/[a-zA-Z0-9-]+\.(?:jpe?g|png|webp)$/.test(media.thumbnailUrl)) {
    fields.push({ path: `${path}.thumbnailUrl`, message: 'Thumbnail URL is invalid.' });
  }
  maximumText(fields, `${path}.altText`, media.altText ?? '', MEDIA_ALT_TEXT_MAX);
  for (const [name, value] of [['width', media.width], ['height', media.height]] as const) {
    if (value !== undefined && (!Number.isInteger(value) || value < 1 || value > 10000)) {
      fields.push({ path: `${path}.${name}`, message: 'Must be an integer from 1 to 10000.' });
    }
  }
}

function requiredText(
  fields: SubmissionValidationFieldError[],
  path: string,
  value: string,
  maximum: number,
): void {
  if (value.trim().length === 0) {
    fields.push({ path, message: 'This field is required.' });
    return;
  }
  maximumText(fields, path, value, maximum);
}

function maximumText(
  fields: SubmissionValidationFieldError[],
  path: string,
  value: string,
  maximum: number,
): void {
  if (value.length > maximum) {
    fields.push({ path, message: `Must be ${maximum} characters or fewer.` });
  }
}
