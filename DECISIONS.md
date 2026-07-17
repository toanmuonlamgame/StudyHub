# StudyHub Decisions

Use this file to record decisions that affect project direction, architecture, tools, or workflow.

## 2026-07-17 - Exam Attempt Persistence Boundary
Decision:
- Completed Exam attempts are persisted by the backend after authoritative
  scoring. Flutter sends selected option IDs, a start time, and a stable
  submission ID; it never sends a trusted score or user ID.
- Until authentication exists, routes obtain `demo-user` from one replaceable
  backend identity boundary. Service reads always filter by that identity.
- `(userId, submissionId)` is unique. A retry with the same canonical request
  returns the existing attempt; reusing the key with different Question Set,
  start time, or selected answers is a conflict.
- Attempt answers store review snapshots, while an optional safe foreign key to
  the source Question Set uses `SET NULL` on deletion.

Reason:
- The MVP needs reliable history without pretending real accounts exist.
- Idempotency protects timeout/retry and repeated-request cases at the backend.
- Snapshots keep old results understandable when community content changes.

Rule:
- Save attempt and answer snapshots in one transaction.
- List/detail endpoints expose only attempts owned by the current identity.
- Practice summaries remain device-local for now; advanced analytics, deletion,
  sync, and history editing remain out of scope.

## 2026-07-14 - Study Materials Metadata-First Boundary
Decision:
- Study Material is a first-class content type separate from Question Set.
- Public list/detail APIs return only published material metadata.
- List responses stay compact and omit source/file detail; detail is fetched on demand.
- Uploaded-file records may expose safe file metadata after publication, but V1
  does not store or deliver binary files.

Reason:
- Metadata browsing creates a useful end-to-end foundation without pretending
  that authentication, ownership, moderation, or cloud storage already exist.
- A shared `LearningService`/`LearningRepository` contract keeps memory, Prisma,
  mock, and API modes behaviorally aligned.

Rule:
- Draft, pending-review, rejected, moderation, and private ownership data must
  never appear in public material endpoints.
- Real upload must be introduced later behind backend validation, authorization,
  storage safety, and moderation boundaries.

## 2026-07-14 - Device-Local Learning Progress
Decision:
- StudyHub records completed Exam and Practice summaries locally through a
  `ProgressStore` abstraction backed by `shared_preferences`.
- Trusted `QuizResult` data is the only source for a completed session. The app
  does not reconstruct correctness from selected answers.
- Local history is ordered newest first, deduplicated by session ID, and bounded
  to the newest 100 sessions.

Reason:
- Real local progress makes the learner experience useful before authentication
  exists without pretending that account sync or analytics are available.
- A store boundary keeps persistence out of screens and allows later replacement
  or migration without rewriting Progress UI.

Rule:
- Persist only session ID, question-set identity/title, mode, score summary, and
  completion time. Do not persist answer keys, full questions, secrets, or credentials.
- A persistence failure must never block access to a completed result.
- Clear history requires explicit confirmation.
- Cross-device sync, account ownership, conflict resolution, streaks, and
  analytics remain future backend/auth work.

## 2026-07-13 - Honest, Purposeful Learner Hub
Decision:
- StudyHub Home is a mobile-first, icon-driven hub with one primary learning
  route, compact shortcuts, manual feature banners, and clearly separated
  upcoming destinations.
- Progress uses honest empty metric shells until persisted attempt data exists.
- Settings exposes only working preferences; planned controls are visibly
  unavailable instead of pretending to function.

Reason:
- A richer interface should improve orientation and motivation without inventing
  activity, commercial offers, account state, or unfinished capabilities.
- Keeping Home independent from `LearningRepository` avoids eager API work and
  preserves fast startup while still giving the product a complete structure.

Rule:
- Banners must not auto-rotate, make unsupported claims, or mimic discounts.
- Every unfinished destination must be labeled `Coming soon` and remain inert.
- Prefer purposeful icons, concise copy, clear hierarchy, and lightweight
  built-in motion over filler text, decorative clutter, or fake dashboard data.
- Load Subjects and other learning data only after an explicit Learn action.

## 2026-07-13 - Localization, Search, And Mobile Accessibility Boundaries
Decision:
- Localize StudyHub system interface through Flutter ARB resources for English
  and Vietnamese, while keeping creator and learning content unchanged.
- Own selected locale state at `StudyHubApp` and persist only the non-sensitive
  `system`, `en`, or `vi` preference locally.
- Keep Question Set search, topic filtering, and cursor pagination behind
  `LearningRepository`; Flutter must not fetch all API data and filter locally.
- Support larger text and platform reduced-motion preferences instead of
  disabling accessibility settings to preserve a fixed layout.

Reason:
- Interface language and educational-content language are separate user choices.
- App-level locale ownership updates the full navigation tree consistently
  without adding a state-management package.
- Backend/repository-driven queries preserve compact payloads and scale beyond
  the prototype dataset.
- Mobile accessibility is part of product quality, not optional visual polish.

Rule:
- Never auto-translate user-created questions, answers, subjects, materials, or uploads.
- Persist no secret, identity, or sensitive data in the locale preference.
- Debounce search, invalidate stale responses, reset cursors when filters change,
  and preserve loaded items when a next-page request fails.
- Do not globally clamp text scale or require motion to understand an interaction.

## 2026-07-13 - Mobile-First Learner UI Standard
Decision: StudyHub designs and validates learner surfaces for phones first. Wider
Flutter Web layouts remain responsive and constrained, but they do not drive the
learner information architecture.

Reason:
- StudyHub is a mobile learning product, so touch comfort, focused vertical flows,
  readable wrapping, and compact-screen behavior are primary product requirements.
- Consistent loading, error, empty, and feedback states make API-backed learning
  flows feel intentional without adding fake data or hiding failures.

Rule:
- Keep top-level navigation in the app shell and hide it on focused deep routes.
- Keep Progress and Settings honest until their data and controls are functional.
- Use lightweight Material motion, clear icon-and-text status feedback, and
  reusable state views without moving trusted correctness logic into Flutter UI.
- Validate compact Android, common Android, Chrome, larger text, and long content
  manually before claiming accessibility completion.

## 2026-07-12 - Mobile App Shell And Practice Summary
Decision: StudyHub uses a Material 3 four-tab mobile shell for Home, Learn,
Progress, and Settings. Focused browse-detail-quiz-result routes are pushed above
the shell and do not show bottom navigation.

Practice Mode now ends with a result/review summary assembled from successful
`checkAnswer` responses. It does not call Exam Mode submission and does not infer
correctness from pre-submit models.

Reason:
- Persistent top-level navigation makes the mobile app predictable without
  distracting learners during focused sessions.
- Honest Progress and Settings placeholders establish information architecture
  without inventing user data or non-functional preferences.
- Reusing `QuizResult` and `AnswerReview` keeps result presentation consistent
  while preserving separate Exam and Practice backend contracts.

Rule:
- Keep bottom navigation visible only on top-level shell sections.
- Keep Exam Mode scoring backend-owned through `submitQuiz`.
- Build Practice summaries only from trusted `checkAnswer` result fields.
- Keep motion lightweight, non-blocking, and understandable when motion is absent.

## 2026-07-11 - Phase 1 Learning Foundation Closed
Decision: Phase 1 is closed with the core StudyHub learning foundation working
across Flutter mock/API modes, Fastify memory/Prisma modes, PostgreSQL, quiz
safety contracts, pagination, indexes, and automated verification.

Reason:
- The browse, Exam Mode, Practice Mode, result/review, and data-source flows are
  complete enough to serve as a stable foundation.
- Keeping UI production polish in a separate phase prevents visual work from
  obscuring contract, safety, and persistence risks.

Rule:
- Phase 2 may refine UI structure and interactions but must preserve Phase 1
  repository/service boundaries, answer safety, API compatibility, and tests.
- Phase 2 prioritizes professional UI/UX, responsive behavior, accessibility,
  lightweight animation, and then Vietnamese localization.
- See `docs/PHASE_1_CHECKPOINT.md` for the complete boundary.

## 2026-07-11 - Scalable Search And Data Growth
Decision: StudyHub will use backend-side filtering, stable cursor pagination,
PostgreSQL-first search, and optional external search only when measured scale or
relevance requirements justify it.

Reason:
- Mobile clients should receive small screen-specific payloads instead of whole datasets.
- PostgreSQL already owns transactional truth and can support the initial search/indexing needs.
- Premature cache, search, and analytics infrastructure would add consistency and operational cost.

Rule:
- Growing list endpoints validate bounded limits and opaque cursors.
- Add query-driven PostgreSQL indexes through Prisma migrations.
- Keep search indexes rebuildable and free of private content, secrets, and unreleased answer keys.
- Separate future analytical workloads from the transactional API.
- Follow `docs/SCALABILITY_AND_SEARCH.md` when implementing list/search work.

## 2026-07-11 - StudyHub Quality System
Decision: Future StudyHub features use the balanced UX, performance, security, and feature-quality review system in `docs/QUALITY_SYSTEM.md`.

Reason:
- Product quality includes usefulness, visual polish, responsiveness, safety, and maintainability together.
- Shared frontend/backend checklists make expectations reviewable without forcing every feature into the same implementation.
- A Definition of Done helps prevent loading states, errors, payload scope, security boundaries, and performance risks from being discovered late.

Rule:
- Apply only the checklist items relevant to the feature, but skip them intentionally and document meaningful deferrals.
- Prefer performance-aware implementation over removing valuable UX or roadmap features.
- Update the quality system when measured product experience shows a standard is missing or counterproductive.

## 2026-07-11 - Balanced Performance And UX
Decision: Performance must not be used as an excuse to make StudyHub visually poor, unfinished, or feature-poor. StudyHub will prefer a polished, modern learning experience implemented within explicit performance guardrails.

Reason:
- Visual clarity, feedback, motivation, and trust are part of product quality.
- Removing useful features is not the default solution to inefficient loading, rendering, assets, or API access.
- Measured budgets make it possible to keep product value while detecting regressions early.

Rule:
- Keep purposeful UI polish and lightweight animation when they support learning.
- Animations must not block navigation or core learning interactions.
- Use pagination, small payloads, lazy loading, caching, and efficient rendering instead of loading all data at once.
- Evaluate valuable features for a performance-aware implementation before removing them.

## 2026-07-11 - Research-Informed Architecture Guardrails
Decision:
- Keep Flutter as the learner-facing mobile app.
- Reserve React for a future Admin Dashboard when moderation operations justify it.
- Do not add Kotlin unless a specific native Android feature cannot reasonably be delivered through Flutter.
- Keep the backend as a modular monolith with clear service boundaries; do not adopt microservices yet.
- Treat performance as a core non-functional requirement.

Reason:
- Consistent feature boundaries reduce implementation and review friction.
- A second learner-app stack would add maintenance cost without V1 product value.
- Distributed services add network, deployment, observability, and data-ownership complexity that StudyHub does not currently need.
- Mobile startup, responsiveness, payload size, and weak-network behavior directly affect whether learners can complete the core flow.

Rule:
- Measure app size, startup, smoothness, API latency, and payload growth as the product evolves.
- Keep API and repository boundaries extraction-friendly without deploying separate services prematurely.
- Record future AI-generated learning content with source provenance, citations, and review status.
- See `docs/PRODUCT_RESEARCH.md` and `docs/ARCHITECTURE_LESSONS.md` for supporting research.

## 2026-07-09 - Collaboration Workflow
Decision: Use Git plus project memory files as the shared context between Codex, Antigravity, ChatGPT, and the user.

Reason:
- Chat history is not a reliable source of truth across tools.
- Project files are visible to the coding/planning tools.
- Git commits make changes reviewable and recoverable.

Rule:
- Codex app is the main coding assistant.
- Antigravity is planner, reviewer, and helper.
- ChatGPT is mentor.
- One AI should be the main editor for a task.
- The other AI should review, explain, or plan unless explicitly assigned to edit.

## 2026-07-09 - Product Direction
Decision: StudyHub is a mobile learning platform for organizing and studying learning content.

Reason:
- The project should be useful as both a learning project and an internship portfolio.
- A mobile learning app gives a clear product surface and a practical portfolio story.
- The project can start small and grow into richer study workflows.

## 2026-07-09 - Flexible Taxonomy
Decision: StudyHub organizes content by school, program/system, major, subject, and topic, but the taxonomy must be flexible and optional by level.

Reason:
- Real learning content does not always fit every level.
- Some users may only know the subject or topic.
- A flexible taxonomy avoids blocking uploads and browsing when metadata is incomplete.

Rule:
- Do not force every content item or user journey through all taxonomy levels.
- Support partial taxonomy paths.

## 2026-07-09 - Study Material And Question Set Are Separate Content Types
Decision: Study Material and Question Set are distinct content types.

Reason:
- Study Material is for notes, documents, PDFs, slides, explanations, and reference resources.
- Question Set is for practiceable questions used in quizzes and review.
- Keeping them separate avoids confusing upload/storage, quiz logic, moderation, and future AI generation flows.

Rule:
- A Study Material may be related to a Question Set, but it is not the same thing.
- A document that later produces questions should still remain a Study Material with related generated/reviewed Question Sets.

## 2026-07-09 - Content Source Model
Decision: Users can study existing question sets, upload documents/exams/question sets, and contribute community content.

Reason:
- StudyHub should support both immediate studying and long-term community growth.
- User-owned and community-contributed content makes the platform useful across schools, majors, and subjects.
- Upload and contribution workflows are central to the product.

## 2026-07-09 - Admin Seed Content
Decision: Admins may create a small amount of legal seed content at the start.

Reason:
- Some seed content helps solve cold start.
- Seed content should be limited and lawful.
- The long-term content model should still rely on user uploads and community contributions.

Rule:
- Do not treat pre-seeded content as the primary product strategy.

## 2026-07-09 - Reward And Quality Model
Decision: Do not reward users with credits only because they upload content. Rewards should be based on content validity, actual use, and quality.

Reason:
- Upload-count rewards encourage spam and low-quality content.
- Usage and quality signals better align rewards with real learning value.
- This keeps community incentives healthier.

## 2026-07-09 - Study Credits
Decision: Study Credits are internal credits for unlocking selected content or features. They cannot be withdrawn as real money.

Reason:
- Internal credits can support engagement and unlock mechanics without creating a cash-out economy.
- Avoiding real-money withdrawal reduces complexity, fraud risk, and compliance burden.

Rule:
- V1 should not implement the full credit economy.
- Credit behavior belongs in later roadmap phases after the core learning flow works.

## 2026-07-09 - Roadmap Direction
Decision: Use a phased roadmap.

V1:
- Basic taxonomy.
- Browse question sets.
- Take quiz.
- View result.
- Upload documents/exams/question sets.

V2:
- Contributor profile.
- Rating/report.
- Duplicate prevention.
- Study Credits.
- Unlock content.

V3:
- AI-generated questions from documents with review.
- Ads-for-credit.
- Consider payments later.

Reason:
- V1 should prove the core learning loop before adding economy, moderation complexity, AI, ads, or payments.
- V2 can improve community quality and controlled unlock mechanics.
- V3 can add AI and monetization options after the platform has a stronger content foundation.

## 2026-07-09 - V1 Milestone Scope
Decision: V1 focuses on the smallest useful learning flow: basic taxonomy, browsing Question Sets, taking a simple multiple-choice quiz, viewing results, and adding an upload placeholder.

V1 includes:
- Basic flexible taxonomy.
- Subject is required.
- School, program/system, major, and topic are optional in V1.
- Browse Question Sets by subject/topic.
- Take a simple multiple-choice quiz.
- View quiz result with correct count, wrong count, percentage score, and correct answers.
- Upload placeholder for document/exam/question set with basic metadata.
- Local/demo auth for V1 only.

V1 excludes:
- Full Study Credits economy.
- Content unlock system.
- Ads.
- Payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

Reason:
- V1 should prove the core learning loop before adding platform economy, monetization, AI, moderation complexity, or admin tooling.
- A smaller V1 is easier to build, test, and present as an internship portfolio milestone.
- The upload placeholder keeps the future contribution loop visible without requiring the full moderation/content pipeline yet.

## 2026-07-09 - V1 Taxonomy Requirements
Decision: Subject is required in V1. School, program/system, major, and topic are optional in V1.

Reason:
- Subject is the minimum useful anchor for browsing and organizing Question Sets.
- Topic improves filtering, but not every upload or Question Set will have a precise topic at the start.
- School, program/system, and major are useful long-term but should not block V1 content entry or browsing.

Rule:
- V1 should not force users through the full taxonomy.
- V1 content must have a Subject.
- V1 content may optionally include school, program/system, major, and topic.

## 2026-07-09 - V1 Local/Demo Auth
Decision: Use local/demo auth for V1 only. Real authentication is deferred to the backend phase.

Reason:
- V1 should focus on the learning flow, taxonomy, quiz, results, and upload placeholder.
- Real authentication adds backend security, account lifecycle, session/token handling, and production concerns that can slow the first demo milestone.
- The project already has a strict security boundary decision for the backend phase.

Rule:
- Do not treat local/demo auth as production auth.
- Do not use frontend-provided identity as a source of truth for real permissions, credits, unlocks, or rewards.
- When real authentication is added, the backend must own authentication and authorization.

## 2026-07-09 - Minimal V1 Data Model
Decision: V1 uses this minimal data model: User, Subject, Topic, QuestionSet, Question, AnswerOption, QuizAttempt, QuizAttemptAnswer, and StudyMaterialUpload.

Reason:
- These entities cover browsing, quiz-taking, results, and upload placeholder behavior.
- The model stays small while leaving room for future Study Material, moderation, credits, unlocks, and AI-generated question workflows.
- Keeping the model explicit helps implementation stay simple and portfolio-readable.

## 2026-07-10 - V1 API Boundaries
Decision: Use a small V1 backend API surface for taxonomy, Question Sets, quiz attempts, quiz results, and study material upload placeholders.

V1 endpoints:
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

Reason:
- This keeps the API focused on the confirmed V1 scope.
- The two-step quiz attempt flow supports future in-progress attempts and quiz history.
- `POST /study-material-uploads` is clearer than a generic `/uploads` endpoint because V1 upload is a Study Material metadata placeholder.
- The API follows the security boundary: Flutter App -> Backend API -> Database.

Rules:
- `GET /question-sets/:id` returns questions and answer options only.
- `GET /question-sets/:id` must not return `isCorrect` or `correctAnswerOptionId`.
- Correct answers are only returned after quiz submission through the result endpoint.
- Backend calculates score; Flutter does not send score.
- Flutter does not send a trusted userId.
- V1 uses local/demo auth, but the API shape should prepare for real backend auth later.
- QuestionSet and StudyMaterialUpload should include simple status fields such as `draft`, `published`, `pending_review`, and `rejected`.
- `GET /taxonomy` is optional for V1 if Flutter needs a combined subject/topic loading endpoint.

## 2026-07-09 - Frontend Stack
Decision: Use Flutter / Dart for the frontend.

Reason:
- StudyHub is a mobile learning platform.
- Flutter is suitable for building a polished mobile app experience.
- Flutter / Dart is useful for portfolio development.

## 2026-07-09 - Backend Stack
Decision: Use Node.js for the backend.

Reason:
- Node.js is practical for building API services.
- It is common in web/mobile app stacks and useful for internship preparation.
- It can stay simple for the first milestone.

## 2026-07-09 - Backend V1 TypeScript, Fastify, And Prisma
Decision: Use Node.js runtime with TypeScript, Fastify, Prisma, and PostgreSQL for the V1 backend.

Confirmed backend V1 stack:
- Runtime: Node.js
- Language: TypeScript
- Framework: Fastify
- ORM / database access layer: Prisma
- Database: PostgreSQL

Reason:
- Node.js fits the JavaScript ecosystem.
- TypeScript makes backend data shapes clearer, reduces avoidable runtime mistakes, and makes AI review easier.
- Fastify is lightweight, fast, and less over-engineered than NestJS for V1.
- Prisma gives clear schema management, migrations, and PostgreSQL queries.
- This stack fits the learning goal, internship portfolio goal, and future codebase growth.

Rule:
- StudyHub remains in the JavaScript ecosystem, but backend application code should be written in TypeScript.
- Keep the Fastify API simple for V1.
- Use Prisma for database schema, migrations, and query access instead of ad hoc SQL in app code unless there is a specific reason.

## 2026-07-09 - Database
Decision: Use PostgreSQL as the database.

Reason:
- StudyHub needs structured data for users, taxonomy, study materials, question sets, questions, quiz attempts, and content quality signals.
- PostgreSQL is a strong portfolio-friendly relational database.
- It keeps the data model explicit and reliable.

## 2026-07-09 - Architecture Principle
Decision: Keep architecture simple and avoid over-engineering.

Reason:
- The project is currently in the foundation / planning phase.
- The first goal is a working learning platform milestone, not a complex architecture showcase.
- Small, reviewable changes are easier for AI-assisted development and future maintenance.

## 2026-07-09 - Security Boundary And Source Of Truth
Decision: StudyHub uses a strict client-server security boundary. The standard data flow is Flutter App -> Backend API -> Database. The Flutter frontend must never call the database directly.

Reason:
- Mobile clients can be inspected, modified, or replayed by users.
- Frontend state is useful for UI, but it cannot be trusted for security-sensitive decisions.
- StudyHub includes roles, moderation, content unlocks, Study Credits, and rewards, so the backend must own the authoritative logic.
- A clear boundary keeps the architecture simple while avoiding dangerous shortcuts.

Frontend rule:
- The frontend only displays UI according to backend responses.
- The frontend only calls approved backend APIs.
- The frontend is not the source of truth for account data, roles, admin/moderator permissions, Study Credits, rewards, content unlocks, or database logic.
- The frontend must not contain database secrets, JWT secrets, admin keys, or service keys.

Backend rule:
- The backend is the source of truth for authentication, authorization, roles/permissions, admin/moderator actions, upload validation, content access, Study Credit transactions, reward calculation, audit logs, and rate limiting.
- The backend must not trust userId, role, credit amount, unlock status, or reward requests sent by the frontend.
- The backend must derive the acting user from verified authentication context, not from arbitrary request body fields.
- The backend must check permissions server-side for admin, moderator, upload, unlock, reward, and credit actions.

Credit and reward safety:
- Credit and reward logic must be controlled by the backend.
- Study Credit transactions must be recorded with transaction-safe database writes.
- Credit/reward changes should have audit logs so future moderation, debugging, and abuse investigation are possible.
- Reward calculation must not be triggered merely by a frontend claim that content was uploaded, used, unlocked, or should be rewarded.

Secrets rule:
- Database credentials, JWT secrets, admin keys, service keys, and production secrets must not be committed to GitHub.
- Secrets must not be embedded in the Flutter app.
- Use environment variables or a proper secret management approach for backend/runtime secrets.

## 2026-07-10 - Frontend Learning Repository Seam
Decision: Add a `LearningRepository` seam between Flutter learning screens and concrete data sources before backend integration.

Reason:
- `SubjectListScreen`, `QuestionSetListScreen`, and `QuizScreen` currently depend directly on mock data.
- Mock data and the future backend API are two real adapters with different loading, error, and scoring behavior.
- A small repository interface lets the data source change without rewriting screen layout or navigation.
- Constructor injection keeps the seam testable without adding state-management or dependency-injection packages.

Target structure:
```text
features/learning/
├── models/
├── data/
├── repositories/
└── screens/
```

Rules:
- Keep the current models, screens, and `mock_learning_data.dart`.
- Screens should eventually depend on the `LearningRepository` interface, not import mock data directly.
- `StudyHubApp` should act as the composition root and inject the selected repository adapter.
- Start with `MockLearningRepository`; add `ApiLearningRepository` only when backend APIs exist.
- Repository methods should be asynchronous so mock and API adapters use the same interface.
- Do not add a state-management or dependency-injection package for this migration.
- Keep mock filtering and local mock scoring inside `MockLearningRepository`.

Quiz safety rule:
- Public pre-submit `AnswerOption` data contains only `id` and `text`.
- Pre-submit question data must not expose `isCorrect` or a correct answer ID.
- Mock answer keys stay private to `MockLearningRepository`.
- `QuizResult` carries post-submit answer review data.
- The backend must calculate the authoritative score and return review data only after submission.

## 2026-07-10 - Quiz Modes And Answer Review Boundary
Decision: StudyHub supports separate Exam Mode and Practice Mode correctness flows.

Exam Mode:
- Users answer the quiz without seeing correctness metadata.
- Correct, wrong, score, and answer review data become available only after submitting the whole quiz.

Practice Mode direction:
- Practice Mode uses a separate backend/repository `checkAnswer` operation after the learner selects an option.
- The response reveals correctness and the correct answer only for that checked question.
- The pre-check question payload remains free of correctness metadata.

Reason:
- Separating safe pre-submit data from post-submit review data matches the backend security boundary.
- A dedicated `AnswerReview` result shape lets the UI render feedback without knowing or deriving the answer key.
- A separate contract preserves the stable Exam Mode submission behavior while allowing immediate Practice Mode feedback.

## Pending Decisions
- Deployment target:
- Moderation approach for uploaded content:

## 2026-07-16 - Structured Full-Exam Paste Boundary
Decision: Question Set creators may either use the manual editor or paste a full
exam using the canonical `/question`, `/answerN`, `/correct`, and optional
`/explanation` format.

Rules:
- Parser logic is deterministic, typed, and separate from Flutter widgets.
- Compatibility aliases such as `/quest` and `/awserN` may be accepted with a
  warning, but documentation and templates only show canonical tags.
- Severe errors block the complete import; StudyHub does not silently save or
  submit only the valid subset.
- Parsed questions return to the normal editor for structured changes and use
  the existing `ContributionRepository` and backend submission contract.
- The frontend never bypasses backend validation or moderation lifecycle rules.

Reason: bulk paste reduces repetitive mobile input while one submission contract
keeps validation, transactions, moderation, and API behavior consistent.

## 2026-07-16 - Centralized Visual Tokens
Decision: Shared brand, supportive, motivational, semantic, spacing, and radius
values belong in centralized Flutter design tokens and `AppTheme`.

Reason: a controlled indigo/teal/warm palette gives StudyHub a more motivating
educational identity while preserving contrast, performance, and maintainability.

## 2026-07-15 - Community Question Set Submission Boundary
Decision: community Question Sets use `draft -> pendingReview -> published` or
`rejected`, with learner visibility restricted to `published` at service/query
level.

- Flutter keeps the current draft locally and sends one atomic final submission.
- Creator DTOs may contain `isCorrect`; learner GET DTOs never do.
- `createdByUserId` stays nullable and untrusted until authentication exists.
- No unauthenticated approve/reject routes are exposed.
- Memory and Prisma implementations share centralized validation and lifecycle
  behavior behind `LearningService`.

## 2026-07-17 - Completion Navigation And App Scope Boundary
Decision: completed flows use one app navigation operation that selects the Home
tab and removes obsolete focused routes back to the existing shell root.

Rules:
- Do not push a second Home or shell route.
- Ordinary browsing Back behavior remains unchanged.
- An active Exam still requires explicit discard confirmation before leaving.
- App navigation, attempt history, and local progress dependencies wrap
  `MaterialApp` so every root-Navigator route inherits the same instances.
- Flutter API requests are bounded to avoid an indefinite loading state; a
  transport timeout is reported through the existing retry/error UI without
  erasing drafts or trusted completed results.

Reason: completion actions should return learners to a predictable top-level
state, while unfinished work and repository ownership remain protected.
