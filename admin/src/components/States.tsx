import { AlertTriangle, Inbox, LoaderCircle, RotateCcw } from 'lucide-react';
import { useLocale } from '../i18n/LocaleContext';

export function FullPageLoading() {
  const { t } = useLocale();
  return <div className="full-state"><LoaderCircle className="spin" /><p>{t.loading}</p></div>;
}

export function LoadingState() {
  const { t } = useLocale();
  return <div className="content-state"><LoaderCircle className="spin" /><span>{t.loading}</span></div>;
}

export function EmptyState({ message }: { message?: string }) {
  const { t } = useLocale();
  return <div className="content-state"><Inbox /><span>{message ?? t.noData}</span></div>;
}

export function ErrorState({ onRetry }: { onRetry: () => void }) {
  const { t } = useLocale();
  return <div className="content-state error"><AlertTriangle /><span>{t.operationFailed}</span><button className="button secondary" onClick={onRetry}><RotateCcw size={16} />{t.retry}</button></div>;
}
