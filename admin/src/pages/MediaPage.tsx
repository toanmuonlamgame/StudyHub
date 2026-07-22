import { ExternalLink, ImageOff, Search } from 'lucide-react';
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import { PageHeader } from '../components/PageHeader';
import { Pagination } from '../components/Pagination';
import { EmptyState, ErrorState, LoadingState } from '../components/States';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function MediaPage() {
  const { t } = useLocale();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [broken, setBroken] = useState('');
  const state = useAsync(() => api.media({ page, limit: 20, q, broken: broken === '' ? undefined : broken === 'true' }), [page, q, broken]);
  return <>
    <PageHeader title={t.media} description="Inspect question media and open the related contribution for moderation." />
    <div className="filter-bar"><label className="search-field"><Search /><input value={q} placeholder={t.search} onChange={(event) => { setQ(event.target.value); setPage(1); }} /></label><select value={broken} onChange={(event) => { setBroken(event.target.value); setPage(1); }}><option value="">{t.all}</option><option value="true">{t.broken}</option><option value="false">Valid</option></select></div>
    {state.loading ? <LoadingState /> : state.error || !state.data ? <ErrorState onRetry={state.reload} /> : state.data.page.items.length === 0 ? <EmptyState /> : <><section className="media-grid">{state.data.page.items.map((item) => <article className="panel media-card" key={item.id}><div className="media-frame">{item.brokenReference ? <ImageOff /> : <img src={api.mediaUrl(item.media.thumbnailUrl ?? item.media.mediaUrl)} alt={item.media.altText ?? item.questionText} loading="lazy" />}</div><div className="media-card-body"><div className="media-card-status"><StatusBadge status={item.submissionStatus} />{item.brokenReference && <span className="status-badge status-rejected">{t.broken}</span>}</div><Link className="text-link" to={item.submissionStatus === 'pendingReview' ? `/contributions/${item.questionSetId}` : `/question-sets/${item.questionSetId}`}>{item.questionSetTitle}</Link><p>{item.questionText}</p><a className="button secondary compact" href={api.mediaUrl(item.media.mediaUrl)} target="_blank" rel="noopener noreferrer"><ExternalLink />Preview</a></div></article>)}</section><Pagination page={state.data.page.page} totalPages={state.data.page.totalPages} onChange={setPage} /></>}
  </>;
}
