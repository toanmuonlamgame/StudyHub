# StudyHub TODO

## Current Phase
Essential MVP feature completion is implemented in code. Authentication,
account ownership, profile/settings, contribution management, and saved
Question Sets are ready for migration and dedicated stabilization testing.

## Essential MVP Completion
- [x] Add register, login, logout, current-user, profile-update, and expiring
  session contracts for memory and Prisma modes.
- [x] Hash passwords and session tokens; never expose either stored hash.
- [x] Replace production `demo-user` identity with authenticated ownership.
- [x] Scope Exam attempt history/detail and contributions to the current user.
- [x] Add owned contribution draft list/edit/delete/submit lifecycle and status UI.
- [x] Add account-owned, duplicate-safe Question Set bookmarks and Saved UI.
- [x] Replace the Settings placeholder with functional account, language,
  app-version, privacy/security, Saved, profile, and logout destinations.
- [x] Keep existing search, subject/topic filters, clear, debounce, pagination,
  loading, empty, and retry behavior.
- [ ] Review and apply migration `20260722120000_auth_and_bookmarks` manually.
- [ ] Run Prisma-mode auth/ownership/bookmark/contribution smoke tests.
- [ ] Run real-device Flutter API journeys for registration, login, session
  restore, Saved, contribution management, attempt ownership, and logout.
- [ ] Add controlled moderator/admin review actions in the future Admin Dashboard.

## Real MVP Integration Checkpoint
- [x] Align Flutter contribution payloads with the atomic Fastify submission
  contract and keep one idempotency key across transport retries.
- [x] Derive temporary contribution ownership from the backend identity boundary.
- [x] Keep memory and Prisma contribution services behaviorally aligned.
- [x] Sanitize unexpected and data-integrity errors before they reach API clients.
- [x] Require explicit learning source and API URL configuration for release API builds.
- [x] Add automated coverage for contribution retry, release configuration, and
  backend error sanitization.
- [ ] Review and apply migration
  `20260721120000_question_set_submission_idempotency` manually after the two
  earlier pending MVP migrations.
- [ ] Run real Prisma smoke tests for contribution submit/retry and Exam attempt
  save/list/detail after all pending migrations are applied.
- [ ] Run the full Flutter API-mode journeys on a real device against PostgreSQL.

## Accelerated MVP Checkpoints
- [x] Checkpoint 1: Complete mobile Exam Session navigation, answer retention,
  protected exit, unanswered submission, backend scoring, and full Result Review.
- [x] Keep correct answers hidden until Exam submit or Practice check-answer.
- [x] Show correct, incorrect, and unanswered counts with answer options and
  optional explanations after submission.
- [x] Checkpoint 2: Persist completed Exam attempts with server-verified scoring,
  idempotent retry, snapshot review data, ownership filtering, and history detail.
- [x] Add Flutter attempt save loading/failure/retry states and an Attempt History
  entry from Progress without weakening device-local Practice summaries.
- [x] Checkpoint 3A: add one reusable completion-to-Home action that selects the
  Home tab, removes obsolete deep routes, and never pushes a duplicate Home.
- [x] Keep normal browsing Back behavior and active Exam discard confirmation.
- [x] Make app-level navigation, attempt, and progress scopes available to
  routes pushed above the shell.
- [x] Bound Learning, Contribution, and Attempt API requests with a 15-second
  timeout while preserving retryable screen state.
- [ ] Review and apply migration `20260717120000_exam_attempt_history` manually.
- [ ] Review and apply migration `20260715090000_question_set_submission_foundation`
  manually if it is not already present in the target database.
- [ ] Smoke-test save/list/detail in Prisma mode and one real Flutter API Exam.
- [ ] Smoke-test one real Flutter API manual contribution and one pasted-exam
  contribution after the submission migration is applied.
- [x] Replace the temporary backend demo identity boundary with authenticated ownership.

## Phase 1 Checkpoint
- [x] Complete the Flutter learner flow from Home through Result/Review.
- [x] Support Exam Mode and Practice Mode with protected correctness data.
- [x] Support Flutter mock/API and backend memory/Prisma modes.
- [x] Add PostgreSQL schema, migrations, seed, smoke test, pagination, and initial indexes.
- [x] Document Phase 1 capabilities, guarantees, limitations, and Phase 2 criteria.

## Phase 2 UI/UX Milestones
- [x] CM37: Polish the visual design system and responsive learner surfaces.
- [x] CM38: Add the mobile app shell, Practice summary, and lightweight learner micro-interactions.
- [x] CM39: Add English/Vietnamese localization with persisted language selection.
- [x] CM40: Add repository-driven search, topic filtering, and cursor load-more UI.
- [x] CM41: Add Study Materials metadata browsing across Flutter, memory API,
  Prisma, migration, seed, and smoke coverage.
- [x] Build the richer mobile Home hub, manual feature banners, destination
  shortcuts, honest Progress metrics, and structured Settings groups.
- [ ] Verify text scaling, accessibility semantics, and touch targets on representative devices.
- [ ] Manually review compact Android, common Android, and Chrome layouts before localization.
- [x] Respect the platform disable-animations preference in current custom learner animations.
- [x] Persist trusted completed Exam/Practice summaries and replace the Progress placeholder.

## Rich Learner UI Follow-Up
- [ ] Connect Home banners to reviewed, managed content with a safe local fallback.
- [x] Populate Progress metrics from persisted trusted completed sessions.
- [ ] Add authenticated backend progress sync and conflict handling after real auth exists.
- [x] Activate safe, published Study Materials metadata browsing from Home.
- [ ] Add authenticated material upload, ownership, storage, validation, and moderation.
- [ ] Manually verify Study Materials in mock/API mode on a real Android device.
- [x] Define and enable account-owned Saved Question Sets.
- [ ] Define a Learning Plans contract before enabling that post-MVP destination.
- [ ] Manually test Home banners and shortcuts on compact/common Android devices.
- [ ] Run TalkBack review for banner position, quick actions, upcoming features,
  Progress metrics, and disabled Settings preferences.

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
- Real-device LAN smoke test passed previously; use
  `http://<developer-computer-LAN-IP>:3000` because the address can change.
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
- [x] Include trusted completed Practice Mode summaries in device-local progress.
- [ ] Apply the frontend performance checklist before major UI feature commits.
- [x] Add the first backend API pagination contract for Question Sets.
- [ ] Add measured caching later for read-heavy public learning content.

## Scalability And Search
- [x] Add a paginated Question Set list endpoint with stable cursor ordering.
- [x] Migrate Flutter Question Set browsing to consume the first page of the paginated endpoint.
- [x] Add cursor load-more UI with separate next-page loading/error/retry states.
- [x] Add debounced Question Set title search and optional topic filtering.
- [x] Add a paginated Study Material list endpoint with published-only visibility.
- [x] Add initial query-driven Prisma indexes for learning filters and ordering.
- [ ] Evaluate PostgreSQL full-text or trigram indexes after search usage is measurable.
- [ ] Add validated PostgreSQL-first search query support.
- [x] Add debounced search, pagination reset, deduplication, and stale-response handling in Flutter.
- [ ] Manually verify English/Vietnamese UI at text scales 1.0, 1.3, and 1.5 on representative devices.
- [ ] Perform TalkBack/VoiceOver and keyboard-focus review before claiming accessibility compliance.
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

## Community Question Bank Foundation (Commit 42)
- [x] Add creator DTOs and centralized submission validation.
- [x] Add memory/Prisma draft, update, get, submit, and atomic final-submit services.
- [x] Keep non-published Question Sets hidden from all learner paths.
- [x] Prepare Prisma moderation schema, indexes, and unapplied migration SQL.
- [x] Add Flutter local-draft contribution flow with separate creator models.
- [x] Add mock/API ContributionRepository parity and structured API errors.
- [x] Add English/Vietnamese mobile creator UI and Home entry.
- [x] Add backend and Flutter regression tests.
- [ ] Manually review and apply the CM42 Prisma migration.
- [ ] Run Prisma/database smoke tests after the CM42 migration is applied.
- [ ] Test one real Flutter API-mode contribution against the local backend.
- [ ] Add authentication-backed ownership and server draft recovery.
- [ ] Build authorized moderation queue and approve/reject workflow.
- [ ] Add duplicate detection and contributor quality signals in V2.

## 2026-07-16 Work Package - Exam Creation And Visual System
- [x] Reduce manual creation friction with persistent mobile actions and clearer labels.
- [x] Add next-question, duplicate-question, and safe reset actions.
- [x] Preserve selected subject/topic when resetting the current draft.
- [x] Add a visible full-exam paste entry from intro and editor flows.
- [x] Parse canonical tags, multiline text, aliases, warnings, and per-question errors.
- [x] Preview recognized/valid/invalid counts before importing any questions.
- [x] Block partial import while severe parser errors remain.
- [x] Return valid parsed questions to the normal editor and existing submission API.
- [x] Add centralized visual color, spacing, and radius tokens.
- [x] Apply indigo, teal, and warm accents through the shared Material theme.
- [x] Add parser and contribution widget tests.
- [ ] Manually verify the editor with a real mobile keyboard on compact Android.
- [ ] Manually verify a full pasted Vietnamese exam in mock and API modes.

## MVP Stabilization (Commit 2)
- [x] Guard repeated attempt-history retry requests and stale repository reloads.
- [x] Guard repeated Practice completion and contribution confirmation actions.
- [x] Preserve drafts/results across recoverable API failures and retry with the same idempotency identity.
- [x] Make history states, contribution confirmation, and core dialogs usable on short screens with large text.
- [x] Lazy-render parsed question previews instead of building the full preview at once.
- [x] Reject blank contribution submission IDs and normalize attempt idempotency IDs at the backend boundary.
- [x] Re-audit learner/contribution strings for direct hard-coded UI text.
- [ ] Manually run the six core journeys on a compact Android device with the real backend.
- [ ] Apply pending Prisma migrations and run database/API smoke tests before release.

## MVP Release Readiness (Commit 3)
- [x] Set the Android app name, stable application ID, and MVP version metadata.
- [x] Add release Internet permission while limiting cleartext HTTP to debug builds.
- [x] Require API mode plus an explicit HTTPS origin for Flutter release builds.
- [x] Require explicit Prisma mode and DATABASE_URL for backend production startup.
- [x] Add production CORS allowlist, 1 MiB request limit, and graceful shutdown.
- [x] Add Prisma deploy script and safe release/device documentation.
- [x] Pass backend/Flutter automated checks and build local debug/release APK baselines.
- [ ] Replace the Flutter template launcher icon with final StudyHub branding.
- [ ] Configure a private production upload keystore outside Git.
- [ ] Deploy an HTTPS backend API and build the final API-connected release APK.
- [ ] Review/apply pending migrations and run Prisma smoke tests personally.
- [ ] Complete the iQOO Z9 Turbo checklist in `docs/RELEASE_READINESS.md`.

## UI/UX Research And Redesign
- [x] Audit Auth, Home, navigation, browsing, quiz, results, history, contribution, profile, settings, and shared states.
- [x] Expand shared visual, layout, icon, elevation, and motion tokens.
- [x] Replace repeated Home entry points with one primary CTA and real shortcuts.
- [x] Polish Auth hierarchy, keyboard safety, errors, loading, and honest social-auth status.
- [x] Unify learning loading, error, and empty states through a shared component.
- [x] Document conceptual references and adopted/rejected design principles.
- [ ] Replace the template launcher icon with approved StudyHub branding.
- [ ] Validate the refreshed surfaces on a physical compact Android device.
- [ ] Design project-owned onboarding/empty-state illustrations after branding approval.
- [ ] Implement Google sign-in only after a secure backend OAuth contract is approved.

## Essential Product Experience Completion
- [x] Complete Profile with real attempt, saved-set, and submission metrics.
- [x] Expose History, Saved, Contributions, Settings, and logout from the account experience.
- [x] Make Saved typed, retryable, removable, and reopenable in the learner flow.
- [x] Add contribution single-flight actions and read-only status/detail review.
- [x] Keep the four-tab mobile shell and expose secondary destinations without overcrowding it.
- [x] Document the secure Google provider setup boundary; keep unavailable social login disabled.
- [ ] Apply pending Prisma migrations and run database smoke tests manually.
- [ ] Run compact Android keyboard, large-text, and complete account-flow verification.
- [ ] Configure and implement Google sign-in only after backend token exchange and provider clients are approved.

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
