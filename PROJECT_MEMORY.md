# StudyHub Project Memory

## Project Identity
- Project name: StudyHub
- Product type: mobile learning platform
- Goal: learning project and internship portfolio
- Current phase: Phase 1 foundation complete; preparing Phase 2 UI/UX polish

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
  Progress now stores trusted completed-session summaries on the current device;
  Settings remains honest until additional preferences are functional.
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
- Local Progress persists only post-result metadata from Exam and Practice. It
  keeps the newest 100 sessions in `shared_preferences`, stores no answer keys or
  full question payloads, and will remain device-only until authentication and
  backend sync are deliberately implemented.

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
- Community Question Sets use a moderation-ready lifecycle: local creator draft, backend `pendingReview`, then future authorized publish/reject. Learner APIs expose only `published` content.
- Creator answer-key models remain separate from learner-safe quiz DTOs. Real ownership and draft sync begin only after authentication.
- Question Set creation supports a fast manual editor and a canonical structured
  paste format (`/question`, `/answerN`, `/correct`, optional `/explanation`).
  Parsing stays local and typed; severe parse errors block the whole import, and
  both creation methods reuse the same validated contribution submission API.
- StudyHub's visual system uses centralized indigo, teal, warm accent, semantic
  state, spacing, and radius tokens so polished UI does not scatter hard-coded
  styling across features.

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
