import type { ModerationStatus, UserStatus } from '../api/types';
import { useLocale } from '../i18n/LocaleContext';

export function StatusBadge({ status }: { status: ModerationStatus | UserStatus | 'admin' | 'user' }) {
  const { t } = useLocale();
  const labels = {
    draft: t.draft,
    pendingReview: t.pending,
    published: t.published,
    rejected: t.rejected,
    active: t.active,
    disabled: t.disabled,
    admin: t.admin,
    user: t.user,
  };
  return <span className={`status-badge status-${status}`}>{labels[status]}</span>;
}
