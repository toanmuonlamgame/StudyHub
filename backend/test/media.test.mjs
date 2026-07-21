import assert from 'node:assert/strict';
import test from 'node:test';

import { buildApp } from '../dist/app.js';

const png = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 1]);

test('authenticated image upload returns safe media metadata', async (t) => {
  const stored = new Map();
  const storage = {
    async saveImage(input) {
      assert.equal(input.mimeType, 'image/png');
      stored.set('safe.png', input.bytes);
      return { mediaType: 'image', mediaUrl: '/media/images/safe.png' };
    },
    async readImage(fileName) {
      const bytes = stored.get(fileName);
      return bytes === undefined ? null : { bytes, mimeType: 'image/png' };
    },
  };
  const app = buildApp({ mediaStorage: storage, requireUser: async () => ({ id: 'user-1' }) });
  t.after(() => app.close());

  const boundary = 'studyhub-boundary';
  const payload = Buffer.concat([
    Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="lesson.png"\r\nContent-Type: image/png\r\n\r\n`),
    png,
    Buffer.from(`\r\n--${boundary}--\r\n`),
  ]);
  const upload = await app.inject({
    method: 'POST',
    url: '/media/images',
    headers: { 'content-type': `multipart/form-data; boundary=${boundary}` },
    payload,
  });
  assert.equal(upload.statusCode, 201);
  assert.deepEqual(upload.json().media, { mediaType: 'image', mediaUrl: '/media/images/safe.png' });

  const image = await app.inject({ method: 'GET', url: '/media/images/safe.png' });
  assert.equal(image.statusCode, 200);
  assert.equal(image.headers['content-type'], 'image/png');
});

test('image upload requires authentication', async (t) => {
  const app = buildApp();
  t.after(() => app.close());
  const response = await app.inject({
    method: 'POST',
    url: '/media/images',
    headers: { 'content-type': 'multipart/form-data; boundary=x' },
    payload: '--x--\r\n',
  });
  assert.equal(response.statusCode, 401);
});
