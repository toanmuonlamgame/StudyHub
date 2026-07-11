# Phase 1 Checkpoint

## 1. Phase 1 Goal
Phase 1 established a working, testable core learning foundation. Its purpose
was to prove the learner flow, frontend/backend boundaries, answer safety,
persistence adapters, and scalable list contract. It was not intended to finish
the production visual design or every platform feature.

## 2. Completed Capabilities
### Flutter Learner App
- Flutter application foundation with a clear multi-screen learning flow.
- Home, Subject browsing, Question Set browsing, and Question Set Detail.
- Dedicated Mode Selection for Exam Mode and Practice Mode.
- Exam Mode submission followed by score and answer review.
- Practice Mode feedback after each explicit answer check.
- Mock mode through `MockLearningRepository`.
- API mode through `ApiLearningRepository` and non-secret `dart-define` config.
- First-page integration with the paginated Question Set API.
- Flutter repository and widget tests covering the main learning flow.

### Backend And Persistence
- Node.js, TypeScript, and Fastify Learning API.
- `LearningService` boundary with `InMemoryLearningService` and
  `PrismaLearningService` adapters.
- Subject, Topic, Question Set, Question, and Answer Option endpoints/data.
- Exam Mode `submitQuiz` endpoint and Practice Mode `checkAnswer` endpoint.
- Paginated Question Set endpoint with filters, bounded limit, and opaque cursor.
- PostgreSQL and Prisma schema, migrations, repeatable seed, and data-source switch.
- Initial Prisma indexes for current filters and stable ordering.
- Fastify injection tests, service tests, and an opt-in PostgreSQL Prisma smoke test.

## 3. Safety Guarantees
- GET question payloads do not expose correct answers or `isCorrect`.
- Question Set list responses contain compact metadata, not questions, answer
  options, correctness, or answer keys.
- The backend calculates authoritative Exam Mode scores.
- Practice Mode reveals correctness only after `checkAnswer` for that question.
- Exam Mode reveals correctness only after whole-quiz submission.
- Flutter calls backend APIs and never accesses PostgreSQL directly.
- Secrets and real credentials must not be committed.
- `backend/.env` remains local and ignored by Git.

## 4. Performance And Scalability Foundation
- Cursor pagination uses stable `createdAt + id` ordering.
- List responses are compact and bounded to a validated maximum.
- Filtering and search parameters are handled by the backend rather than by
  downloading whole datasets to Flutter.
- PostgreSQL remains the source of truth and the first search implementation.
- Initial indexes support Question Set subject/topic pagination and ordered
  Topic, Question, and Answer Option reads.
- Later caching, external search, and analytics are planned as measured additions,
  not Phase 1 dependencies.

## 5. Known Limitations
- The learner UI has an initial visual structure but still needs production-level
  polish, responsive verification, and measured interaction refinement.
- There is no production authentication or authorization yet.
- User progress, attempt history, and streaks are not persisted yet.
- Study Material upload is not implemented yet.
- The React Admin Dashboard is not implemented yet.
- Vietnamese localization is not available yet.
- There is no external search engine or shared cache.
- Difficulty and estimated time are provisional values derived from question count.
- Flutter currently consumes the first Question Set page; load-more/search UI is deferred.

## 6. Phase 2 Start Criteria
Phase 2 starts from the stable learning contracts and tests completed above. It
should focus on a professional learner UI, a documented visual design system,
responsive layouts, lightweight purposeful animation, micro-interactions,
accessibility, text scaling, and touch targets. Vietnamese localization should
follow once the principal UI structure and terminology are stable.

Phase 2 must preserve repository/service boundaries, mock/API modes, test
coverage, compact payloads, and the Phase 1 answer-safety guarantees.

## 7. Recommended Phase 2 Milestones
- **CM37:** Polish the visual design system and responsive learner surfaces.
- **CM38:** Add lightweight learner animations and micro-interactions.
- **CM39:** Add the Vietnamese localization foundation.
- **CM40:** Add the search/filter UI foundation, followed by cursor load-more.
