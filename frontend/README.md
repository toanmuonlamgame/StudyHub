# StudyHub Frontend

The Flutter app uses `MockLearningRepository` by default.

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
