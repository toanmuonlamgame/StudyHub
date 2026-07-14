import { PrismaClient } from '@prisma/client';

import {
  getCorrectAnswerOptionId,
  questions,
  questionSets,
  subjects,
  topics,
} from '../src/data/mockLearningData.js';
import { studyMaterials } from '../src/data/mockStudyMaterials.js';

const prisma = new PrismaClient();

async function seedSubjects() {
  for (const subject of subjects) {
    const data = {
      name: subject.name,
      school: subject.school ?? null,
      program: subject.program ?? null,
      major: subject.major ?? null,
      description: subject.description ?? null,
    };

    await prisma.subject.upsert({
      where: { id: subject.id },
      update: data,
      create: { id: subject.id, ...data },
    });
  }
}

async function seedTopics() {
  for (const topic of topics) {
    const data = {
      subjectId: topic.subjectId,
      name: topic.name,
    };

    await prisma.topic.upsert({
      where: { id: topic.id },
      update: data,
      create: { id: topic.id, ...data },
    });
  }
}

async function seedQuestionSets() {
  for (const questionSet of questionSets) {
    const data = {
      subjectId: questionSet.subjectId,
      topicId: questionSet.topicId ?? null,
      title: questionSet.title,
      description: questionSet.description,
    };

    await prisma.questionSet.upsert({
      where: { id: questionSet.id },
      update: data,
      create: { id: questionSet.id, ...data },
    });
  }
}

async function seedStudyMaterials() {
  for (const material of studyMaterials) {
    const data = {
      subjectId: material.subjectId,
      topicId: material.topicId ?? null,
      title: material.title,
      description: material.description,
      materialType: material.materialType,
      sourceType: material.sourceType,
      sourceUrl: material.sourceUrl ?? null,
      fileName: material.fileName ?? null,
      mimeType: material.mimeType ?? null,
      fileSizeBytes: material.fileSizeBytes ?? null,
      language: material.language ?? null,
      status: material.status,
      createdAt: new Date(material.createdAt),
      updatedAt: new Date(material.updatedAt),
    };

    await prisma.studyMaterial.upsert({
      where: { id: material.id },
      update: data,
      create: { id: material.id, ...data },
    });
  }
}

async function seedQuestionsAndAnswerOptions() {
  for (const questionSet of questionSets) {
    const questionSetQuestions = questions.filter(
      (question) => question.questionSetId === questionSet.id,
    );

    for (const [questionIndex, question] of questionSetQuestions.entries()) {
      const questionData = {
        questionSetId: question.questionSetId,
        text: question.text,
        position: questionIndex + 1,
      };

      await prisma.question.upsert({
        where: { id: question.id },
        update: questionData,
        create: { id: question.id, ...questionData },
      });

      const correctAnswerOptionId = getCorrectAnswerOptionId(question.id);
      if (correctAnswerOptionId === undefined) {
        throw new Error(`Missing answer key for question ${question.id}.`);
      }

      const answerKeyExists = question.answerOptions.some(
        (answerOption) => answerOption.id === correctAnswerOptionId,
      );
      if (!answerKeyExists) {
        throw new Error(
          `Answer key ${correctAnswerOptionId} is invalid for question ${question.id}.`,
        );
      }

      for (const [optionIndex, answerOption] of question.answerOptions.entries()) {
        const answerOptionData = {
          questionId: question.id,
          text: answerOption.text,
          position: optionIndex + 1,
          isCorrect: answerOption.id === correctAnswerOptionId,
        };

        await prisma.answerOption.upsert({
          where: { id: answerOption.id },
          update: answerOptionData,
          create: { id: answerOption.id, ...answerOptionData },
        });
      }
    }
  }
}

async function main() {
  await seedSubjects();
  await seedTopics();
  await seedQuestionSets();
  await seedStudyMaterials();
  await seedQuestionsAndAnswerOptions();
}

main()
  .catch((error: unknown) => {
    console.error('Prisma seed failed.', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
