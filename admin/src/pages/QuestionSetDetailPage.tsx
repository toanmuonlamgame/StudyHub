import { Archive, ArrowLeft, Save } from 'lucide-react';
import { useEffect, useState, type FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/client';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Feedback } from '../components/Feedback';
import { PageHeader } from '../components/PageHeader';
import { ErrorState, LoadingState } from '../components/States';
import { StatusBadge } from '../components/StatusBadge';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function QuestionSetDetailPage() {
  const { id = '' } = useParams();
  const navigate = useNavigate();
  const { t } = useLocale();
  const state = useAsync(() => api.questionSet(id), [id]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [confirmArchive, setConfirmArchive] = useState(false);
  const [feedback, setFeedback] = useState('');
  const [busy, setBusy] = useState(false);
  useEffect(() => { if (state.data) { setTitle(state.data.questionSet.title); setDescription(state.data.questionSet.description); } }, [state.data]);
  if (state.loading) return <LoadingState />;
  if (state.error || !state.data) return <ErrorState onRetry={state.reload} />;
  const item = state.data.questionSet;
  async function save(event: FormEvent) { event.preventDefault(); setBusy(true); try { await api.updateQuestionSet(id, { title, description }); setFeedback(t.operationSuccess); await state.reload(); } catch { setFeedback(t.operationFailed); } finally { setBusy(false); } }
  async function toggleArchive() { setBusy(true); try { await api.updateQuestionSet(id, { isArchived: !item.isArchived }); setFeedback(t.operationSuccess); setConfirmArchive(false); await state.reload(); } catch { setFeedback(t.operationFailed); } finally { setBusy(false); } }
  return <><button className="back-link" onClick={() => navigate(-1)}><ArrowLeft />{t.questionSets}</button><PageHeader title={item.title} description={`${item.subjectName} · ${item.questionCount} ${t.questions.toLowerCase()}`} actions={<StatusBadge status={item.status} />} />{feedback && <Feedback message={feedback} error={feedback === t.operationFailed} />}
    <div className="detail-grid"><form className="panel form-panel" onSubmit={save}><label>{t.name}<input value={title} onChange={(e) => setTitle(e.target.value)} maxLength={120} required /></label><label>{t.description}<textarea value={description} onChange={(e) => setDescription(e.target.value)} maxLength={2000} /></label><button className="button primary" disabled={busy}><Save />{t.save}</button></form><aside className="panel action-panel"><h2>{t.actions}</h2><dl className="metadata"><div><dt>{t.attempts}</dt><dd>{item.attemptCount}</dd></div><div><dt>{t.source}</dt><dd>{item.sourceType}</dd></div></dl><button className={`button ${item.isArchived ? 'secondary' : 'danger'}`} onClick={() => setConfirmArchive(true)}><Archive />{item.isArchived ? t.restore : t.archive}</button></aside></div>
    <section className="panel"><h2>{t.questions}</h2><div className="compact-question-list">{item.questions.map((question, index) => <article key={index}><strong>{index + 1}. {question.text}</strong><span>{question.answerOptions.find((answer) => answer.isCorrect)?.text}</span></article>)}</div></section>
    <ConfirmDialog open={confirmArchive} title={item.isArchived ? t.restore : t.archive} destructive={!item.isArchived} busy={busy} onCancel={() => setConfirmArchive(false)} onConfirm={() => void toggleArchive()}><p>{item.isArchived ? 'Nội dung sẽ xuất hiện lại cho người học.' : 'Nội dung sẽ bị ẩn nhưng lịch sử làm bài vẫn được giữ.'}</p></ConfirmDialog></>;
}
