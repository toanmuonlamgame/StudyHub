import { randomUUID } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import type { MediaAsset } from '../types/learning.js';

export const mediaUploadMaxBytes = 5 * 1024 * 1024;

export interface StoredMediaFile {
  bytes: Buffer;
  mimeType: string;
}

export interface MediaStorage {
  saveImage(input: { bytes: Buffer; mimeType: string; altText?: string }): Promise<MediaAsset>;
  readImage(fileName: string): Promise<StoredMediaFile | null>;
}

export class MediaUploadError extends Error {
  constructor(message: string, public readonly statusCode: 400 | 413 = 400) {
    super(message);
  }
}

export class LocalMediaStorage implements MediaStorage {
  constructor(
    private readonly rootDirectory = path.resolve(
      path.dirname(fileURLToPath(import.meta.url)),
      '..',
      '..',
      'uploads',
      'images',
    ),
  ) {}

  async saveImage(input: { bytes: Buffer; mimeType: string; altText?: string }): Promise<MediaAsset> {
    if (input.bytes.length === 0) throw new MediaUploadError('Image file is empty.');
    if (input.bytes.length > mediaUploadMaxBytes) {
      throw new MediaUploadError('Image must be 5 MiB or smaller.', 413);
    }
    const detected = detectImage(input.bytes);
    const suppliedMime = input.mimeType.toLowerCase();
    if (detected === null ||
        (suppliedMime !== 'application/octet-stream' && detected.mimeType !== suppliedMime)) {
      throw new MediaUploadError('Only valid JPEG, PNG, or WebP images are supported.');
    }
    const fileName = `${randomUUID()}.${detected.extension}`;
    await mkdir(this.rootDirectory, { recursive: true });
    await writeFile(path.join(this.rootDirectory, fileName), input.bytes, { flag: 'wx' });
    return {
      mediaType: 'image',
      mediaUrl: `/media/images/${fileName}`,
      ...(input.altText?.trim() ? { altText: input.altText.trim().slice(0, 500) } : {}),
    };
  }

  async readImage(fileName: string): Promise<StoredMediaFile | null> {
    if (!/^[a-f0-9-]+\.(?:jpg|png|webp)$/.test(fileName)) return null;
    try {
      const bytes = await readFile(path.join(this.rootDirectory, fileName));
      const detected = detectImage(bytes);
      return detected === null ? null : { bytes, mimeType: detected.mimeType };
    } catch (error) {
      if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'ENOENT') return null;
      throw error;
    }
  }
}

function detectImage(bytes: Buffer): { mimeType: string; extension: 'jpg' | 'png' | 'webp' } | null {
  if (bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
    return { mimeType: 'image/jpeg', extension: 'jpg' };
  }
  if (bytes.length >= 8 && bytes.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))) {
    return { mimeType: 'image/png', extension: 'png' };
  }
  if (bytes.length >= 12 && bytes.subarray(0, 4).toString('ascii') === 'RIFF' && bytes.subarray(8, 12).toString('ascii') === 'WEBP') {
    return { mimeType: 'image/webp', extension: 'webp' };
  }
  return null;
}
