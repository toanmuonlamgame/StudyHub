import { ShieldCheck } from 'lucide-react';
import { useAuth } from '../auth/AuthContext';
import { PageHeader } from '../components/PageHeader';
import { StatusBadge } from '../components/StatusBadge';
import { useLocale } from '../i18n/LocaleContext';

export function AccountPage() {
  const { user } = useAuth();
  const { t } = useLocale();
  return <><PageHeader title={t.account} description={t.profile} /><section className="panel account-card"><div className="account-icon"><ShieldCheck /></div><div><h2>{user?.displayName}</h2><p>{user?.email}</p><div className="badge-row"><StatusBadge status="admin" /><StatusBadge status="active" /></div></div></section></>;
}
