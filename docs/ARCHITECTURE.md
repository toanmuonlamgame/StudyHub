# StudyHub Architecture

## Architecture Status
StudyHub is in the foundation / planning phase. The architecture should stay simple and support the V1 learning flow before adding marketplace, credit economy, AI, or complex moderation features.

## High-Level Flow
```text
Flutter App -> Backend API -> Database
```

The Flutter app must never call the database directly.

## Security Boundary
The backend is the source of truth for security-sensitive behavior.

Frontend is not the source of truth for:

- Account data.
- Roles.
- Admin/moderator permissions.
- Study Credits.
- Rewards.
- Content unlocks.
- Database logic.

Backend is the source of truth for:

- Authentication.
- Authorization.
- Roles and permissions.
- Admin/moderator actions.
- Upload validation.
- Content access.
- Study Credit transactions.
- Reward calculation.
- Audit logs.
- Rate limiting.

The frontend should only render UI from backend responses and call approved backend APIs.

## Trust Rules
- Backend must not trust userId, role, credit amount, unlock status, or reward requests sent by the frontend.
- Backend must derive the acting user from verified authentication context when real auth is added.
- Database secrets, JWT secrets, admin keys, service keys, and production secrets must not be stored in the Flutter app or committed to GitHub.
- Credit and reward logic must be controlled by backend transactions and audit logs.

## Exam Attempt History Boundary

After Exam scoring succeeds, Flutter sends selected option IDs and a stable
submission ID to the attempt endpoint. The backend recalculates the score and
persists the attempt plus review snapshots in one transaction. The API never
accepts a trusted client score or user ID.

Until authentication exists, one backend identity provider returns the temporary
`demo-user`. Attempt service methods always receive that identity and filter
list/detail reads by owner. `(userId, submissionId)` provides idempotent retry,
and a canonical request fingerprint rejects reuse of a key with changed data.
Question and answer snapshots preserve historical meaning if published community
content changes; the optional source Question Set relation uses `SET NULL`.

Flutter keeps this backend Exam history separate from device-local Progress
summaries. Practice sessions remain local until an authenticated persistence
contract is designed.

## Contribution Retry Boundary

Flutter's atomic contribution request includes a stable client `submissionId`
plus creator content. It does not include a trusted user identity. The Fastify
route derives the current temporary identity, validates the payload, and passes
it to the selected `LearningService`.

Memory and Prisma services fingerprint normalized content. An identical retry
returns the same pending-review submission; the same ID with changed content
returns `409`. Prisma stores the key and fingerprint on `QuestionSet` and writes
the Question Set, Questions, and Answer Options in one transaction. Published
learner APIs continue to hide pending-review submissions and all pre-submit
correctness metadata.

## Flutter Runtime Configuration

Debug and test builds may default to mock mode. A release build must explicitly
set `STUDYHUB_LEARNING_SOURCE`; release API mode must also set
`STUDYHUB_API_BASE_URL`. This prevents silent fixture fallback and accidental
use of the Android-emulator loopback URL outside development.

## V1 Architecture
V1 should support:

- Basic flexible taxonomy.
- Required Subject.
- Optional school, program/system, major, and topic.
- Browsing Question Sets by subject/topic.
- Simple multiple-choice quiz.
- Quiz result calculation.
- Upload placeholder with basic metadata.
- Local/demo auth only.

Real authentication is deferred to the backend phase, but V1 should still avoid patterns that conflict with the security boundary.

## Frontend Learning Repository Seam
The current Flutter folder structure is suitable for V1 and does not need a broad rewrite.

```text
frontend/lib/
├── app/                         # App composition and top-level wiring
├── core/                        # Shared theme and future cross-feature utilities
└── features/
    ├── home_placeholder.dart    # Current Home screen; rename can wait
    └── learning/
        ├── models/              # Learning data used by the UI
        ├── data/                # Mock constants now; remote data source later
        ├── repositories/        # Repository interface and adapters
        └── screens/             # Learning UI and navigation
```

Keep the existing models, screens, and `mock_learning_data.dart`. Add `repositories/` only when implementing the migration. Renaming or moving Home is optional cleanup and is not required for backend integration.

### Current Dependency Status
The repository migration is complete for the active learner flow. Subject,
Question Set, quiz, answer-check, submission, search, topic filtering, and cursor
pagination operations all pass through `LearningRepository`. Screens do not
import `mock_learning_data.dart` directly.

`StudyHubApp` remains the composition root for the selected learning repository
and the app-level interface locale. Locale state is independent of learning
content: ARB resources translate system UI, while repository content remains
unchanged.

### Target Dependency Direction
Use a repository seam so screens depend on one small interface instead of a concrete data source.

```text
StudyHubApp composition root
            |
            v
Learning screens -> LearningRepository -> MockLearningRepository -> Mock data
                                      \-> ApiLearningRepository  -> API service
```

Rules:

- Learning models do not import screens, repositories, or data sources.
- Screens import models, peer screens, and the `LearningRepository` interface only.
- Screens must not import `mock_learning_data.dart` after the repository migration.
- Mock and API repository adapters may import their own data sources.
- `StudyHubApp` is the composition root that chooses and injects the active adapter.
- Use constructor injection; do not add a state-management or dependency-injection package for this seam.

### Repository Interface Direction
The future repository interface should express user-facing learning operations, not expose raw lists or transport details. A conceptual shape is:

```text
LearningRepository
- getSubjects()
- getTopicsBySubjectId(subjectId)
- getQuestionSetsBySubjectId(subjectId)
- getQuestionsByQuestionSetId(questionSetId)
- submitQuiz(questionSetId, selectedAnswerIds)
- checkAnswer(questionId, selectedAnswerOptionId)
```

Repository operations should return `Future` values from the start so the mock adapter and API adapter share the same interface. The mock adapter can return local values immediately through `Future.value`. Screens can use simple Flutter loading/error state without a new package.

### Quiz Answer Safety
Pre-submit and post-submit quiz data use separate public models.

- Pre-submit `AnswerOption` exposes only `id` and `text`.
- `Question` contains only quiz-safe answer options and does not expose correctness metadata.
- `MockLearningRepository` keeps its answer key private and uses it for local demo scoring.
- `submitQuiz(...)` returns a `QuizResult` containing score totals and post-submit `AnswerReview` records.
- `QuizResultScreen` renders `AnswerReview` data and does not infer correctness from pre-submit questions.
- `ApiLearningRepository.submitQuiz(...)` sends selected option IDs to the backend and maps the returned review data.
- The backend should calculate the authoritative score and return result/review data after submission.

Exam Mode reveals correctness only after the whole quiz is submitted. Practice Mode uses a separate `checkAnswer` operation and reveals correctness only for the question the learner has explicitly checked. Both modes consume the same correctness-free question payload.

The backend Learning API exposes:

```text
POST /learning/questions/:questionId/check-answer
```

The request contains only `selectedAnswerOptionId`. The response may contain the selected and correct option details for that question. Unknown questions return `404`, options outside the question return `400`, and answer-key integrity failures return `500`.

### Incremental Migration
1. Add the `LearningRepository` interface and `MockLearningRepository` adapter.
2. Move mock filtering and local quiz scoring behind the mock adapter while keeping `mock_learning_data.dart` as raw fixture data.
3. Inject the repository from `StudyHubApp` through existing screen constructors.
4. Replace direct mock imports in one screen at a time, preserving current widget tests.
5. Separate pre-submit answer options from post-submit answer review data.
6. Use `ApiLearningRepository` to map the mock Learning API into frontend models. Keep mock as the default source and enable API mode only through non-secret `dart-define` configuration.

This sequence changes the data source without rewriting screen layout or navigation.

## V1 API Boundaries
API means backend code written for Flutter to call. It is not a programming language and not a third-party service.

V1 API flow:

```text
Flutter App -> Backend API -> Database
```

The backend owns validation, scoring, user context, and database writes. Flutter must not call the database directly and must not send trusted score, userId, role, credit, unlock, or reward values.

### V1 Endpoints
```text
GET  /health

GET  /subjects
GET  /topics?subjectId=sub_1

GET  /question-sets?subjectId=sub_1&topicId=topic_1
GET  /question-sets/:id

POST /quiz-attempts
POST /quiz-attempts/:attemptId/submit
GET  /quiz-attempts/:attemptId/result

POST /study-material-uploads
```

### Response Safety
- `GET /question-sets/:id` returns questions and answer options only.
- `GET /question-sets/:id` must not return `isCorrect` or `correctAnswerOptionId`.
- Correct answers are exposed only after whole-quiz submission in Exam Mode or a per-question `check-answer` response in Practice Mode.
- Backend calculates score. Flutter does not send score.

### Quiz API Shape
Use the standard two-step quiz flow:

```text
POST /quiz-attempts
POST /quiz-attempts/:attemptId/submit
GET  /quiz-attempts/:attemptId/result
```

This is slightly more work than a single submit endpoint, but it prepares V1 for in-progress attempts, continuing a quiz later, and quiz history.

### Upload API Shape
Use:

```text
POST /study-material-uploads
```

V1 upload is a metadata placeholder. V1 does not need real file storage. If Flutter lets the user select a file in the UI, V1 does not process production storage yet.

### Status Fields
QuestionSet and StudyMaterialUpload should include simple status fields so later moderation can fit without reshaping the model.

Suggested statuses:

- `draft`
- `published`
- `pending_review`
- `rejected`

V1 can keep behavior simple while still storing a status.

### Optional Taxonomy Endpoint
V1 can keep separate endpoints:

```text
GET /subjects
GET /topics?subjectId=sub_1
```

If Flutter needs simpler screen loading, add:

```text
GET /taxonomy
```

`GET /taxonomy` should return the basic subject/topic structure. It is optional for V1, not required.

## Minimal V1 Data Model
- User
- Subject
- Topic
- QuestionSet
- Question
- AnswerOption
- QuizAttempt
- QuizAttemptAnswer
- StudyMaterialUpload

## Persistence Foundation
The backend now includes a Prisma schema for PostgreSQL with Subject, Topic,
QuestionSet, Question, and AnswerOption relations. `AnswerOption.isCorrect`
is database/internal data and must not appear in pre-submit API responses.

The Prisma seed foundation maps the existing mock Learning fixtures into the
database in dependency order using stable IDs and upserts. Seeding is an opt-in
local command and is not required by backend tests.

Learning routes now depend on a `LearningService` interface. The default
`InMemoryLearningService` preserves the current local API behavior, while
`PrismaLearningService` provides the selectable database adapter. Prisma uses
explicit mappers instead of returning raw rows, keeps correctness metadata
internal before quiz submission, and accepts a client dependency for tests.

The data source defaults to memory and does not create a Prisma client unless
Prisma is explicitly selected. The initial local PostgreSQL migration and seed
have run successfully, and Prisma-mode read endpoints have passed a manual smoke
test without exposing correctness metadata. Prisma-mode quiz submission has also
been verified with seeded answers, including backend-calculated scoring and
post-submit answer reviews. A future automated integration suite should use a
separate PostgreSQL test database.

## Content Model Notes
Study Material and Question Set are separate content types.

StudyMaterialUpload represents the V1 upload placeholder for documents, exams, question sets, or related learning material metadata. It should leave room for later moderation, conversion, duplicate detection, and AI-assisted question generation.

## Deferred Architecture
V1 should not implement:

- Full Study Credits economy.
- Content unlock system.
- Ads or payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

## Data Growth Standard
Growing list and search workflows must use backend-side filtering, stable cursor
pagination, compact DTOs, and indexed PostgreSQL queries. Flutter should request
only the slice required by the current screen and fetch detail on demand.

The first paginated endpoint is now available without replacing the existing
subject-specific endpoint:

```text
GET /learning/question-sets?subjectId=...&topicId=...&q=...&limit=20&cursor=...
```

It returns `{ items, nextCursor, hasMore }`, uses stable `createdAt + id`
ordering, enforces a maximum limit of 50, and returns metadata without questions
or answers. Memory and Prisma services implement the same contract.

See [SCALABILITY_AND_SEARCH.md](SCALABILITY_AND_SEARCH.md) for the list contract,
indexing plan, search progression, caching boundaries, and analytics strategy.

These belong in later phases after the core learning loop works.

## Study Materials Foundation
Study Materials use the existing replaceable data-source boundaries:

```text
Flutter StudyMaterial screens
  -> LearningRepository
  -> MockLearningRepository / ApiLearningRepository
  -> Fastify Learning routes
  -> LearningService
  -> InMemoryLearningService / PrismaLearningService
  -> PostgreSQL
```

Public APIs are metadata-first:

```text
GET /learning/materials?subjectId=...&topicId=...&q=...&materialType=...&language=...&limit=20&cursor=...
GET /learning/materials/:materialId
```

Lists use stable `createdAt + id` cursor ordering, default to 20, cap at 50,
and return only published compact items. Detail is fetched only when opened.
Draft, pending-review, rejected, moderation, and ownership data remain internal.
The current uploaded-file source is metadata only; no binary upload or cloud
delivery is implemented.

## Community Question Bank Boundary

```text
Flutter creator screens -> ContributionRepository
  -> MockContributionRepository / ApiContributionRepository
  -> Fastify submission routes -> LearningService
  -> InMemoryLearningService / PrismaLearningService -> PostgreSQL
```

Creator DTOs are separate from learner DTOs. Flutter composes a bounded local
draft and performs one final atomic submit-for-review request. The backend owns
validation and lifecycle (`draft -> pendingReview -> published/rejected`). Only
`published` sets can enter learner browse, search, detail, questions,
`checkAnswer`, or `submitQuiz` paths.

`createdByUserId` is nullable until real authentication exists. Submission
endpoints are a development foundation, not proof of creator ownership. Public
unauthenticated approve/reject routes are prohibited.

Submission validation bounds each set to 50 questions and each question to 8
answer options. Prisma edit and submit transitions conditionally lock the draft
state inside a transaction so a concurrent state change cannot leave partial
question data.
