import { Search, ShieldCheck, UserRoundCheck, UserRoundX } from 'lucide-react';
import { useState } from 'react';
import { api } from '../api/client';
import type { AdminUser } from '../api/types';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Feedback } from '../components/Feedback';
import { PageHeader } from '../components/PageHeader';
import { Pagination } from '../components/Pagination';
import { EmptyState, ErrorState, LoadingState } from '../components/States';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function UsersPage() {
  const { t } = useLocale();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [role, setRole] = useState('');
  const [selected, setSelected] = useState<AdminUser | null>(null);
  const [action, setAction] = useState<'status' | 'role' | null>(null);
  const [feedback, setFeedback] = useState('');
  const [busy, setBusy] = useState(false);
  const state = useAsync(() => api.users({ page, limit: 20, q, role: role || undefined }), [page, q, role]);

  async function update() {
    if (!selected || !action) return;
    setBusy(true); setFeedback('');
    try {
      await api.updateUser(selected.id, action === 'status'
        ? { status: selected.status === 'active' ? 'disabled' : 'active' }
        : { role: selected.role === 'admin' ? 'user' : 'admin' });
      setFeedback(t.operationSuccess); setSelected(null); setAction(null); await state.reload();
    } catch { setFeedback(t.operationFailed); }
    finally { setBusy(false); }
  }

  return <>
    <PageHeader title={t.users} description="Review accounts, roles and aggregate learning activity." />
    {feedback && <Feedback message={feedback} error={feedback === t.operationFailed} />}
    <div className="filter-bar"><label className="search-field"><Search /><input value={q} placeholder={t.search} onChange={(event) => { setQ(event.target.value); setPage(1); }} /></label><select value={role} onChange={(event) => { setRole(event.target.value); setPage(1); }}><option value="">{t.all}</option><option value="user">User</option><option value="admin">Admin</option></select></div>
    <section className="panel table-panel">{state.loading ? <LoadingState /> : state.error || !state.data ? <ErrorState onRetry={state.reload} /> : state.data.page.items.length === 0 ? <EmptyState /> : <><div className="responsive-table"><table><thead><tr><th>{t.users}</th><th>{t.role}</th><th>{t.status}</th><th>{t.attemptsCount}</th><th>{t.contributionsCount}</th><th>{t.actions}</th></tr></thead><tbody>{state.data.page.items.map((user) => <tr key={user.id}><td><strong>{user.displayName}</strong><small>{user.email}</small></td><td><StatusBadge status={user.role} /></td><td><StatusBadge status={user.status} /></td><td>{user.attemptCount}</td><td>{user.contributionCount}</td><td><div className="row-actions"><button className="icon-button" title={user.status === 'active' ? t.disable : t.enable} onClick={() => { setSelected(user); setAction('status'); }}>{user.status === 'active' ? <UserRoundX /> : <UserRoundCheck />}</button><button className="icon-button" title={t.role} onClick={() => { setSelected(user); setAction('role'); }}><ShieldCheck /></button></div></td></tr>)}</tbody></table></div><Pagination page={state.data.page.page} totalPages={state.data.page.totalPages} onChange={setPage} /></>}</section>
    <ConfirmDialog open={selected !== null} title={action === 'role' ? t.role : selected?.status === 'active' ? t.disable : t.enable} destructive={action === 'status' && selected?.status === 'active'} busy={busy} onCancel={() => { setSelected(null); setAction(null); }} onConfirm={() => void update()}><p>{selected?.displayName} ({selected?.email})</p></ConfirmDialog>
  </>;
}
