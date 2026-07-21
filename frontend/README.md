# StudyHub Frontend

The Flutter app uses `MockLearningRepository` by default.

## Learner navigation

StudyHub is mobile-first. The top-level Material 3 shell contains Home, Learn,
Progress, and Settings. Browse, detail, mode selection, quiz, and result screens
open as focused routes above the shell, so bottom navigation does not distract
from a learning session.

Progress shows real completed Exam and Practice summaries stored on the current
device without invented history, charts, or streaks. Settings exposes only the
functional language preference plus app/safety information.

Completed Result/Review, Attempt detail, and contribution confirmation screens
offer a direct Back to Home action. It selects the existing Home tab and clears
obsolete deep routes instead of stacking another shell; normal Back navigation
still follows the browsing hierarchy, and active Exams keep discard protection.

## Device-local progress

`ProgressStore` separates Progress UI from persistence. The default
`SharedPreferencesProgressStore` stores a compact JSON history ordered newest
first and bounded to 100 sessions. `StudyHubApp` owns or accepts an injected store,
which keeps widget tests independent from device storage.

Each completed session is created once from trusted `QuizResult` data after Exam
submit or the final Practice check. Stored fields are limited to session ID,
question-set ID/title, mode, correct/total counts, percentage, and completion
time. Full questions, selected answers, answer keys, credentials, and secrets are
not persisted. Save failures do not block the result screen.

This history is device-local until real authentication and backend progress sync
are implemented. Clearing it requires confirmation and cannot currently be undone
or recovered from another device.

## Exam attempt history

Completed Exam results are also saved through `AttemptRepository`. Mock mode
keeps an in-memory history; API mode calls the backend save/list/detail endpoints.
The result remains visible while saving, reports failure honestly, and retries
with the same submission ID so the backend does not create duplicates.

The History action in Progress opens a newest-first Exam list and reuses the
normal result-review screen for detail. Backend history currently belongs to a
temporary demo identity until authentication exists. Practice remains in the
device-local Progress store and is not presented as server-synced history.

## Home hub architecture

Home is a repository-lazy mobile hub. It does not fetch Subjects or other remote
learning data during startup. An explicit Start Learning, Browse Subjects, Exam,
or Practice action switches to Learn; Progress and Settings shortcuts switch to
their corresponding shell tabs.

The Home feature is split into a screen, immutable banner model, and focused
widgets under `lib/features/home`. Its `PageView` is manually controlled and does
not auto-rotate. Banner copy describes real learning flows rather than prices,
discounts, or unsupported product claims. Study Materials is now an active deep
route. Saved Content and Learning Plans remain visibly labeled `Coming soon`
and have no fake interaction.

Shared presentation primitives such as section headers, icon surfaces, upcoming
badges, and empty metric cards live in `lib/core/widgets/studyhub_ui.dart`. They
carry structure and semantics only; learning data and answer safety remain behind
the repository boundary.

## Localization

The system interface supports English and Vietnamese through Flutter ARB
resources in `lib/l10n`. Settings offers System default, English, and Tiếng Việt;
the selected non-sensitive preference applies immediately and persists with
`shared_preferences`.

Learning content is intentionally separate from interface localization. Subject,
topic, question-set, question, answer, and future creator-uploaded text is shown
exactly as returned by the active repository and is not auto-translated.

After editing an ARB file, regenerate typed localization accessors with:

```bash
flutter gen-l10n
```

`flutter pub get` also performs generation for this project because
`flutter.generate` is enabled.

## Question Set search and pagination

Question Set browsing sends `subjectId`, optional `topicId`, debounced title
query `q`, bounded `limit`, and `cursor` through `LearningRepository`. API mode
uses the compact backend endpoint; mock mode implements the same filters and
stable cursor behavior for local development. Load-more failures keep existing
items visible and can be retried without duplicating cards.

## Question Set contribution

Creators can build a Question Set manually or paste a complete structured exam.
The canonical paste format is:

```text
/question: What is 2 + 2?
/answer1: 3
/answer2: 4
/correct: 2
/explanation: 2 + 2 equals 4.
```

The local typed parser reports recognized, valid, and invalid questions with
source-line guidance. Severe errors block the complete import; valid content
returns to the normal editor and uses the existing contribution API. The manual
editor supports add-next, duplicate, and safe reset actions. Compatibility
aliases may be read for migration convenience, but templates only advertise the
canonical tags above.

## Exam Session and Result Review

Exam Mode presents one question at a time, preserves changed answers across
previous/next navigation, and confirms before discarding meaningful progress.
Learners may submit with unanswered questions after an explicit count-based
confirmation. Flutter sends only selected option IDs; repository/backend logic
calculates the trusted result outside widgets.

Results separate correct, incorrect, and unanswered counts. Percentages are
rounded to the nearest whole percent in mock and backend modes. Post-submit
review can show every answer option, the learner choice, correct choice, and an
optional explanation without exposing correctness in pre-submit question data.
Completed Exam attempts now save through an injected attempt repository with
loading, failure, and same-key retry states. Attempt History lists newest-first
summaries and reopens the trusted snapshot review. Prisma mode still requires
the prepared attempt migration and real API smoke test before database use.

Run with local mock data:

```bash
flutter run
```

Mock is a development default only. Release builds must explicitly set
`STUDYHUB_LEARNING_SOURCE`. When the selected source is `api`, release builds
must also set `STUDYHUB_API_BASE_URL`; they never silently fall back to fixture
data or the Android emulator URL.

Run against the backend mock Learning API from an Android emulator:

```bash
flutter run \
  --dart-define=STUDYHUB_LEARNING_SOURCE=api \
  --dart-define=STUDYHUB_API_BASE_URL=http://10.0.2.2:3000
```

These values select a development data source and URL only. Do not place API
keys, tokens, passwords, or other secrets in `dart-define` values.

Learning, contribution, and attempt API adapters apply a 15-second request
timeout by default. Existing loading/error/retry surfaces handle an unavailable
backend without silently losing a creator draft or hiding a completed result.

Run checks with:

```bash
flutter analyze --no-pub
flutter test
```

## Study Materials

The Home Study Materials tile opens a separate mobile-first browsing flow.
`LearningRepository` provides paginated metadata listing and on-demand detail in
both mock and API modes. Search is debounced, filters reset pagination, stale
responses are ignored, and next-page failures preserve existing cards.

Only published metadata is presented. External URLs are displayed as selectable
resource text; uploaded-file entries show honest metadata and an unavailable
prototype state. There is no binary upload, cloud storage, authentication,
ownership, or moderation UI yet.

## Contribute Questions

Home opens a mobile creator flow: introduction, details, question builder,
creator-only review, submit for review, and pending confirmation. Creator draft
models are separate from learner-safe models because they contain the selected
correct answer.

The draft stays in Flutter memory until final confirmation. Mock mode validates
locally; API mode calls `POST /learning/question-set-submissions/submit`. A
failed request keeps form state and retries with the same client submission ID,
allowing the backend to return the original pending-review submission instead
of creating a duplicate. Draft sync, authenticated ownership,
moderation UI, and rewards are deferred.

The creator contract currently allows at most 50 questions and 8 answer options
per question. The prepared contribution and idempotency migrations plus a real
Flutter API-mode submit/retry still require manual verification before this flow
is treated as database-ready.
