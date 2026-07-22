import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider } from '../auth/AuthContext';
import { LoginPage } from '../auth/LoginPage';
import { ProtectedRoute } from '../auth/ProtectedRoute';
import { LocaleProvider } from '../i18n/LocaleContext';
import { AdminLayout } from '../layouts/AdminLayout';
import { AccountPage } from '../pages/AccountPage';
import { ContributionDetailPage } from '../pages/ContributionDetailPage';
import { ContributionsPage } from '../pages/ContributionsPage';
import { DashboardPage } from '../pages/DashboardPage';
import { MediaPage } from '../pages/MediaPage';
import { QuestionSetDetailPage } from '../pages/QuestionSetDetailPage';
import { QuestionSetsPage } from '../pages/QuestionSetsPage';
import { TaxonomyPage } from '../pages/TaxonomyPage';
import { UsersPage } from '../pages/UsersPage';

export function App() {
  return <LocaleProvider><AuthProvider><BrowserRouter><Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route element={<ProtectedRoute />}>
      <Route element={<AdminLayout />}>
        <Route index element={<DashboardPage />} />
        <Route path="contributions" element={<ContributionsPage />} />
        <Route path="contributions/:id" element={<ContributionDetailPage />} />
        <Route path="question-sets" element={<QuestionSetsPage />} />
        <Route path="question-sets/:id" element={<QuestionSetDetailPage />} />
        <Route path="taxonomy" element={<TaxonomyPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="media" element={<MediaPage />} />
        <Route path="account" element={<AccountPage />} />
      </Route>
    </Route>
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes></BrowserRouter></AuthProvider></LocaleProvider>;
}
