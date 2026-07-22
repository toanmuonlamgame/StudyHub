import { ChevronLeft, ChevronRight } from 'lucide-react';
import { useLocale } from '../i18n/LocaleContext';

export function Pagination({ page, totalPages, onChange }: { page: number; totalPages: number; onChange: (page: number) => void }) {
  const { t } = useLocale();
  return <nav className="pagination" aria-label="Pagination">
    <button className="icon-button" title={t.previous} disabled={page <= 1} onClick={() => onChange(page - 1)}><ChevronLeft /></button>
    <span>{t.page} {page} / {totalPages}</span>
    <button className="icon-button" title={t.next} disabled={page >= totalPages} onClick={() => onChange(page + 1)}><ChevronRight /></button>
  </nav>;
}
