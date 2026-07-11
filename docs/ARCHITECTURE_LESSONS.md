# StudyHub Architecture Lessons

## Purpose
These lessons adapt proven ideas from major learning platforms without copying
their UI, assets, content, or infrastructure scale. StudyHub should adopt a
pattern only when it solves a current product problem.

## Frontend Lessons
- Keep Flutter organized by feature, with models, repositories, and screens
  behind small contracts. Coursera found that a consistent modular architecture
  reduced friction when engineers moved between mobile platforms; StudyHub can
  gain the same clarity without duplicating native apps
  ([Coursera Engineering](https://medium.com/coursera-engineering/learning-multiple-platforms-coursera-281f03beb332)).
- Keep business and data-access logic outside widgets. Continue using repository
  injection so mock and API sources do not require UI rewrites.
- React remains a future Admin Dashboard technology, not a replacement for the
  Flutter learner app. Add Kotlin only for a justified native Android capability
  that Flutter cannot reasonably provide.
- Every screen that loads remote data should have explicit loading, empty, error,
  and retry states. Prefer cached or previously loaded content for read-heavy
  learning flows later.

## Backend Lessons
- Keep the Node.js backend as a modular monolith. `LearningService` is a useful
  module boundary; it is not a reason to deploy a separate microservice.
- Khan Academy notes that in-process calls are fast and reliable while service
  boundaries introduce slower, more fragile communication. Its services rewrite
  addressed a mature Python 2 system and required explicit boundary documents,
  gateways, and incremental migration. StudyHub does not yet have that pressure
  ([Khan Academy engineering](https://blog.khanacademy.org/go-services-one-goliath-project/),
  [rewrite lessons](https://blog.khanacademy.org/technical-choices-behind-a-successful-rewrite-project/)).
- Preserve clear contracts between routes, services, and persistence. Extract a
  deployable service only when ownership, scale, reliability, or deployment needs
  justify the operational cost.
- Backend remains the source of truth for authentication, authorization,
  moderation, access, scoring, credits, rewards, and audit logs.

## Database And Data Modeling
- Keep `StudyMaterial` and `QuestionSet` distinct, with Subject required and
  other taxonomy levels optional.
- Model quiz attempts separately from question definitions so history and future
  practice modes do not mutate source content.
- For future AI generation, retain provenance: source material, source version,
  cited page/section/chunk, generation status, reviewer, and approval status.
- Generated questions should be drafts until reviewed. A source update should not
  silently change already-reviewed questions.
- Add indexes, uniqueness rules, and pagination based on measured query patterns;
  avoid speculative denormalization in V1.

## Performance Guardrails
Performance is a product requirement because StudyHub targets mobile learners,
including slower devices and networks.

- Track release app size, cold/warm startup, first useful screen time, frame
  smoothness, API latency, and error rate. Establish baselines before setting
  numerical budgets.
- Duolingo reported that 39% of learners on entry-level Android devices waited
  more than five seconds for startup. It improved outcomes by removing blocking
  startup requests, delaying non-critical work, caching, prefetching, and adding
  offline support ([Duolingo Android case study](https://blog.duolingo.com/android-app-performance/)).
- Keep startup work minimal and never block the first useful screen on unrelated
  leaderboard, analytics, moderation, or reward requests.
- Keep API payloads endpoint-specific. Do not load all subjects, question sets,
  questions, attempts, or uploads at once.
- Add pagination before community lists become large. Add caching later for
  stable, read-heavy taxonomy and published content, with explicit invalidation.
- Optimize media before delivery and measure on a low-end Android device, not
  only an emulator or development machine.

## Balanced Performance and UX Standard
- StudyHub should be beautiful, modern, useful, and feature-rich while remaining
  lightweight and responsive.
- Optimization means removing unnecessary work, blocking calls, oversized
  payloads, wasteful rebuilds, and avoidable asset cost. It does not mean
  stripping away product value or leaving the interface visually unfinished.
- UI polish is encouraged when it improves clarity, confidence, motivation, or
  learning feedback and is measured on representative devices.
- Animations should be lightweight, purposeful, interruptible, and never block
  navigation, answer selection, quiz submission, or result review.
- Richer features should be supported through pagination, small endpoint-specific
  payloads, lazy loading, and measured caching rather than loading all data at
  once.
- When a valuable feature creates a performance problem, prefer a
  performance-aware implementation before removing the feature.

## Security And Data Safety
- Pre-submit question responses must never expose `isCorrect`, answer keys, or
  equivalent correctness metadata.
- Secrets must not enter Flutter, source control, docs, fixtures, or logs.
- Treat user uploads as untrusted: validate type/size, scan where appropriate,
  restrict access, and add reporting/moderation before broad community discovery.
- AI output must be grounded and traceable. NotebookLM-style flashcards, quizzes,
  and study guides are useful because explanations can cite the original source;
  StudyHub should require the same provenance and a review step
  ([Google NotebookLM learning features](https://blog.google/innovation-and-ai/models-and-research/google-labs/notebooklm-student-features/),
  [source citation overview](https://blog.google/innovation-and-ai/products/notebooklm-beginner-tips/)).

## Staged Plan
### V1
- Finish the small browse -> quiz -> result -> upload-placeholder loop.
- Add a lightweight performance checklist and test on a real Android device.
- Keep memory/API repository boundaries and the modular backend monolith.

### V2
- Add real Study Material uploads, contributor quality signals, moderation,
  reporting, duplicate detection, pagination, and measured caching.
- Design Practice Mode through a backend `checkAnswer` contract without weakening
  Exam Mode.
- Add a React Admin Dashboard only when moderation workflows require it.

### V3
- Extract questions, flashcards, and study guides from user-provided sources.
- Store citations/provenance and require review before publishing generated work.
- Revisit service extraction only with evidence from scale or team ownership.
