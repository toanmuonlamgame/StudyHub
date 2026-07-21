# StudyHub - Mobile Learning Platform

A Flutter + Fastify learning platform for structured study, quizzes, and future
user-uploaded and AI-assisted learning.

StudyHub is an active learning and portfolio project focused on a polished mobile
experience, clear architecture boundaries, safe quiz scoring, and a roadmap that
grows from a small learning loop into trusted community content.

## Current Status

**Essential MVP feature-completion checkpoint**

Phase 1 is complete as a working learning foundation. See the
[Phase 1 checkpoint](docs/PHASE_1_CHECKPOINT.md) for completed capabilities,
safety guarantees, limitations, and Phase 2 entry criteria.

- Flutter learner app with English/Vietnamese UI and complete Exam/Practice flows.
- Fastify Learning API with typed service boundaries.
- Flutter API mode through `ApiLearningRepository`.
- PostgreSQL schema, Prisma migration, and repeatable seed foundation.
- Selectable backend data source: in-memory by default or Prisma/PostgreSQL.
- Automated memory/unit tests and an opt-in Prisma smoke-test script.
- Email/password registration and login with expiring opaque sessions.
- Account-owned attempts, contributions, and saved Question Sets.

## Implemented Features

### Learning Experience

- Browse Subjects and their Question Sets.
- Search Question Set titles, filter by topic, and load cursor pages in mock/API modes.
- Browse published Study Material metadata with search, subject/type/language
  filters, cursor pagination, and on-demand detail in mock/API modes.
- Switch between system, English, and Vietnamese interface languages with local persistence.
- Use Practice Mode for immediate per-question feedback without exposing answer keys in question payloads.
- View Question Set details and question counts.
- Complete a mobile Exam Mode session with retained previous/next navigation,
  protected exit, and clear unanswered-question submission.
- View rounded score, correct/wrong/unanswered counts, answer options, correct
  answers, and optional explanations after submission.
- Persist completed Exam attempts with server-verified scoring and idempotent retry.
- Browse newest-first Exam history and reopen full snapshot-based answer review.
- Navigate the full Home -> Subjects -> Question Sets -> Quiz -> Result flow.

### Frontend Architecture

- `LearningRepository` abstraction between Flutter screens and data sources.
- `MockLearningRepository` for the default local prototype.
- `ApiLearningRepository` for the Fastify Learning API.
- `AttemptRepository` with mock/API adapters for save, history, and result detail.
- Compile-time mock/API selection through non-secret `dart-define` values.

### Accounts And Community Content

- Register, sign in, restore a session, edit a display name, and log out.
- Save and remove Question Sets, then reopen them from Home or Settings.
- Create, edit, delete, and submit owned contribution drafts.
- Track `draft`, `pendingReview`, `approved`, and `rejected` states, including
  rejection notes returned by a future controlled review process.

### Backend And Persistence

- Fastify Learning API for Subjects, Topics, Question Sets, Questions, and quiz
  submission.
- Backend-owned Exam attempt persistence with authenticated ownership,
  transaction-safe answer snapshots, and duplicate-request protection.
- `LearningService` abstraction with `InMemoryLearningService` and
  `PrismaLearningService` implementations.
- PostgreSQL models for Subjects, Topics, Question Sets, Questions, and Answer
  Options.
- Prisma migration, repeatable seed data, validation, and smoke-test tooling.
- Fastify injection tests for routes and focused service/mapper tests.

### Answer Safety

Pre-submit question responses contain only question and option display data.
Correct answers and `isCorrect` remain backend-owned until quiz submission, and
the backend calculates the score and answer review.

## Planned Features

- Auth-backed cross-device progress sync and measured feedback polish.
- User-uploaded Study Materials with binary storage, validation, ownership, and moderation.
- AI-assisted question extraction with source provenance, citations, and human
  review before publication.
- More advanced ranked search and measured caching for growing public content.
- User progress, targeted review, and carefully designed streaks.
- React + TypeScript Admin Dashboard for future moderation workflows.
- Study Credits and content unlocks in a later roadmap phase.
- Google Cloud deployment after local product and security foundations are ready.

## Tech Stack

| Area | Technology |
| --- | --- |
| Mobile frontend | Flutter, Dart |
| Backend runtime | Node.js |
| Backend language | TypeScript |
| API framework | Fastify |
| Database access | Prisma |
| Database | PostgreSQL |
| Future admin | React, TypeScript |
| Future deployment | Google Cloud |

## Architecture Overview

```text
Flutter App
  -> AuthController / authenticated session
  -> LearningRepository
     -> MockLearningRepository
     -> ApiLearningRepository
        -> Fastify API
           -> LearningService
              -> InMemoryLearningService
              -> PrismaLearningService
                 -> PostgreSQL
```

Protected attempt, contribution, and bookmark routes derive identity from the
verified bearer session. Flutter never sends a trusted user ID.

The Flutter app never accesses PostgreSQL directly. Repositories isolate UI from
data sources, while backend routes depend on service contracts rather than raw
mock data or database rows. The backend remains a modular monolith.

## Local Development

### Backend

```bash
cd backend
npm install
npm run dev
npm test
```

See [backend/README.md](backend/README.md) for Prisma setup, migrations, seed
commands, data-source selection, and smoke testing.

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

See [frontend/README.md](frontend/README.md) for Flutter mock/API configuration
and Android emulator networking.

The complete build, environment, signing, migration, and physical-device
checklist is in [Android MVP release readiness](docs/RELEASE_READINESS.md).

## API And Data Modes

### Flutter

- **Mock mode is the default:** Flutter uses `MockLearningRepository`.
- **API mode:** pass non-secret compile-time configuration:

```bash
flutter run \
  --dart-define=STUDYHUB_LEARNING_SOURCE=api \
  --dart-define=STUDYHUB_API_BASE_URL=http://10.0.2.2:3000
```

### Backend

- **Development memory mode is the default:** no PostgreSQL connection is required.
- **Prisma mode:** provide a local `DATABASE_URL` and select the data source:

```powershell
$env:DATABASE_URL = "<your local DATABASE_URL>"
$env:STUDYHUB_LEARNING_DATA_SOURCE = "prisma"
npm run dev
```

`backend/.env` is local-only, ignored by Git, and must never be committed.
Normal `npm test` remains database-independent; `npm run test:prisma-smoke` is
the explicit local PostgreSQL verification command.

Production requires `NODE_ENV=production`, an explicit Prisma data source, and
`DATABASE_URL`. Flutter release builds require API mode and an explicit HTTPS
API origin; they cannot use mock mode or the emulator URL.

## Quality And Performance Principles

- StudyHub should be polished, modern, motivating, and feature-rich by roadmap.
- Performance-aware implementation should remove unnecessary work, not valuable
  features or purposeful visual polish.
- Load data by screen with small endpoint-specific payloads and responsive
  loading, empty, error, and retry states.
- Use lazy loading now, then pagination and measured caching as data grows.
- Keep animations lightweight, purposeful, non-blocking, and respectful of
  reduced-motion preferences.
- Track app size, startup, perceived loading, smoothness, and API latency as the
  product matures.

The complete review standard is documented in
[docs/QUALITY_SYSTEM.md](docs/QUALITY_SYSTEM.md).

## Security Notes

- No API keys, passwords, tokens, or database credentials belong in the repo.
- Local `.env` files are ignored and example configuration uses placeholders.
- Flutter calls approved backend APIs and never calls the database directly.
- Passwords are salted and hashed with Node's `scrypt`; opaque session tokens
  are stored hashed in PostgreSQL and expire after a bounded lifetime.
- Attempt history, contributions, and bookmarks are scoped to the authenticated user.
- Correctness metadata is not exposed before quiz submission.
- The backend owns scoring and remains the future source of truth for identity,
  permissions, moderation, credits, rewards, and content access.

## Portfolio Highlights

- Clean repository pattern in Flutter with swappable mock and API adapters.
- Backend service abstraction with selectable in-memory and Prisma data sources.
- Testable Fastify routes and Prisma-independent normal test suite.
- PostgreSQL schema, migration, repeatable seed, and automated Prisma smoke test.
- Explicit pre-submit/post-submit answer safety boundary.
- Moderation-ready community Question Set submissions with local drafts,
  structured validation, and published-only learner visibility.
- Fast manual Question Set creation plus a validated full-exam paste workflow
  with preview, line-aware errors, and canonical structured tags.
- Research-informed roadmap and a reusable UX/performance quality system.
- Architecture prepared for growth without premature microservices or extra app
  stacks.

## Documentation

- [Phase 1 checkpoint](docs/PHASE_1_CHECKPOINT.md)
- [Project architecture](docs/ARCHITECTURE.md)
- [Confirmed technology stack](docs/TECH_STACK.md)
- [Product research](docs/PRODUCT_RESEARCH.md)
- [Architecture lessons](docs/ARCHITECTURE_LESSONS.md)
- [Quality system](docs/QUALITY_SYSTEM.md)
- [Android MVP release readiness](docs/RELEASE_READINESS.md)
- [Frontend development guide](frontend/README.md)
- [Backend development guide](backend/README.md)

## Roadmap Philosophy

V1 proves the core learning loop. V2 adds trusted contribution, moderation, and
Practice Mode foundations. V3 explores source-grounded AI study aids and later
economy/monetization options. Useful complexity is added when the product and
measurements justify it, not simply because a larger platform uses it.
