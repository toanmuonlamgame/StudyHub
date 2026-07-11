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
GET  /learning/question-sets?subjectId=...&topicId=...&q=...&limit=20&cursor=...
GET  /learning/question-sets/:questionSetId
GET  /learning/question-sets/:questionSetId/questions
POST /learning/questions/:questionId/check-answer
POST /learning/question-sets/:questionSetId/submit
```

Question responses omit correctness metadata. Submit scoring stays inside the
selected service.

The paginated Question Set endpoint defaults to 20 items, accepts at most 50,
and returns `{ items, nextCursor, hasMore }`. Its opaque cursor uses stable
`createdAt` and `id` ordering. List items contain metadata only, never questions
or answers. Difficulty and estimated time are currently derived from question
count until those fields become persisted product metadata.

Set `STUDYHUB_LEARNING_DATA_SOURCE=memory` or leave it unset for the current
default. The prepared `prisma` option requires a valid local `DATABASE_URL` and
should only be selected after migration and seed have completed. These values
are local runtime configuration; no credentials belong in Git.

Run all backend tests with `npm test`.

## Prisma foundation

The Prisma schema targets PostgreSQL. Learning routes can use either the default
in-memory service or the Prisma service without changing their JSON contract.
Existing automated tests continue to use memory and do not require a database.

The `learning_query_indexes` migration adds composite indexes for paginated
Question Set filtering/order and ordered Topic reads. Existing unique
`(questionSetId, position)` and `(questionId, position)` constraints already
support ordered Question and Answer Option lookups, so redundant single-column
indexes are intentionally omitted.

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

4. Validate the schema and generate the Prisma client:

   ```text
   npm run prisma:validate
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

## Run and smoke-test data sources

The seeded IDs in these commands come from `prisma/seed.ts`. Update the commands
if those fixtures change.

### Memory mode

Memory remains the safe default and does not require `DATABASE_URL`:

```powershell
$env:STUDYHUB_LEARNING_DATA_SOURCE = "memory"
npm run dev
```

### Prisma mode

Use the same local connection string used for migration and seed:

```powershell
$env:DATABASE_URL = "<your local DATABASE_URL>"
$env:STUDYHUB_LEARNING_DATA_SOURCE = "prisma"
npm run dev
```

With the backend running, check the health endpoint and seeded Learning reads:

```powershell
curl.exe "http://localhost:3000/health"
curl.exe "http://localhost:3000/learning/subjects"
curl.exe "http://localhost:3000/learning/subjects/subject_database/question-sets"
curl.exe "http://localhost:3000/learning/question-sets/question_set_database/questions"
```

Pre-submit question responses must not contain `isCorrect`, `correctAnswer`, or
`correctAnswerOptionId`.

Submit the seeded Database Fundamentals quiz:

```powershell
$body = @{
  selectedAnswerOptionIdsByQuestionId = @{
    question_database_1 = "db_1_a"
    question_database_2 = "db_2_b"
    question_database_3 = "db_3_c"
  }
} | ConvertTo-Json -Compress

$body | curl.exe --request POST `
  "http://localhost:3000/learning/question-sets/question_set_database/submit" `
  --header "Content-Type: application/json" `
  --data-binary "@-"
```

The response should contain a backend-calculated score and post-submit
`answerReviews`. Correctness metadata is allowed there because submission has
completed.

### Automated Prisma smoke test

The automated smoke test performs the same seeded Learning checks in-process,
so a separate backend server is not required. It requires a migrated and seeded
local PostgreSQL database plus `DATABASE_URL` in the current environment or the
ignored local `backend/.env` file.

```text
npm run build
npm run test:prisma-smoke
```

The script forces Prisma mode, verifies that pre-submit questions do not expose
correctness metadata, and checks a 100% seeded quiz submission. Normal
`npm test` remains memory-only and does not require PostgreSQL.

Never commit `backend/.env` or its database credentials.
