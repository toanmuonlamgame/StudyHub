# StudyHub Project Memory

## Project Identity
- Project name: StudyHub
- Product type: mobile learning platform
- Goal: learning project and internship portfolio
- Current phase: essential MVP feature completion, before migration and dedicated stabilization

## Product Purpose
StudyHub is a mobile learning platform for organizing and studying learning content. The product should help users browse structured learning content, practice question sets, upload their own materials, and contribute useful community content.

StudyHub is not a pre-seeded question database first. It should support a small amount of legal admin-created seed content to solve cold start, but the long-term model is user-owned and community-contributed learning content.

## Confirmed Product Direction
- StudyHub organizes content by school, program/system, major, subject, and topic.
- The taxonomy must be flexible. Users should not be forced to pass through every taxonomy level when their content does not need it.
- Study Material and Question Set are separate content types.
- Study Materials now have a metadata-first browsing foundation in Flutter and
  the backend. Only published materials are public; binary upload, ownership,
  moderation workflows, and cloud storage remain future authenticated work.
- Users can study existing question sets.
- Users can upload documents, exams, question sets, and other study content.
- Users can contribute community content.
- Admins may create a small amount of legal seed content at the start to reduce cold start.
- Rewards should not be granted just because someone uploads content.
- Reward logic should be based on valid content, real usage, and quality.
- Study Credits are internal credits for unlocking selected content or features.
- Study Credits cannot be withdrawn as real money.
- V1 should not implement the full credit economy.
- Android identity is `StudyHub`, application ID
  `com.toanmuonlamgame.studyhub`, version `1.0.0+1`.
- Flutter release builds require API mode and an explicit HTTPS API origin.
  Backend production requires explicit Prisma mode plus `DATABASE_URL`; local
  mock/memory and cleartext LAN behavior remain development-only.

## Core Content Model
### Taxonomy
Content can be organized through these optional levels:

- School
- Program / system
- Major
- Subject
- Topic

The taxonomy should support partial paths. For example:

- A user may browse directly by subject without choosing a school.
- A question set may belong to a subject and topic but no major.
- Community content may be tagged broadly until more structure is available.

### Study Material
Study Material means learning resources such as notes, PDFs, documents, slides, explanations, and uploaded reference material.

### Question Set
Question Set means a practiceable collection of questions used for quizzes, review, or exam preparation.

Study Material and Question Set should stay distinct even when a document later produces questions.

## V1 Milestone Scope
V1 is the first usable demo milestone. It should prove the core learning flow without building the full platform economy, marketplace, admin system, or AI pipeline.

### V1 Includes
- Basic flexible taxonomy.
- Subject is required.
- School, program/system, major, and topic are optional in V1.
- Browse Question Sets by subject/topic.
- Take a simple multiple-choice quiz.
- View quiz result:
  - correct count
  - wrong count
  - percentage score
  - correct answers
- Upload placeholder for document/exam/question set with basic metadata.
- Local/demo auth for V1 only.
- Real authentication is deferred to the backend phase.

### V1 Excludes
- Full Study Credits economy.
- Content unlock system.
- Ads.
- Payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

### Minimal V1 Data Model
- User
- Subject
- Topic
- QuestionSet
- Question
- AnswerOption
- QuizAttempt
- QuizAttemptAnswer
- StudyMaterialUpload

## Long-Term Core Loop
1. User browses or filters content using the flexible taxonomy.
2. User opens a Question Set or Study Material.
3. User studies, takes a quiz, or reviews results.
4. User uploads documents, exams, or question sets.
5. Valid, useful, high-quality contributed content becomes discoverable.
6. In later versions, high-quality usage can affect reputation, credits, or unlocks.

## Confirmed Tech Stack
- Frontend: Flutter / Dart
- Backend: Node.js
- Database: PostgreSQL

## Current Repository Status
- Local project path: F:\Projects\StudyHub
- Phase 1 is complete as a working learning foundation across Flutter, Fastify,
  Prisma/PostgreSQL, mock/API modes, pagination, safety boundaries, and tests.
- Phase 2 should focus on professional learner UI/UX, responsive behavior,
  lightweight interactions, accessibility, and then Vietnamese localization.
- The mobile app uses a four-tab top-level shell: Home, Learn, Progress, and
  Settings. Focused learning routes open above the shell without bottom navigation.
- Home is an icon-driven learner hub with manual, honest feature banners, clear
  quick destinations, and visibly labeled upcoming features. It remains
  repository-lazy so learning data loads only after the learner enters Learn.
- Mobile phone layouts are the learner UI source of truth; wider Chrome layouts
  remain constrained and responsive for development and secondary use.
- Shared loading, error, and empty states keep learner feedback consistent.
  Progress stores trusted completed-session summaries on the current device;
  Settings now exposes functional account, language, Saved, version, privacy,
  profile, and logout destinations.
- StudyHub supports English and Vietnamese system UI. The app-level locale
  selection supports system default, persists locally, and updates immediately.
- Interface localization is separate from learning-content language: subject,
  topic, question-set, question, answer, and creator-uploaded text is not auto-translated.
- Flutter Question Set search, topic filtering, and cursor load-more are
  repository-driven in both mock/API modes, with debouncing and stale-response protection.
- Compact-screen, large-text, semantics, and reduced-motion behavior are core
  mobile quality requirements; representative-device review is still required.
- Practice Mode ends with a summary assembled only from trusted per-question
  `checkAnswer` responses; Exam Mode continues to use backend `submitQuiz`.
- Exam Mode supports one-question-at-a-time previous/next navigation, retained
  answer changes, protected exit after meaningful progress, and explicit
  submission with unanswered questions. Backend scoring separates incorrect
  from unanswered answers and rounds percentage to the nearest whole percent.
- Post-submit review may include all safe answer options and an optional
  explanation. Accelerated MVP Checkpoint 2 adds backend Exam attempt
  persistence, newest-first history, and reusable result-detail review.
- StudyHub now has minimum email/password authentication with expiring opaque
  sessions. Passwords and session tokens are stored only as hashes by the backend.
- Exam attempts, contributions, and saved Question Sets belong to the authenticated
  user. Flutter never sends a trusted user ID; protected routes derive identity
  from the verified bearer session.
- Attempt retries use a client-generated submission ID unique per current user.
  The backend fingerprints the canonical request and returns the existing
  attempt only when retry content matches; changed content returns a conflict.
- Atomic Question Set contribution retries use the same pattern: Flutter keeps
  one client submission ID for the editor session, while the backend derives
  authenticated ownership, fingerprints normalized content, and returns the same
  pending-review submission only when retry content matches.
- Debug/test builds may default to mock learning data for local development.
  Release builds must explicitly choose their learning source; release API mode
  must also provide an explicit non-secret backend base URL.
- Unexpected backend and stored-data integrity errors are logged server-side but
  returned to clients with stable generic messages that do not expose Prisma,
  database, credential, or internal answer-key details.
- Historical review stores question, option, selected-answer, correct-answer,
  and explanation snapshots so published content changes cannot corrupt history.
- Local Progress persists only post-result metadata from Exam and Practice. It
  keeps the newest 100 sessions in `shared_preferences`, stores no answer keys or
  full question payloads, and remains device-only until authenticated backend
  progress sync is deliberately implemented.
- Backend Attempt History is separate from local Progress: authenticated Exam
  details persist server-side; Practice remains device-local until a future sync
  contract is deliberately added.
- Completed result, attempt-detail, and contribution-success flows share one
  return-to-Home operation: select shell tab 0 and pop the root Navigator to its
  first route. It does not push another Home route; ordinary Back remains intact.
- Navigation, AttemptRepository, and ProgressStore scopes wrap `MaterialApp` so
  focused routes above the shell inherit the same app-level dependencies.
- Flutter API adapters use bounded requests (15 seconds by default). Timeout and
  other transport failures remain retryable and must not discard learner drafts.
- Core retry and completion actions are single-flight: repeated taps must not
  duplicate history requests, submissions, persisted attempts, or result routes.
  Long preview/state screens remain scrollable and long parsed lists render lazily.

## Roadmap Summary
- V1: basic taxonomy, browse question sets, take quiz, view results, upload documents/exams.
- V2: contributor profiles, rating/report, duplicate prevention, Study Credits, unlock content.
- V3: AI-generated questions from documents with review, ads-for-credit, possible payments later.

## Architecture Guidance
- Keep architecture simple.
- Avoid over-engineering.
- Prefer a small, understandable structure over premature abstractions.
- Build V1 around the smallest useful learning workflow.
- Do not implement the full credit economy in V1.
- Record meaningful architecture, product, and workflow decisions in DECISIONS.md.

## Research-Informed Long-Term Guardrails
- Keep Flutter as the main learner app; React is reserved for a future Admin Dashboard.
- Add Kotlin only when a concrete native Android requirement justifies it.
- Keep the backend a modular monolith with clear service contracts until scale or ownership requires extraction.
- Treat mobile performance, small API payloads, pagination, and later read caching as product requirements.
- Aim for a polished, feature-rich learning experience while keeping the app lightweight, smooth, and API-efficient.
- Use `docs/QUALITY_SYSTEM.md` as the balanced UX, performance, security, and Definition of Done guardrail for future features.
- Future AI study aids must come from user-provided sources, retain citations/provenance, and pass review before publication.
- Plan for data growth with backend filtering, cursor pagination, PostgreSQL indexes, and later measured caching, external search, or analytics only when needed.
- Community Question Sets use an account-owned moderation-ready lifecycle:
  `draft`, `pendingReview`, `approved`/published, and `rejected`. Creators can
  manage drafts and inspect statuses; future authorized admin tooling owns review
  actions. Learner APIs expose only published content.
- Creator answer-key models remain separate from learner-safe quiz DTOs. Real ownership and draft sync begin only after authentication.
- Question Set creation supports a fast manual editor and a canonical structured
  paste format (`/question`, `/answerN`, `/correct`, optional `/explanation`).
  Parsing stays local and typed; severe parse errors block the whole import, and
  both creation methods reuse the same validated contribution submission API.
- StudyHub's visual system uses centralized indigo, teal, warm accent, semantic
  state, spacing, and radius tokens so polished UI does not scatter hard-coded
  styling across features.
- The learner UI uses one dominant action per screen, labeled Material icons,
  shared state views, account-aware but non-invented Home content, bounded mobile
  layouts, and reduced-motion-aware transitions. See `docs/UI_UX_REDESIGN.md`.
- The essential account experience uses backend-owned identity and real repository
  data: Profile summarizes attempts, bookmarks, and submissions; Saved reopens
  learner-safe sets; contribution management keeps drafts editable and later
  lifecycle states read-only. The four-tab shell remains the mobile navigation
  baseline, with Saved, History, and Contributions as clear secondary routes.
- Google sign-in remains disabled until provider-console clients and a secure
  backend ID-token exchange are configured; Facebook remains hidden.

## AI Workflow
- Codex app: main coding assistant.
- Antigravity: planner, reviewer, and helper.
- ChatGPT: mentor.

Only one AI should be the main editor for a task. Do not let Codex and Antigravity edit the same files at the same time.

## Installed Support Tools
- ui-ux-pro-max
- mattpocock/skills
- Codebase Memory MCP
- Context Mode

## Collaboration Workflow
- Git is the source of truth.
- Important context must be written into project files, not kept only in chat history.
- Active work should be tracked in TODO.md.
- Meaningful decisions should be recorded in DECISIONS.md.
- Keep changes small and reviewable.
- Commit after each working milestone.

## Handoff Format
When switching from one AI/tool to another, use:

```text
Handoff summary:
- Goal:
- Files changed:
- What works:
- What is unfinished:
- Known issues:
- Recommended next step:
```
