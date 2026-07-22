# StudyHub Admin

React and TypeScript administration application for StudyHub moderation and
platform operations. It uses the existing StudyHub bearer-session API; route
guards improve UX, while every `/admin` request is authorized again by Fastify.

## Local setup

```powershell
cd admin
Copy-Item .env.example .env.local
npm install
npm run dev
```

Set `VITE_API_BASE_URL` in the local `.env.local` to the non-secret backend
origin. Never put credentials or access tokens in Vite environment variables.

The matching backend must have the admin migration applied and at least one
active user whose database role is `admin`. StudyHub never ships a default admin
password. For local development, create a normal account, then use Prisma Studio
or a controlled database operation to promote that specific account. Do not
hard-code or commit the account credentials.

## Commands

```text
npm run dev        # Vite development server
npm run typecheck  # TypeScript validation
npm run build      # production bundle in dist/
npm run preview    # preview the built bundle
```

For production hosting, configure the web server to return `index.html` for
unknown client-side routes and add the deployed admin origin to the backend's
exact `STUDYHUB_CORS_ORIGINS` allowlist.

## Available areas

- Admin-only login, persistent session restore, logout, and expired-session handling.
- Real dashboard totals and recent contribution activity.
- Pending contribution inspection with answers, explanations, media, approve,
  and reason-required reject actions.
- Question Set search, detail, safe metadata editing, and reversible archive.
- Subject and Topic creation and reversible archive with backend duplicate checks.
- User search, aggregate counts, role/status controls, and session revocation on disable.
- Media inspection with broken-reference filtering and safe full-size links.

The first milestone intentionally excludes charts, impersonation, password
management, bulk operations, a permission matrix, AI moderation, and a full
audit-log product.
