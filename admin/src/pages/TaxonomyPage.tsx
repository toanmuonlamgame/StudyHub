import { Archive, FolderTree, Pencil, Plus } from 'lucide-react';
import { useState, type FormEvent } from 'react';
import { api } from '../api/client';
import type { Subject, Topic } from '../api/types';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { Feedback } from '../components/Feedback';
import { PageHeader } from '../components/PageHeader';
import { EmptyState, ErrorState, LoadingState } from '../components/States';
import { useAsync } from '../hooks/useAsync';
import { useLocale } from '../i18n/LocaleContext';

export function TaxonomyPage() {
  const { t } = useLocale();
  const state = useAsync(async () => {
    const [subjectResponse, topicResponse] = await Promise.all([api.subjects(), api.topics()]);
    return { subjects: subjectResponse.subjects, topics: topicResponse.topics };
  }, []);
  const [subjectName, setSubjectName] = useState('');
  const [topicName, setTopicName] = useState('');
  const [topicSubjectId, setTopicSubjectId] = useState('');
  const [pending, setPending] = useState<{ kind: 'subject' | 'topic'; item: Subject | Topic } | null>(null);
  const [editing, setEditing] = useState<{ kind: 'subject' | 'topic'; item: Subject | Topic; name: string } | null>(null);
  const [feedback, setFeedback] = useState('');
  const [busy, setBusy] = useState(false);

  async function createSubject(event: FormEvent) {
    event.preventDefault();
    await run(async () => { await api.createSubject({ name: subjectName }); setSubjectName(''); });
  }

  async function createTopic(event: FormEvent) {
    event.preventDefault();
    await run(async () => { await api.createTopic({ subjectId: topicSubjectId, name: topicName }); setTopicName(''); });
  }

  async function toggleArchive() {
    if (!pending) return;
    await run(async () => {
      if (pending.kind === 'subject') await api.updateSubject(pending.item.id, { isArchived: !pending.item.isArchived });
      else await api.updateTopic(pending.item.id, { isArchived: !pending.item.isArchived });
      setPending(null);
    });
  }

  async function saveEdit() {
    if (!editing) return;
    await run(async () => {
      if (editing.kind === 'subject') await api.updateSubject(editing.item.id, { name: editing.name });
      else await api.updateTopic(editing.item.id, { name: editing.name });
      setEditing(null);
    });
  }

  async function run(action: () => Promise<void>) {
    setBusy(true); setFeedback('');
    try { await action(); setFeedback(t.operationSuccess); await state.reload(); }
    catch { setFeedback(t.operationFailed); }
    finally { setBusy(false); }
  }

  if (state.loading) return <LoadingState />;
  if (state.error || !state.data) return <ErrorState onRetry={state.reload} />;
  const activeSubjects = state.data.subjects.filter((item) => !item.isArchived);
  return <>
    <PageHeader title={t.taxonomy} description="Maintain the subject and topic structure without deleting learning history." />
    {feedback && <Feedback message={feedback} error={feedback === t.operationFailed} />}
    <div className="taxonomy-grid">
      <section className="panel">
        <div className="panel-heading"><h2>{t.subject}</h2></div>
        <form className="inline-create" onSubmit={createSubject}><label><span>{t.name}</span><input value={subjectName} onChange={(event) => setSubjectName(event.target.value)} maxLength={120} required /></label><button className="button primary" disabled={busy}><Plus />{t.create}</button></form>
        {state.data.subjects.length === 0 ? <EmptyState /> : <div className="management-list">{state.data.subjects.map((subject) => <article key={subject.id}><div className="list-icon"><FolderTree /></div><div><strong>{subject.name}</strong><span>{subject.topicCount} topics · {subject.questionSetCount} sets</span></div><div className="row-actions"><button className="icon-button" title={t.edit} onClick={() => setEditing({ kind: 'subject', item: subject, name: subject.name })}><Pencil /></button><button className="icon-button" title={subject.isArchived ? t.restore : t.archive} onClick={() => setPending({ kind: 'subject', item: subject })}><Archive /></button></div></article>)}</div>}
      </section>
      <section className="panel">
        <div className="panel-heading"><h2>{t.topic}</h2></div>
        <form className="stacked-create" onSubmit={createTopic}><label>{t.subject}<select value={topicSubjectId} onChange={(event) => setTopicSubjectId(event.target.value)} required><option value="">{t.subject}</option>{activeSubjects.map((subject) => <option key={subject.id} value={subject.id}>{subject.name}</option>)}</select></label><label>{t.name}<input value={topicName} onChange={(event) => setTopicName(event.target.value)} maxLength={120} required /></label><button className="button primary" disabled={busy}><Plus />{t.create}</button></form>
        {state.data.topics.length === 0 ? <EmptyState /> : <div className="management-list">{state.data.topics.map((topic) => <article key={topic.id}><div><strong>{topic.name}</strong><span>{topic.subjectName} · {topic.questionSetCount} sets</span></div><div className="row-actions"><button className="icon-button" title={t.edit} onClick={() => setEditing({ kind: 'topic', item: topic, name: topic.name })}><Pencil /></button><button className="icon-button" title={topic.isArchived ? t.restore : t.archive} onClick={() => setPending({ kind: 'topic', item: topic })}><Archive /></button></div></article>)}</div>}
      </section>
    </div>
    <ConfirmDialog open={pending !== null} title={pending?.item.isArchived ? t.restore : t.archive} destructive={!pending?.item.isArchived} busy={busy} onCancel={() => setPending(null)} onConfirm={() => void toggleArchive()}><p>{pending?.item.name}</p></ConfirmDialog>
    <ConfirmDialog open={editing !== null} title={t.edit} busy={busy} confirmLabel={t.save} onCancel={() => setEditing(null)} onConfirm={() => void saveEdit()}><label>{t.name}<input value={editing?.name ?? ''} maxLength={120} required onChange={(event) => setEditing((current) => current ? { ...current, name: event.target.value } : null)} /></label></ConfirmDialog>
  </>;
}
