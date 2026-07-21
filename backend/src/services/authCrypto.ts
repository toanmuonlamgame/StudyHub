import { createHash, randomBytes, scrypt, timingSafeEqual } from 'node:crypto';

const keyLength = 64;

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  const key = await deriveKey(password, salt);
  return `scrypt$${salt.toString('base64url')}$${key.toString('base64url')}`;
}

export async function verifyPassword(
  password: string,
  storedHash: string,
): Promise<boolean> {
  const [algorithm, encodedSalt, encodedKey] = storedHash.split('$');
  if (algorithm !== 'scrypt' || !encodedSalt || !encodedKey) return false;
  try {
    const salt = Buffer.from(encodedSalt, 'base64url');
    const expected = Buffer.from(encodedKey, 'base64url');
    if (expected.length !== keyLength) return false;
    const actual = await deriveKey(password, salt);
    return timingSafeEqual(actual, expected);
  } catch {
    return false;
  }
}

export function createAccessToken(): string {
  return randomBytes(32).toString('base64url');
}

export function hashAccessToken(accessToken: string): string {
  return createHash('sha256').update(accessToken, 'utf8').digest('hex');
}

function deriveKey(password: string, salt: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    scrypt(password, salt, keyLength, (error, derivedKey) => {
      if (error) reject(error);
      else resolve(derivedKey);
    });
  });
}
