import { createContext, useContext, useMemo, useState, type ReactNode } from 'react';
import { copy, type Copy, type Locale } from './copy';

const LocaleContext = createContext<{ locale: Locale; t: Copy; toggle: () => void } | null>(null);

export function LocaleProvider({ children }: { children: ReactNode }) {
  const [locale, setLocale] = useState<Locale>(() => localStorage.getItem('studyhub_admin_locale') === 'en' ? 'en' : 'vi');
  const value = useMemo(() => ({
    locale,
    t: copy[locale],
    toggle: () => setLocale((current) => {
      const next = current === 'vi' ? 'en' : 'vi';
      localStorage.setItem('studyhub_admin_locale', next);
      return next;
    }),
  }), [locale]);
  return <LocaleContext.Provider value={value}>{children}</LocaleContext.Provider>;
}

export function useLocale() {
  const value = useContext(LocaleContext);
  if (!value) throw new Error('LocaleProvider is missing.');
  return value;
}
