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

## Learning API

The Learning routes depend on a `LearningService` abstraction. The in-memory
implementation remains the default and requires no PostgreSQL database:

```text
GET  /learning/subjects
GET  /learning/subjects/:subjectId/topics
GET  /learning/subjects/:subjectId/question-sets
GET  /learning/question-sets/:questionSetId
GET  /learning/question-sets/:questionSetId/questions
POST /learning/question-sets/:questionSetId/submit
```

Question responses omit correctness metadata. Submit scoring stays inside the
selected service.

Set `STUDYHUB_LEARNING_DATA_SOURCE=memory` or leave it unset for the current
default. The prepared `prisma` option requires a valid local `DATABASE_URL` and
should only be selected after migration and seed have completed. These values
are local runtime configuration; no credentials belong in Git.

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

The backend also includes a `PrismaLearningService` foundation for reading
Learning data and calculating submitted quiz results through Prisma.
It maps database rows to the existing API types and removes `isCorrect` from
pre-submit question data. It is selectable but not enabled by default, so tests
and normal local API development do not require PostgreSQL yet.

Never commit `.env` or real database credentials. `.env.example` contains
placeholders only.
