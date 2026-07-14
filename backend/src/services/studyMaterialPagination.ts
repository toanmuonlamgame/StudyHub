import type {
  InternalStudyMaterial,
  StudyMaterialListItem,
} from '../types/learning.js';
import { InvalidLearningListQueryError } from './learningService.js';

interface StudyMaterialCursor {
  createdAt: string;
  id: string;
}

export function toStudyMaterialListItem(
  material: InternalStudyMaterial,
): StudyMaterialListItem {
  return {
    id: material.id,
    subjectId: material.subjectId,
    ...(material.topicId === undefined ? {} : { topicId: material.topicId }),
    title: material.title,
    description: material.description,
    materialType: material.materialType,
    ...(material.language === undefined ? {} : { language: material.language }),
    createdAt: material.createdAt,
  };
}

export function toPublicStudyMaterial(
  material: InternalStudyMaterial,
): Omit<InternalStudyMaterial, 'status'> {
  const { status: _status, ...publicMaterial } = material;
  return publicMaterial;
}

export function encodeStudyMaterialCursor(
  material: Pick<StudyMaterialListItem, 'createdAt' | 'id'>,
): string {
  return Buffer.from(
    JSON.stringify({ createdAt: material.createdAt, id: material.id }),
  ).toString('base64url');
}

export function decodeStudyMaterialCursor(cursor: string): StudyMaterialCursor {
  try {
    const value: unknown = JSON.parse(
      Buffer.from(cursor, 'base64url').toString('utf8'),
    );
    if (
      typeof value !== 'object' ||
      value === null ||
      !('createdAt' in value) ||
      !('id' in value) ||
      typeof value.createdAt !== 'string' ||
      typeof value.id !== 'string' ||
      value.id.length === 0 ||
      Number.isNaN(Date.parse(value.createdAt))
    ) {
      throw new Error('Invalid cursor payload.');
    }
    return { createdAt: value.createdAt, id: value.id };
  } catch {
    throw new InvalidLearningListQueryError('cursor is invalid.');
  }
}
