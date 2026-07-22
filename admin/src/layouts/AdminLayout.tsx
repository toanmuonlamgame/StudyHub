import { BookOpenCheck, ClipboardCheck, FileQuestion, FolderTree, Gauge, Images, Languages, LogOut, Menu, Settings, Users, X } from 'lucide-react';
import { useState } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { useLocale } from '../i18n/LocaleContext';

export function AdminLayout() {
  const { user, logout } = useAuth();
  const { t, locale, toggle } = useLocale();
  const [open, setOpen] = useState(false);
  const links = [
    ['/', t.dashboard, Gauge],
    ['/contributions', t.contributions, ClipboardCheck],
    ['/question-sets', t.questionSets, FileQuestion],
    ['/taxonomy', t.taxonomy, FolderTree],
    ['/users', t.users, Users],
    ['/media', t.media, Images],
    ['/account', t.account, Settings],
  ] as const;
  return <div className="admin-shell">
    <aside className={`sidebar ${open ? 'sidebar-open' : ''}`}>
      <div className="sidebar-brand"><BookOpenCheck /><div><strong>StudyHub</strong><span>{t.adminConsole}</span></div><button className="icon-button sidebar-close" title={t.close} onClick={() => setOpen(false)}><X /></button></div>
      <nav>{links.map(([to, label, Icon]) => <NavLink key={to} to={to} end={to === '/'} onClick={() => setOpen(false)}><Icon /><span>{label}</span></NavLink>)}</nav>
      <div className="sidebar-footer"><button onClick={toggle}><Languages /><span>{locale === 'vi' ? 'English' : 'Tiếng Việt'}</span></button><button onClick={() => void logout()}><LogOut /><span>{t.logout}</span></button></div>
    </aside>
    {open && <button className="sidebar-backdrop" aria-label={t.close} onClick={() => setOpen(false)} />}
    <div className="shell-main">
      <header className="topbar"><button className="icon-button mobile-menu" title={t.menu} onClick={() => setOpen(true)}><Menu /></button><div className="topbar-spacer" /><div className="admin-identity"><div className="avatar">{user?.displayName.charAt(0).toUpperCase()}</div><div><strong>{user?.displayName}</strong><span>{user?.email}</span></div></div></header>
      <main className="page-content"><Outlet /></main>
    </div>
  </div>;
}
