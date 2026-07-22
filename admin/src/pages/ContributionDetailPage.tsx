import { ArrowLeft, Check, ExternalLink, X } from 'lucide-react';
import { useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/client';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Feedback } from '../components/Feedback';
import { PageHeader } from '../components/PageHeader';
import { ErrorState, LoadingState } from '../components/States';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function ContributionDetailPage() {
  const { id = '' } = useParams();
  const { t } = useLocale();
  const navigate = useNavigate();
  const state = useAsync(() => api.contribution(id), [id]);
  const [decision, setDecision] = useState<'approve' | 'reject' | null>(null);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [feedback, setFeedback] = useState('');
  if (state.loading) return <LoadingState />;
  if (state.error || !state.data) return <ErrorState onRetry={state.reload} />;
  const item = state.data.contribution;

  async function moderate() {
    if (!decision) return;
    setBusy(true); setFeedback('');
    try {
      if (decision === 'approve') await api.approveContribution(id);
      else await api.rejectContribution(id, reason);
      setDecision(null); setFeedback(t.operationSuccess); await state.reload();
    } catch { setFeedback(t.operationFailed); } finally { setBusy(false); }
  }

  return <><button className="back-link" onClick={() => navigate(-1)}><ArrowLeft />{t.contributions}</button>
    <PageHeader title={item.title} description={`${item.subjectName}${item.topicName ? ` · ${item.topicName}` : ''}`} actions={<StatusBadge status={item.status} />} />
    {feedback && <Feedback message={feedback} error={feedback === t.operationFailed} />}
    <div className="detail-grid"><section className="panel"><h2>{t.description}</h2><p>{item.description}</p><dl className="metadata"><div><dt>{t.contributor}</dt><dd>{item.contributor?.displayName ?? '—'}<small>{item.contributor?.email}</small></dd></div><div><dt>{t.questions}</dt><dd>{item.questions.length}</dd></div></dl></section>
      {item.status === 'pendingReview' && <aside className="panel action-panel"><h2>{t.actions}</h2><button className="button primary" onClick={() => setDecision('approve')}><Check />{t.approve}</button><button className="button danger" onClick={() => setDecision('reject')}><X />{t.reject}</button></aside>}
    </div>
    <section className="question-review-list">{item.questions.map((question, index) => <article className="panel question-review" key={`${item.id}-${index}`}><span className="question-number">{index + 1}</span><div><h3>{question.text}</h3>{question.media && <a className="media-preview" href={api.mediaUrl(question.media.mediaUrl)} target="_blank" rel="noreferrer"><img src={api.mediaUrl(question.media.mediaUrl)} alt={question.media.altText ?? question.text} /><ExternalLink /></a>}<ul className="answer-list">{question.answerOptions.map((answer, answerIndex) => <li className={answer.isCorrect ? 'correct-answer' : ''} key={answerIndex}>{answer.text}{answer.isCorrect && <span>{t.correctAnswer}</span>}</li>)}</ul>{question.explanation && <div className="explanation"><strong>{t.explanation}</strong><p>{question.explanation}</p></div>}</div></article>)}</section>
    <ConfirmDialog open={decision !== null} title={decision === 'approve' ? t.confirmApprove : t.confirmReject} destructive={decision === 'reject'} busy={busy} confirmLabel={decision === 'approve' ? t.approve : t.reject} onCancel={() => setDecision(null)} onConfirm={() => void moderate()}>{decision === 'reject' && <label>{t.reason}<textarea value={reason} onChange={(e) => setReason(e.target.value)} minLength={3} maxLength={1000} autoFocus /></label>}</ConfirmDialog>
    <Link to="/contributions" className="sr-only">{t.contributions}</Link></>;
}
