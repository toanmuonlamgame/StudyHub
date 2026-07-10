import type { Prisma } from '@prisma/client';

import type {
  Question,
  QuestionSet,
  Subject,
  Topic,
} from '../types/learning.js';

type QuestionSetWithCount = Prisma.QuestionSetGetPayload<{
  include: { _count: { select: { questions: true } } };
}>;

type QuestionWithAnswerOptions = Prisma.QuestionGetPayload<{
  include: { answerOptions: true };
}>;

export function mapSubject(subject: Prisma.SubjectGetPayload<object>): Subject {
  return {
    id: subject.id,
    name: subject.name,
    ...(subject.school === null ? {} : { school: subject.school }),
    ...(subject.program === null ? {} : { program: subject.program }),
    ...(subject.major === null ? {} : { major: subject.major }),
    ...(subject.description === null
      ? {}
      : { description: subject.description }),
  };
}

export function mapTopic(topic: Prisma.TopicGetPayload<object>): Topic {
  return {
    id: topic.id,
    subjectId: topic.subjectId,
    name: topic.name,
  };
}

export function mapQuestionSet(
  questionSet: QuestionSetWithCount,
): QuestionSet {
  return {
    id: questionSet.id,
    subjectId: questionSet.subjectId,
    ...(questionSet.topicId === null
      ? {}
      : { topicId: questionSet.topicId }),
    title: questionSet.title,
    description: questionSet.description,
    questionCount: questionSet._count.questions,
  };
}

export function mapQuestion(question: QuestionWithAnswerOptions): Question {
  return {
    id: question.id,
    questionSetId: question.questionSetId,
    text: question.text,
    answerOptions: question.answerOptions.map(({ id, text }) => ({ id, text })),
  };
}
