import { CheckCircle2, ClipboardList, FileQuestion, RotateCcw, Target, Users } from 'lucide-react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import { ErrorState, LoadingState } from '../components/States';
import { PageHeader } from '../components/PageHeader';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function DashboardPage() {
  const { t } = useLocale();
  const state = useAsync(() => api.dashboard(), []);
  if (state.loading) return <LoadingState />;
  if (state.error || !state.data) return <ErrorState onRetry={state.reload} />;
  const summary = state.data.summary;
  const cards = [
    [t.totalUsers, summary.totalUsers, Users, 'indigo'], [t.totalSets, summary.totalQuestionSets, FileQuestion, 'teal'],
    [t.pending, summary.pendingContributions, ClipboardList, 'amber'], [t.approved, summary.approvedContributions, CheckCircle2, 'green'],
    [t.rejected, summary.rejectedContributions, RotateCcw, 'red'], [t.attempts, summary.totalAttempts, Target, 'violet'],
  ] as const;
  return <><PageHeader title={t.dashboard} description="Theo dõi dữ liệu thật và các việc cần xử lý trên StudyHub." />
    <section className="metric-grid">{cards.map(([label, value, Icon, tone]) => <article className={`metric-card tone-${tone}`} key={label}><div className="metric-icon"><Icon /></div><div><strong>{value.toLocaleString()}</strong><span>{label}</span></div></article>)}</section>
    <section className="panel"><div className="panel-heading"><h2>{t.recent}</h2><Link className="text-link" to="/contributions">{t.review}</Link></div>
      {summary.recentContributions.length === 0 ? <p className="muted">{t.noData}</p> : <div className="activity-list">{summary.recentContributions.map((item) => <Link key={item.id} to={`/contributions/${item.id}`}><div><strong>{item.title}</strong><span>{item.contributorName ?? item.subjectName}</span></div><StatusBadge status={item.status} /></Link>)}</div>}
    </section></>;
}
