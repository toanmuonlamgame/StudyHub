import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import { api, clearStoredSession, readStoredSession, storeSession } from '../api/client';
import type { AuthUser } from '../api/types';

interface AuthValue {
  user: AuthUser | null;
  loading: boolean;
  login(email: string, password: string): Promise<void>;
  logout(): Promise<void>;
}

const AuthContext = createContext<AuthValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(() => readStoredSession()?.user ?? null);
  const [loading, setLoading] = useState(Boolean(readStoredSession()));

  const clear = useCallback(() => { clearStoredSession(); setUser(null); }, []);

  useEffect(() => {
    const unauthorized = () => clear();
    window.addEventListener('studyhub:unauthorized', unauthorized);
    const session = readStoredSession();
    if (!session) { setLoading(false); return () => window.removeEventListener('studyhub:unauthorized', unauthorized); }
    api.me()
      .then(({ user: current }) => {
        if (current.role !== 'admin' || current.status !== 'active') clear();
        else setUser(current);
      })
      .catch(clear)
      .finally(() => setLoading(false));
    return () => window.removeEventListener('studyhub:unauthorized', unauthorized);
  }, [clear]);

  async function login(email: string, password: string) {
    const session = await api.login(email, password);
    if (session.user.role !== 'admin' || session.user.status !== 'active') {
      clearStoredSession();
      throw new Error('ADMIN_REQUIRED');
    }
    storeSession(session);
    setUser(session.user);
  }

  async function logout() {
    try { await api.logout(); } finally { clear(); }
  }

  return <AuthContext.Provider value={{ user, loading, login, logout }}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error('AuthProvider is missing.');
  return value;
}
