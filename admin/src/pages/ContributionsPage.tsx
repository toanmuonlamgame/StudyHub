import { Search } from 'lucide-react';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import type { ModerationStatus } from '../api/types';
import { PageHeader } from '../components/PageHeader';
import { Pagination } from '../components/Pagination';
import { EmptyState, ErrorState, LoadingState } from '../components/States';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function ContributionsPage() {
  const { t } = useLocale();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState<ModerationStatus | ''>('pendingReview');
  const [subjectId, setSubjectId] = useState('');
  const [topicId, setTopicId] = useState('');
  const state = useAsync(async () => {
    const [contributions, subjects, topics] = await Promise.all([
      api.contributions({ page, limit: 20, q, status, subjectId, topicId }),
      api.subjects(),
      api.topics(subjectId || undefined),
    ]);
    return { ...contributions, subjects: subjects.subjects, topics: topics.topics };
  }, [page, q, status, subjectId, topicId]);
  return <><PageHeader title={t.contributions} description="Duyệt nội dung cộng đồng trước khi hiển thị cho người học." />
    <div className="filter-bar"><label className="search-field"><Search /><input value={q} onChange={(e) => { setQ(e.target.value); setPage(1); }} placeholder={t.search} /></label><select value={status} onChange={(e) => { setStatus(e.target.value as ModerationStatus | ''); setPage(1); }}><option value="">{t.all}</option><option value="pendingReview">{t.pending}</option><option value="published">{t.published}</option><option value="rejected">{t.rejected}</option><option value="draft">{t.draft}</option></select><select value={subjectId} onChange={(e) => { setSubjectId(e.target.value); setTopicId(''); setPage(1); }}><option value="">{t.subject}: {t.all}</option>{state.data?.subjects.map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}</select><select value={topicId} onChange={(e) => { setTopicId(e.target.value); setPage(1); }}><option value="">{t.topic}: {t.all}</option>{state.data?.topics.map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}</select></div>
    <section className="panel table-panel">{state.loading ? <LoadingState /> : state.error || !state.data ? <ErrorState onRetry={state.reload} /> : state.data.page.items.length === 0 ? <EmptyState /> : <>
      <div className="responsive-table"><table><thead><tr><th>{t.questions}</th><th>{t.subject}</th><th>{t.contributor}</th><th>{t.status}</th><th>{t.actions}</th></tr></thead><tbody>{state.data.page.items.map((item) => <tr key={item.id}><td><strong>{item.title}</strong><small>{item.questionCount} {t.questions.toLowerCase()}</small></td><td>{item.subjectName}<small>{item.topicName}</small></td><td>{item.contributorName ?? '—'}</td><td><StatusBadge status={item.status} /></td><td><Link className="button compact secondary" to={`/contributions/${item.id}`}>{t.review}</Link></td></tr>)}</tbody></table></div>
      <Pagination page={state.data.page.page} totalPages={state.data.page.totalPages} onChange={setPage} /></>}</section></>;
}
