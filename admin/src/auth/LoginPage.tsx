import { BookOpenCheck, LockKeyhole } from 'lucide-react';
import { useState, type FormEvent } from 'react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from './AuthContext';
import { useLocale } from '../i18n/LocaleContext';

export function LoginPage() {
  const { user, login } = useAuth();
  const { t, locale, toggle } = useLocale();
  const navigate = useNavigate();
  const location = useLocation();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  if (user) return <Navigate to="/" replace />;

  async function submit(event: FormEvent) {
    event.preventDefault();
    setBusy(true); setError('');
    try {
      await login(email, password);
      const from = (location.state as { from?: string } | null)?.from ?? '/';
      navigate(from, { replace: true });
    } catch (reason) {
      setError(reason instanceof Error && reason.message === 'ADMIN_REQUIRED' ? t.unauthorized : t.operationFailed);
    } finally { setBusy(false); }
  }

  return <main className="login-page">
    <button className="language-button" onClick={toggle}>{locale === 'vi' ? 'EN' : 'VI'}</button>
    <form className="login-panel" onSubmit={submit}>
      <div className="brand-mark"><BookOpenCheck aria-hidden="true" /></div>
      <p className="eyebrow">StudyHub</p>
      <h1>{t.signIn}</h1>
      <p className="muted">{t.signInHint}</p>
      <label>{t.email}<input type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} required /></label>
      <label>{t.password}<input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required /></label>
      {error && <div className="inline-error" role="alert"><LockKeyhole size={18} />{error}</div>}
      <button className="button primary" disabled={busy}>{busy ? t.loading : t.signIn}</button>
    </form>
  </main>;
}
