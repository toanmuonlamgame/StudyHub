export interface CurrentIdentity {
  userId: string;
}

// Replace this single boundary with verified authentication when auth is added.
export function getCurrentIdentity(): CurrentIdentity {
  return { userId: 'demo-user' };
}
