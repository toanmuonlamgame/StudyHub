import { Archive, Search } from 'lucide-react';
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

export function QuestionSetsPage() {
  const { t } = useLocale();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [archived, setArchived] = useState('');
  const [status, setStatus] = useState<ModerationStatus | ''>('');
  const [subjectId, setSubjectId] = useState('');
  const [topicId, setTopicId] = useState('');
  const state = useAsync(async () => {
    const [sets, subjects, topics] = await Promise.all([
      api.questionSets({ page, limit: 20, q, status, subjectId, topicId, archived: archived === '' ? undefined : archived === 'true' }),
      api.subjects(),
      api.topics(subjectId || undefined),
    ]);
    return { ...sets, subjects: subjects.subjects, topics: topics.topics };
  }, [page, q, status, subjectId, topicId, archived]);
  return <><PageHeader title={t.questionSets} description="Quản lý metadata và ẩn nội dung mà không phá lịch sử làm bài." />
    <div className="filter-bar"><label className="search-field"><Search /><input value={q} placeholder={t.search} onChange={(e) => { setQ(e.target.value); setPage(1); }} /></label><select value={status} onChange={(e) => { setStatus(e.target.value as ModerationStatus | ''); setPage(1); }}><option value="">{t.all}</option><option value="draft">{t.draft}</option><option value="pendingReview">{t.pending}</option><option value="published">{t.published}</option><option value="rejected">{t.rejected}</option></select><select value={subjectId} onChange={(e) => { setSubjectId(e.target.value); setTopicId(''); setPage(1); }}><option value="">{t.subject}: {t.all}</option>{state.data?.subjects.map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}</select><select value={topicId} onChange={(e) => { setTopicId(e.target.value); setPage(1); }}><option value="">{t.topic}: {t.all}</option>{state.data?.topics.map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}</select><select value={archived} onChange={(e) => { setArchived(e.target.value); setPage(1); }}><option value="">{t.all}</option><option value="false">{t.active}</option><option value="true">{t.archive}</option></select></div>
    <section className="panel table-panel">{state.loading ? <LoadingState /> : state.error || !state.data ? <ErrorState onRetry={state.reload} /> : state.data.page.items.length === 0 ? <EmptyState /> : <><div className="responsive-table"><table><thead><tr><th>{t.questionSets}</th><th>{t.subject}</th><th>{t.source}</th><th>{t.attempts}</th><th>{t.status}</th><th>{t.actions}</th></tr></thead><tbody>{state.data.page.items.map((item) => <tr key={item.id}><td><strong>{item.title}</strong><small>{item.questionCount} {t.questions.toLowerCase()}</small></td><td>{item.subjectName}<small>{item.topicName}</small></td><td>{item.sourceType === 'system' ? t.system : t.community}</td><td>{item.attemptCount}</td><td>{item.isArchived ? <span className="status-badge status-rejected"><Archive size={14} />{t.archive}</span> : <StatusBadge status={item.status} />}</td><td><Link className="button compact secondary" to={`/question-sets/${item.id}`}>{t.edit}</Link></td></tr>)}</tbody></table></div><Pagination page={state.data.page.page} totalPages={state.data.page.totalPages} onChange={setPage} /></>}</section></>;
}
