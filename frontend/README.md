# StudyHub Frontend

The Flutter app uses `MockLearningRepository` by default.

## Learner navigation

StudyHub is mobile-first. The top-level Material 3 shell contains Home, Learn,
Progress, and Settings. Browse, detail, mode selection, quiz, and result screens
open as focused routes above the shell, so bottom navigation does not distract
from a learning session.

Progress remains an honest planned state without invented history or streaks.
Settings exposes only the functional language preference plus app/safety information.

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
