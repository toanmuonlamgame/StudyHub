# StudyHub Backend

Minimal Fastify and TypeScript backend skeleton for StudyHub.

## Run locally

```bash
npm install
npm run dev
npm test
```

The server uses port `3000` by default and accepts a `PORT` environment variable.

Health check:

```text
GET http://localhost:3000/health
```

## Mock learning API

The current learning API uses in-memory data only:

```text
GET  /learning/subjects
GET  /learning/subjects/:subjectId/topics
GET  /learning/subjects/:subjectId/question-sets
GET  /learning/question-sets/:questionSetId
GET  /learning/question-sets/:questionSetId/questions
POST /learning/question-sets/:questionSetId/submit
```

Question responses omit correctness metadata. Submit scoring uses a private in-memory answer key.

Run all backend tests with `npm test`.

## Prisma foundation

The Prisma schema targets PostgreSQL, but the Learning API still uses in-memory
data. Existing development and tests do not require a running database.

1. Copy `.env.example` to a local `.env`.
2. Replace the placeholder `DATABASE_URL` with local PostgreSQL credentials.
3. Run `npm run prisma:generate`.
4. When a database is available, run `npm run prisma:migrate -- --name init`.
5. After the migration succeeds, run `npm run prisma:seed` to load the mock
   Learning fixtures into PostgreSQL.

The seed uses stable fixture IDs and upserts records in dependency order, so it
can be run again while the fixture structure is unchanged. It is opt-in and is
not run by backend tests. The in-memory Learning API remains active.

Never commit `.env` or real database credentials. `.env.example` contains
placeholders only.
