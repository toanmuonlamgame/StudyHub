# StudyHub Android MVP Release Readiness

This checklist prepares a local Android release candidate. It does not deploy
the backend, apply database migrations, create signing credentials, or publish
to Google Play.

## Release Identity

- App name: `StudyHub`
- Android application ID: `com.toanmuonlamgame.studyhub`
- Version name/code: `1.0.0` / `1`
- Minimum, target, and compile SDK versions follow the installed Flutter SDK.
- The current launcher icon is the Flutter template icon. Replacing it with
  final StudyHub branding is post-MVP polish.

## Required Tools

- Flutter SDK and Android SDK/JDK 17
- Node.js and npm
- PostgreSQL for Prisma runtime mode
- ADB or Android Studio for device installation and log inspection

## Backend Production Configuration

Keep real values in the deployment environment, never in Git. Start from
`backend/.env.example` only as a field reference.

```text
NODE_ENV=production
PORT=3000
STUDYHUB_LEARNING_DATA_SOURCE=prisma
DATABASE_URL=<secret PostgreSQL connection string>
STUDYHUB_CORS_ORIGINS=https://trusted-web-origin.example
```

`STUDYHUB_CORS_ORIGINS` is a comma-separated browser allowlist. Native Android
requests do not send a browser Origin header. Production refuses an implicit or
memory Learning data source and Prisma mode refuses a missing `DATABASE_URL`.
Fastify accepts request bodies up to 1 MiB, sanitizes unexpected server errors,
and closes on `SIGINT`/`SIGTERM`.

```powershell
cd backend
npm ci
npm run prisma:generate
npm run prisma:validate
npm run prisma:migrate:deploy
npm run build
npm start
```

Review migration SQL and back up the target database before personally running
`prisma:migrate:deploy`. Normal automated tests do not apply migrations.

## Flutter Development Configuration

Debug builds default to mock mode. Android debug permits cleartext HTTP for a
local backend; the main/release manifest does not enable cleartext traffic.

Android emulator:

```powershell
flutter run --dart-define=STUDYHUB_LEARNING_SOURCE=api `
  --dart-define=STUDYHUB_API_BASE_URL=http://10.0.2.2:3000
```

Real Android device on the same LAN:

```powershell
flutter run --dart-define=STUDYHUB_LEARNING_SOURCE=api `
  --dart-define=STUDYHUB_API_BASE_URL=http://<developer-computer-LAN-IP>:3000
```

The backend must listen on `0.0.0.0`, Windows Firewall must permit the selected
port, and both devices must share the network.

## Android Release APK

Release mode accepts only API mode and an explicit HTTPS origin. It never falls
back to mock data, localhost, the emulator address, or cleartext HTTP.

```powershell
cd frontend
flutter pub get
flutter build apk --release `
  --dart-define=STUDYHUB_LEARNING_SOURCE=api `
  --dart-define=STUDYHUB_API_BASE_URL=https://<deployed-api-origin>
```

Output: `frontend/build/app/outputs/flutter-apk/app-release.apk`.

The repository currently signs local release-candidate APKs with the Android
debug key. That is suitable only for local installation. Before external
distribution, create a private upload keystore outside Git, configure local
`key.properties`, protect backups/passwords, and replace the debug signing
configuration. Never commit a keystore or signing credentials.

### Verified Local Build Baseline (2026-07-21)

- Debug APK built successfully: `150,857,494` bytes (`143.87 MiB`).
- Universal release APK built successfully: `54,124,146` bytes (`51.62 MiB`).
- Release metadata: `com.toanmuonlamgame.studyhub`, version `1.0.0` (`1`),
  minimum SDK 24, label `StudyHub`.
- The release manifest contains Internet permission and does not enable
  cleartext traffic.
- The release build used `https://api.example.invalid` only to verify release
  configuration and compilation. It cannot connect to a real backend.
- The release APK is debug-signed for local testing. It is not a production
  distribution artifact.

The current universal APK size is acceptable for a local MVP candidate, but it
is not a measured performance result. Before store distribution, compare an
Android App Bundle or split-per-ABI output and test startup/responsiveness on a
representative lower-spec device.

## Safe Verification Commands

```powershell
cd backend
npm run prisma:validate
npm run prisma:generate
npm run typecheck
npm run build
npm test

cd frontend
flutter gen-l10n
dart format lib test
flutter analyze --no-pub
flutter test
flutter build apk --debug
```

## iQOO Z9 Turbo Device Checklist

- [ ] Review Git diff and confirm no secret or local `.env` is tracked.
- [ ] Back up the database, review migrations, apply them, and run Prisma smoke tests.
- [ ] Start the real Prisma backend and verify `/health` and Learning endpoints.
- [ ] Install the APK as a fresh install; confirm the StudyHub name and launch.
- [ ] Check Home layout, Subject/Topic loading, Question Set list, and search.
- [ ] Complete an Exam: navigate answers, submit, review, save, and return Home.
- [ ] Open Attempt History and detail, then return Home without stale routes.
- [ ] Complete Practice Mode and verify immediate feedback and final review.
- [ ] Create and submit a manual contribution; verify one pending submission.
- [ ] Paste a long Vietnamese exam, preview, edit, submit, and return Home.
- [ ] Stop the backend, verify safe errors, restart it, retry, and check no duplicates.
- [ ] Rapidly tap submit/retry/Home and confirm only one action/result occurs.
- [ ] Test keyboard-open forms, long Vietnamese text, and 1.5x display text.
- [ ] Test Android Back during browsing and during an active Exam.
- [ ] Background/resume the app during browsing and an unfinished form.
- [ ] Cold-start on a slow network and check loading/error/retry states.
- [ ] Reinstall/update the APK and verify expected local-data behavior.

Do not mark device checks complete until they are performed on the physical
device. Minimum account authentication and ownership are implemented, but this
candidate is not ready for public multi-user use until the auth/bookmark migration,
Prisma smoke tests, abuse controls, and dedicated security stabilization complete.
