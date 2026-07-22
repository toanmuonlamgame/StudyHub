import { X } from 'lucide-react';
import { useEffect, useRef, type ReactNode } from 'react';
import { useLocale } from '../i18n/LocaleContext';

export function ConfirmDialog({ open, title, children, confirmLabel, destructive, busy, onCancel, onConfirm }: {
  open: boolean; title: string; children?: ReactNode; confirmLabel?: string; destructive?: boolean; busy?: boolean;
  onCancel: () => void; onConfirm: () => void;
}) {
  const { t } = useLocale();
  const ref = useRef<HTMLDialogElement>(null);
  useEffect(() => { if (open && !ref.current?.open) ref.current?.showModal(); else if (!open && ref.current?.open) ref.current.close(); }, [open]);
  return <dialog ref={ref} className="dialog" onCancel={onCancel}>
    <div className="dialog-title"><h2>{title}</h2><button className="icon-button" title={t.close} onClick={onCancel}><X /></button></div>
    <div>{children}</div>
    <div className="dialog-actions"><button className="button secondary" onClick={onCancel}>{t.cancel}</button><button className={`button ${destructive ? 'danger' : 'primary'}`} disabled={busy} onClick={onConfirm}>{confirmLabel ?? t.confirm}</button></div>
  </dialog>;
}
