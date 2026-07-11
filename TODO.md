# StudyHub TODO

## Current Phase
Foundation / planning.

## Active
- [x] Confirm product type: mobile learning platform.
- [x] Confirm project goal: learning project and internship portfolio.
- [x] Confirm frontend stack: Flutter / Dart.
- [x] Confirm backend stack: Node.js.
- [x] Confirm database: PostgreSQL.
- [x] Confirm AI workflow roles.
- [x] Confirm flexible taxonomy direction.
- [x] Confirm Study Material and Question Set as separate content types.
- [x] Confirm user upload and community contribution direction.
- [x] Confirm admin may create a small amount of legal seed content.
- [x] Confirm Study Credits are internal only and not withdrawable as real money.
- [x] Define V1 milestone scope in detail.
- [x] Decide authentication approach for V1: local/demo auth only.
- [x] Decide required taxonomy field for V1: Subject.
- [x] Decide optional taxonomy fields for V1: school, program/system, major, topic.
- [x] Decide backend language for V1: TypeScript.
- [x] Decide Node.js API framework: Fastify.
- [x] Decide PostgreSQL access layer / ORM: Prisma.
- [ ] Decide deployment target.
- [ ] Configure GitHub remote.

## V1 Checklist
### Taxonomy And Browsing
- [ ] Create basic flexible taxonomy model for V1.
- [ ] Make Subject required for Question Sets and uploads.
- [ ] Keep school optional in V1.
- [ ] Keep program/system optional in V1.
- [ ] Keep major optional in V1.
- [ ] Keep topic optional in V1.
- [ ] Browse Question Sets by subject.
- [ ] Browse/filter Question Sets by topic when topic exists.

### Quiz Flow
- [ ] Start a simple multiple-choice quiz from a Question Set.
- [ ] Display one or more answer options per question.
- [ ] Record selected answers in a QuizAttempt.
- [ ] Calculate correct count.
- [ ] Calculate wrong count.
- [ ] Calculate percentage score.
- [ ] Show correct answers on the result screen.

### Upload Placeholder
- [ ] Add upload placeholder for document/exam/question set.
- [ ] Capture basic upload metadata.
- [ ] Store upload as StudyMaterialUpload.
- [ ] Keep moderation simple for V1.

### Local/Demo Auth
- [ ] Use local/demo auth for V1 only.
- [ ] Do not implement production authentication in V1.
- [ ] Keep real authentication deferred to the backend phase.

### Minimal V1 Data Model
- [ ] User
- [ ] Subject
- [ ] Topic
- [ ] QuestionSet
- [ ] Question
- [ ] AnswerOption
- [ ] QuizAttempt
- [ ] QuizAttemptAnswer
- [ ] StudyMaterialUpload

## Near-Term Tasks
- [ ] Decide deployment target.
- [x] Define V1 API boundaries using the security rules in ReadBeforeWork.md.
- [x] Create first milestone implementation checklist.
- [ ] Learn JavaScript fundamentals needed for the StudyHub backend.
- [ ] Learn TypeScript fundamentals needed for the StudyHub backend.
- [ ] Learn Fastify basics for routing, validation, and plugins.
- [ ] Learn Prisma basics for schema, migrations, and PostgreSQL queries.

## Frontend V1 Mock Learning Flow Checklist
Build this frontend-only mock flow in small, reviewable commits. Keep data local so the UI flow can be proven before backend integration.

### Commit 1 - Define Mock Models
- [ ] Define a minimal immutable `Subject` model.
- [ ] Define a minimal immutable `Topic` model with a Subject relationship.
- [ ] Define a minimal immutable `QuestionSet` model with required Subject and optional Topic.
- [ ] Define a minimal immutable `Question` model.
- [ ] Define a minimal immutable `AnswerOption` model.
- [ ] Define a minimal immutable `QuizResult` model with correct count, wrong count, percentage score, and answer review data.
- [ ] Keep model fields limited to what the mock learning flow uses.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 2 - Add Mock Learning Data
- [ ] Add 2-3 mock Subjects.
- [ ] Add 1-2 mock Question Sets for each Subject.
- [ ] Add a few multiple-choice Questions to each Question Set.
- [ ] Give each Question several Answer Options with one correct option.
- [ ] Include optional Topic data where useful without requiring it.
- [ ] Add tests that verify mock data relationships and required fields.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 3 - Home And Subject List
- [ ] Update Home to provide a clear entry into the mock learning flow.
- [ ] Add a Subject list screen using mock Subjects.
- [ ] Show simple empty-state handling even though initial mock data is present.
- [ ] Add widget tests for Home and Subject list rendering.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 4 - Question Set Browsing
- [ ] Add a Question Set list screen filtered by the selected Subject.
- [ ] Show optional Topic metadata only when it exists.
- [ ] Add a Question Set detail screen with title, subject/topic metadata, and question count.
- [ ] Do not expose correct answers on the detail screen.
- [ ] Add widget tests for Question Set list and detail rendering.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 5 - Simple Quiz Screen
- [ ] Add a Quiz screen for one mock Question Set.
- [ ] Display each question with multiple-choice Answer Options.
- [ ] Store selected answers in local screen state only.
- [ ] Require an answer for each question before submission, with simple user feedback.
- [ ] Calculate the mock result locally only for this frontend phase.
- [ ] Add widget tests for selecting answers and submitting a quiz.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 6 - Result Screen
- [ ] Add a Result screen driven by `QuizResult`.
- [ ] Show correct count, wrong count, and percentage score.
- [ ] Show the correct answers and the user's selected answers.
- [ ] Add a simple action to return to the learning flow.
- [ ] Add widget tests for score summary and answer review.
- [ ] Run `flutter analyze` and relevant tests before commit.

### Commit 7 - Complete Mock Navigation
- [ ] Connect Home -> Subjects.
- [ ] Connect Subjects -> Question Sets.
- [ ] Connect Question Sets -> Question Set Detail.
- [ ] Connect Question Set Detail -> Quiz.
- [ ] Connect Quiz -> Result.
- [ ] Verify back navigation does not lose the selected Subject or Question Set unexpectedly.
- [ ] Add a widget test covering the full mock learning path.
- [ ] Run `flutter analyze` and `flutter test` before commit.

### Frontend Mock Flow Constraints
- [ ] Do not connect to a backend yet.
- [ ] Do not implement real authentication.
- [ ] Do not implement real file upload; keep upload as a placeholder only.
- [ ] Do not implement Study Credits or any credit economy behavior.
- [ ] Do not add packages unless explicitly approved.
- [ ] Keep Flutter separate from the future database; later integration must use Backend APIs.
- [ ] Keep the structure simple and avoid abstractions that the mock flow does not need.

## Frontend Repository Migration Checklist
- [x] Review current Flutter folder structure and learning dependencies.
- [x] Decide on a `LearningRepository` seam with mock and API adapters.
- [x] Decide to use constructor injection without a new package.
- [x] Add `features/learning/repositories/learning_repository.dart`.
- [x] Add `MockLearningRepository` backed by existing mock data.
- [ ] Move mock filtering helpers behind `MockLearningRepository`.
- [x] Add the `submitQuiz` contract to `LearningRepository`.
- [x] Move local mock quiz scoring behind `MockLearningRepository`.
- [x] Make repository operations asynchronous to match future network behavior.
- [x] Inject the repository from `StudyHubApp` as the composition root.
- [x] Migrate `SubjectListScreen` to load data through `LearningRepository`.
- [ ] Remove direct mock-data imports from learning screens one screen at a time.
- [ ] Add simple loading and error states using Flutter SDK tools only.
- [x] Separate safe pre-submit answer options from mock-only correctness metadata.
- [x] Define post-submit answer review data returned by `submitQuiz`.
- [x] Harden the Exam Mode foundation and result-review contract.
- [x] Implement Practice Mode and a `checkAnswer` contract after Exam Mode stabilization.
- [x] Add repository contract tests using the mock adapter.
- [x] Add an unwired `ApiLearningRepository` skeleton.
- [x] Implement `ApiLearningRepository` against the mock Fastify Learning API.
- [x] Keep mock as default and add non-secret `dart-define` API mode.
- [x] Pass the Flutter API mode smoke test on a real device over LAN.
- Tested real-device backend base URL: `http://192.168.1.12:3000`.
- Android emulator backend base URL: `http://10.0.2.2:3000`.

## Backend Foundation
- [x] Create the minimal Node.js, TypeScript, and Fastify backend skeleton.
- [x] Add dev, build, start, and typecheck scripts.
- [x] Add the backend health endpoint.
- [x] Add an automated Fastify injection test for the health endpoint.
- [x] Complete the mock/in-memory backend Learning API phase.
- [x] Create the Prisma/PostgreSQL schema and tooling foundation.
- [x] Add the Prisma seed foundation from the mock Learning data.
- [x] Add the unwired Prisma-backed Learning service and mapping foundation.
- [x] Make Learning routes depend on a selectable `LearningService` adapter.
- [x] Document the Prisma local mode checklist and safe configuration steps.
- [x] Run local PostgreSQL migration, seed, and Prisma read-endpoint smoke tests.
- [x] Smoke-test quiz submit in Prisma mode and verify score/answer reviews.
- [x] Add an opt-in automated Prisma Learning API smoke-test script.
- [ ] Consider backend integration tests using a dedicated PostgreSQL test database.
- [x] Implement the Flutter `ApiLearningRepository` against the mock Learning API.

## Research-Informed Roadmap
- [x] Define and implement a Practice Mode `checkAnswer` backend contract while preserving Exam Mode behavior.
- [ ] Implement secure user-upload Study Materials with metadata, validation, and ownership.
- [ ] Add moderation/reporting before uploaded materials become broadly discoverable.
- [ ] Add AI-assisted question extraction from user sources in V3 with citations, provenance, and human review.
- [ ] Build a React Admin Dashboard later for real moderation and content operations, not as the learner app.
- [x] Define and apply initial UI polish guidelines for clarity, motivation, accessibility, and visual consistency.
- [ ] Define an animation budget covering purpose, duration, smoothness, and reduced-motion behavior.
- [ ] Add a performance checklist before major feature commits.
- [ ] Later measure release app size, startup time, perceived loading, smoothness, and API latency on representative devices.
- [ ] Add API pagination before community content lists grow large.
- [ ] Add measured caching later for stable, read-heavy taxonomy and published content.
- [ ] Reassess microservices only when scale, ownership, or independent deployment provides clear evidence.

## Quality System Applied Tasks
- [x] Restructure the Flutter learner flow into focused Home, browse, detail, mode, quiz, and result screens.
- [x] Apply the quality and security checklist to the Practice Mode foundation.
- [ ] Polish Practice Mode progress, accessibility, and feedback after user testing.
- [ ] Decide whether Practice Mode history belongs in V2 user progress.
- [ ] Apply the frontend performance checklist before major UI feature commits.
- [x] Add the first backend API pagination contract for Question Sets.
- [ ] Add measured caching later for read-heavy public learning content.

## Scalability And Search
- [x] Add a paginated Question Set list endpoint with stable cursor ordering.
- [ ] Migrate Flutter Question Set browsing to consume the paginated endpoint.
- [ ] Add a paginated Study Material list endpoint when the content model is implemented.
- [ ] Add query-driven Prisma indexes for list and search filters.
- [ ] Add validated PostgreSQL-first search query support.
- [ ] Add debounced search and stale-response handling in Flutter.
- [ ] Add measured caching later for read-heavy public taxonomy/content metadata.
- [ ] Add analytics summary tables or materialized views before considering a warehouse.
- [ ] Measure release app size, startup, and perceived loading on representative devices later.

## V1 API Checklist
- [x] Implement `GET /health`.
- [ ] Implement `GET /subjects`.
- [ ] Implement `GET /topics?subjectId=...`.
- [ ] Implement `GET /question-sets?subjectId=...&topicId=...`.
- [ ] Implement `GET /question-sets/:id` without exposing `isCorrect` or `correctAnswerOptionId`.
- [ ] Implement `POST /quiz-attempts`.
- [ ] Implement `POST /quiz-attempts/:attemptId/submit`.
- [ ] Implement `GET /quiz-attempts/:attemptId/result`.
- [ ] Implement `POST /study-material-uploads` as metadata placeholder.
- [ ] Ensure backend calculates quiz score.
- [ ] Ensure Flutter does not send trusted `score` or `userId`.
- [ ] Consider optional `GET /taxonomy` only if Flutter screen loading needs it.

## Roadmap
### V1 - Core Learning Flow
- [ ] Basic flexible taxonomy: school, program/system, major, subject, topic.
- [ ] Browse question sets.
- [ ] Take quiz from a question set.
- [ ] View quiz result.
- [ ] Upload study material, exam, or question set.
- [ ] Use local/demo auth only.
- [ ] Keep Study Credits out of V1 except as future-facing terminology if needed.

### V2 - Community Quality And Unlocks
- [ ] Contributor profile.
- [ ] Rating and report system.
- [ ] Duplicate content prevention.
- [ ] Study Credits.
- [ ] Unlock selected content or features using Study Credits.
- [ ] Reward valid, used, high-quality content instead of raw upload count.

### V3 - AI And Monetization Options
- [ ] AI-generated questions from uploaded documents.
- [ ] Human review step before AI-generated questions become available.
- [ ] Ads-for-credit flow.
- [ ] Consider payments after the credit model and content quality loop are proven.

## Content Model Tasks
- [ ] Define Study Material fields.
- [ ] Define Question Set fields.
- [ ] Define how Study Material can be linked to generated or related Question Sets.
- [ ] Define contribution approval rules.
- [ ] Define quality signals for future rewards.
- [ ] Define duplicate detection requirements for V2.

## Documentation Tasks
- [ ] Create docs/PROJECT_OVERVIEW.md after review.
- [ ] Create docs/ARCHITECTURE.md after review.
- [ ] Create docs/TECH_STACK.md after review.
- [ ] Create docs/ROADMAP.md after review.

## Maintenance
- [ ] Keep PROJECT_MEMORY.md updated after important changes.
- [ ] Record architecture/product decisions in DECISIONS.md.
- [ ] Update TODO.md after finishing or changing a task.
- [ ] Commit small working changes.

## Not Doing Yet
- [ ] Do not create docs/ files until explicitly requested.
- [ ] Do not write app code until the first milestone is approved.
- [ ] Do not implement full credit economy in V1.
- [ ] Do not reward users only for uploading content.
- [ ] Do not implement content unlocks in V1.
- [ ] Do not implement ads in V1.
- [ ] Do not implement payments in V1.
- [ ] Do not implement AI question generation in V1.
- [ ] Do not implement marketplace in V1.
- [ ] Do not implement full admin dashboard in V1.
