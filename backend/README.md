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

## Prisma local mode checklist

Use this checklist only when a local PostgreSQL instance is ready. The normal
development and test flow continues to use the in-memory data source.

1. Copy `.env.example` to `.env` inside `backend`.
2. Replace the placeholder `DATABASE_URL` in that local file with the connection
   string for your local PostgreSQL database.
3. Export the same local `DATABASE_URL` to the terminal session. In PowerShell:

   ```powershell
   $env:DATABASE_URL = "<your local DATABASE_URL>"
   ```

   This is required by the direct `prisma:seed` script; keep the real value only
   in your local environment and `.env` file.

4. Generate the Prisma client:

   ```text
   npm run prisma:generate
   ```

5. Create and apply the initial migration:

   ```text
   npm run prisma:migrate -- --name init
   ```

6. Seed the Learning fixtures:

   ```text
   npm run prisma:seed
   ```

7. Select the Prisma data source and start the backend in the same PowerShell
   session:

   ```powershell
   $env:STUDYHUB_LEARNING_DATA_SOURCE = "prisma"
   npm run dev
   ```

8. In another terminal, smoke-test both endpoints:

   ```powershell
   Invoke-RestMethod http://localhost:3000/health
   Invoke-RestMethod http://localhost:3000/learning/subjects
   ```

9. Confirm that `/health` reports `status: ok` and `/learning/subjects` returns
   the seeded subjects.

`backend/.env` is ignored by Git and must remain local. Never commit the file,
its connection string, or any database password.
