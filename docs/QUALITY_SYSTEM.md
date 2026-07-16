# StudyHub Quality System

## Purpose
This quality system is the review standard for future StudyHub features. It
balances learning value, modern visual polish, feature depth, mobile performance,
small app size, API efficiency, security, and maintainability.

## A. Product Quality Principles
- Build a beautiful and useful learning product, not a bare-minimum interface.
- Add rich features through the roadmap, not all in one sprint. Each phase must
  remain understandable, testable, and usable.
- Optimize implementation before considering feature removal. Performance work
  should eliminate waste without eliminating learning value.
- Make the core browse, study, quiz, result, and contribution flows feel clear,
  motivating, trustworthy, and polished.
- Bulk creator inputs must be previewed and validated as one unit. Never hide
  malformed blocks or silently submit only the valid subset.
- Canonical user-facing import formats must remain documented and stable;
  compatibility aliases stay isolated from widgets and recommended templates.
- Prefer evidence from learners and measurements over assumptions about what is
  engaging or slow.

## B. UI Polish Guidelines
- Use a consistent spacing scale, alignment, card treatment, and content width so
  screens feel related. Cards should frame meaningful repeated items, not every
  section or nested surface.
- Define clear typography roles for page titles, section headings, body text,
  labels, metadata, scores, and feedback. Keep compact surfaces compact.
- Use color hierarchy intentionally: primary actions, neutral structure, success,
  warning, error, and disabled states must remain distinguishable and accessible.
- Every remote-data screen needs designed loading, empty, error, and retry states.
  Empty states should explain the state and offer the most relevant next action.
- Use skeletons when preserving content shape improves perceived loading; use a
  compact progress indicator when the final layout is unknown or the wait is short.
- Quiz results and rewards should provide clear, encouraging feedback without
  hiding mistakes or overwhelming the learner with celebration effects.
- Use familiar icons with accessible labels or tooltips where needed. Visual
  hierarchy should make the next action obvious without filling the screen with
  competing buttons, cards, badges, or colors.
- Prefer purposeful destinations and concise learner guidance over filler copy.
  Never use fake progress, fake account activity, discounts, scarcity, or
  unsupported promotional claims to make a screen appear richer.
- Label unfinished capabilities clearly and keep them non-interactive until their
  real contract, data, validation, and failure states exist.
- Check long text, small screens, text scaling, contrast, and touch-target size.

## C. Animation Guidelines
Purposeful animation is allowed for:

- Page transitions and navigation continuity.
- Button press, selection, and submission feedback.
- Quiz-result reveal and correct/incorrect feedback after submission.
- Progress changes and completion moments.
- Subtle micro-interactions that confirm state changes.

Avoid:

- Heavy continuous background animation.
- Excessive blur, glass, shader, or layered transparency effects.
- Animation that blocks navigation, answering, submission, or review.
- Animating every item in a long or frequently scrolling list.
- Replaying heavy celebration effects whenever a screen rebuilds.

Animation budget:

- Keep common feedback and micro-interactions around 100-250 ms.
- Keep most transitions and result reveals within 300-400 ms unless user testing
  demonstrates a clear reason otherwise.
- Animations must be lightweight, interruptible or skippable, and non-blocking.
- Avoid repeated heavy animation in lists and measure frame smoothness on a
  representative lower-end Android device.
- Respect reduced-motion preferences and provide a simpler equivalent state.

## D. Frontend Performance Checklist
- Load data by screen and user action; do not fetch the whole learning domain.
- Do not load all Subjects, Question Sets, Questions, attempts, or uploads at once.
- Avoid unnecessary widget rebuilds and keep changing state close to its owner.
- Add pagination or incremental loading when list data grows.
- Avoid large bundled assets; reuse appropriate icons and remove unused assets.
- Compress and resize uploaded or downloaded images when real media is introduced.
- Keep interaction responsive during API work and prevent duplicate submissions.
- Show stable loading, error, empty, retry, and offline-aware states where relevant.
- Consider release app size when adding assets, native code, or dependencies.
- Measure startup, first useful content, perceived loading, and frame smoothness
  before and after major UI features.

## E. Backend API Performance Checklist
- Keep payloads endpoint-specific and return only fields required by the workflow.
- Use explicit Prisma selection/mapping rather than returning broad database rows.
- Add pagination to growing list endpoints and define stable ordering/cursors.
- Cache stable, read-heavy public taxonomy and published content only after
  measuring need; define invalidation before introducing the cache.
- Review Prisma queries for N+1 access and avoid per-item queries in list loops.
- Add indexes for measured filters, joins, ordering, and uniqueness requirements.
- Return correctness metadata only after quiz submission or an approved Practice
  Mode check; never include it in pre-submit question payloads.
- Add rate limiting before public write, upload, reward, AI, or expensive endpoints.
- Return consistent status codes and concise, actionable error responses without
  leaking secrets or internal database details.

## F. Feature Quality Checklist
Every proposed feature must answer:

- Is it useful to the learner, contributor, moderator, or administrator it serves?
- What learning outcome or workflow does it improve?
- Does it add complexity that belongs in a later roadmap phase?
- Does it require backend validation, persistence, authorization, or auditability?
- Will its data require pagination, lazy loading, or measured caching?
- Could it expose private data, answer keys, permissions, credits, or secrets?
- Are loading, empty, error, retry, disabled, and success states designed?
- Does the interface remain polished, accessible, and understandable on mobile?
- What is the verification plan and what performance risk should be measured?

## G. Definition Of Done
### Frontend Feature
- UI and primary interactions work on the supported screen sizes.
- Loading, empty, error, retry, disabled, and success states are handled as needed.
- Repository/API boundaries are respected; screens do not import mock data directly.
- The frontend does not call the database or contain secrets.
- Tests or focused manual verification cover the main flow and meaningful failures.
- Accessibility, long text, back navigation, and duplicate actions are checked.
- The handoff includes a short performance note: loading scope, rebuild risk,
  assets/dependencies added, and measurements performed or deferred.

### Backend Feature
- Route, request/response types, service boundary, and persistence mapping are clear.
- Fastify validation and `Fastify.inject` tests cover success and key errors.
- No secret or private configuration enters code, fixtures, docs, or logs.
- Responses are scoped and do not return unnecessary database fields.
- Error handling uses clear status codes without leaking internal details.
- Correctness, authorization, credit, reward, and moderation data stay backend-owned.
- Pre-submit responses do not leak database correctness metadata.
- API documentation is updated whenever the public contract changes.

## H. Roadmap Application
### Practice Mode
Design a backend `checkAnswer` contract, preserve Exam Mode secrecy, provide quick
feedback, prevent duplicate requests, and keep correctness out of initial payloads.

### Upload Study Materials
Design polished progress, validation, retry, and failure states. Validate type and
size on the backend, store ownership/status, and add moderation before discovery.

### AI Extraction
Run asynchronously, show progress and recoverable errors, retain source citations
and generation metadata, and require human review before publication. Add limits
and rate protection because extraction is expensive.

### React Admin Dashboard
Build it only when moderation and content operations are real. Reuse backend
contracts and semantic design rules without copying the mobile layout.

### Study Credits
Keep balances, transactions, rewards, and unlocks backend-owned and audited. Add
clear UI explanations, idempotent actions, abuse protection, and no cash-out path.

### Search And Filter
Use debouncing where useful, server-side filtering for growing data, pagination,
stable ordering, compact result payloads, and clear no-result/error states.

### User Progress And Streaks
Use progress to motivate learning rather than punish absence. Define timezone and
offline behavior, keep calculations backend-owned when they affect rewards, and
avoid startup-blocking refreshes or excessive celebration animation.

Before authentication, device-local progress may store bounded summaries from
trusted post-result data only. Keep persistence behind an injectable store, never
derive correctness again in Progress UI, and never invent streaks, history, or
analytics. Account sync must later define ownership, migration, and conflict rules.

## Review Use
Before a major feature commit, select the relevant sections above and include the
results in the task handoff. A small feature does not need every item, but skipped
items should be intentional rather than accidental.

For list, filter, search, caching, or analytics work, also apply the endpoint and
data-growth checklist in
[SCALABILITY_AND_SEARCH.md](SCALABILITY_AND_SEARCH.md). In particular, verify
bounded payloads, stable pagination, indexed filtering, visibility rules, and the
absence of correctness/private-data leaks.

## Creator Content Guardrail

- Keep creator answer-key models separate from learner-safe models.
- Validate locally for feedback and authoritatively on the backend.
- Preserve local drafts after network or validation failure.
- Never auto-publish community content; successful submission means
  `pendingReview` only.
- Filter public search and learning queries by `published` before DTO mapping.
- Require authenticated ownership and moderator authorization before exposing
  production editing or moderation actions.
