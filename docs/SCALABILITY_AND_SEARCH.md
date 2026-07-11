# Scalability And Search

## 1. Problem Statement
StudyHub may grow from small fixtures into many subjects, topics, Question Sets,
questions, Study Materials, uploads, users, attempts, filters, and search queries.
Flutter must not download whole datasets and filter them locally. The backend and
PostgreSQL should return small, indexed slices that match the current screen.

## 2. Core Principles
- Filter, authorize, order, and paginate on the backend.
- Prefer cursor pagination for lists that can grow significantly.
- Keep PostgreSQL as the transactional source of truth.
- Return compact list DTOs; fetch detail only when opened.
- Treat an external search engine as an optional later read index, not a V1 need.
- Cache measured read-heavy public data later, with an invalidation plan.
- Separate future analytics workloads from the transactional learning API.

## 3. Future API List Contract

```text
GET /learning/question-sets?subjectId=...&topicId=...&q=...&difficulty=...&limit=20&cursor=...
GET /learning/materials?subjectId=...&topicId=...&q=...&type=...&limit=20&cursor=...
```

```json
{
  "items": [],
  "nextCursor": "opaque-cursor-or-null",
  "hasMore": true
}
```

Contract rules:
- Validate `limit`, provide a conservative default, and enforce a maximum.
- Use a stable order with a unique tie-breaker, such as `createdAt DESC, id DESC`.
- Treat cursors as opaque client values and reject malformed cursors clearly.
- Prefer cursor pagination over large offsets as data grows.
- List endpoints return metadata only, never full questions or correct answers.
- Existing endpoints remain working while paginated variants are introduced.

## 4. Filtering Strategy
Add filters only when the model and user workflow support them:

- First: `subjectId`, `topicId`, content type, publication status.
- Next: school, program/system, major, difficulty, language, and tags.
- Later: creation date, popularity, usage, and moderation/admin filters.

Filters must be validated, permission-aware, composable, and backed by measured
indexes. Public queries must exclude drafts, rejected content, and private data.

## 5. PostgreSQL Indexing Plan
Candidate indexes should be added through reviewed Prisma migrations:

- `QuestionSet`: `(subjectId, status, createdAt, id)` and
  `(topicId, status, createdAt, id)` when status exists.
- `Question`: existing `(questionSetId)` plus stable `(questionSetId, position)`.
- `Topic`: existing `(subjectId)`; consider `(subjectId, name)` for ordered lists.
- `StudyMaterial`: `(subjectId, status, createdAt, id)` and
  `(topicId, status, createdAt, id)` when implemented.
- Upload: `(ownerId, status, createdAt, id)` when implemented.
- `QuizAttempt`: `(userId, createdAt, id)` and
  `(questionSetId, createdAt, id)` when implemented.
- Tag join tables: unique content/tag pairs plus indexes in both lookup directions.
- Search: PostgreSQL full-text or trigram indexes for title/description only after
  query patterns and language needs are known.

Avoid speculative indexes: each index increases write and storage cost. Confirm
important queries with `EXPLAIN ANALYZE` before and after index changes.

## 6. Search Strategy
### V1
- Use PostgreSQL `ILIKE` or basic full-text search for small, simple datasets.
- Search compact published-content metadata, not question/answer payloads.

### V2
- Add PostgreSQL full-text search, appropriate indexes, and ranking weighted
  toward title, topic, and measured usage signals.
- Define language/tokenization behavior and stable pagination for ranked results.

### V3
- Evaluate Meilisearch, Typesense, or OpenSearch only when PostgreSQL search no
  longer meets measured relevance, latency, typo-tolerance, or scale needs.

PostgreSQL remains authoritative. Any external search index must be rebuildable,
permission-aware, and free of secrets, private/admin-only content, drafts, and
unreleased correct answers.

## 7. Caching Strategy
- Start without Redis; measure latency, query frequency, and database load first.
- Later cache stable Subjects, Topics, and published Question Set metadata.
- Consider safe HTTP cache headers for public, versioned responses.
- Invalidate or version cached data when moderation/admin updates are published.
- Never casually cache private user data, permissions, attempts, credits, rewards,
  or answer-key responses.

## 8. Big Data And Analytics Strategy
Start with transactional PostgreSQL. Add structured event logging only after
events, consent, retention, and privacy rules are defined. Prefer summary tables
or materialized views before introducing a data warehouse. BigQuery or another
warehouse becomes relevant only when analytical workload or volume justifies the
operational cost.

Useful future aggregates include:
- Popular Question Sets and completion rates.
- Wrong-answer rates by question without exposing individual private answers.
- Active learners and learning-flow drop-off.
- Upload review throughput and rejection reasons.
- Search queries with no results.

Analytics processing must not slow or weaken the transactional API.

## 9. Flutter Implications
- List screens should evolve toward pagination or infinite scrolling.
- Debounce search input and cancel/ignore stale responses.
- Do not cache large datasets blindly; define bounded, purpose-specific caches.
- Preserve loading, empty, error, retry, and end-of-list states.
- Avoid unnecessary rebuilds in long lists and use stable item identities.
- Use compact list DTOs and fetch detail/questions only when the user opens them.

## 10. Backend Definition Of Done For List/Search Endpoints
Every growing list/search endpoint should:
- Accept and validate `limit` and `cursor`, including a maximum limit.
- Use stable ordering and indexed filters.
- Return a compact `{ items, nextCursor, hasMore }` payload.
- Avoid N+1 Prisma queries and broad raw-row responses.
- Never return answer correctness or unauthorized/private content.
- Include Fastify injection tests for success, validation, pagination boundaries,
  filtering, and permission-sensitive visibility.
- Document request parameters, ordering, and response shape.

## 11. Migration Plan
1. Keep current endpoints and clients working.
2. Add paginated Question Set and Study Material list endpoints incrementally.
3. Add query-driven PostgreSQL indexes through Prisma migrations.
4. Add validated search parameters and PostgreSQL-first search.
5. Add measured caching for stable, read-heavy public metadata.
6. Introduce an external search engine only if PostgreSQL is demonstrably insufficient.
7. Add an analytics/event pipeline only when product questions and volume justify it.
