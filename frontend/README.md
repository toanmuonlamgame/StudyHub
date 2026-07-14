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

Run with local mock data:

```bash
flutter run
```

Run against the backend mock Learning API from an Android emulator:

```bash
flutter run \
  --dart-define=STUDYHUB_LEARNING_SOURCE=api \
  --dart-define=STUDYHUB_API_BASE_URL=http://10.0.2.2:3000
```

These values select a development data source and URL only. Do not place API
keys, tokens, passwords, or other secrets in `dart-define` values.

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
