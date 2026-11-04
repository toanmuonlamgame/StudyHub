# StudyHub Android MVP Release Readiness

This checklist prepares a local Android release candidate. It does not deploy
the backend, apply database migrations, create signing credentials, or publish
to Google Play.

## Release Identity

- App name: `StudyHub`
- Android application ID: `com.toanmuonlamgame.studyhub`
- Version name/code: `1.0.0` / `1`
- Minimum, target, and compile SDK versions follow the installed Flutter SDK.
- Android uses the StudyHub launcher icon. The source artwork is
  `frontend/branding/studyhub-icon.png`.

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

### First cloud staging pass

- Use a separate PostgreSQL database, a Node host that supports the toolchain
  (local baseline: Node 24), an injected port, HTTPS, and server-side secrets.
- Build with dev dependencies available: `npm ci --include=dev`, then
  `npm run prisma:generate` and `npm run build`. Run the migration as a separate
  step with the Prisma CLI available; start with `npm start`.
- On an empty staging database, add approved demo content. Only seed a
  disposable staging database if the development fixtures are intended there.
- From `backend`, run
  `npm run test:staging -- https://your-api.example`. This checks HTTPS, health,
  data-source readiness, a non-empty catalog, and answer safety without
  credentials or writes.
- Verify registration, saved exams, quiz submission, and contributions using
  a disposable account on a physical device. The read-only smoke does not
  verify authentication, database writes, or the Android build.
- If the host uses an ephemeral filesystem, do not rely on uploaded images
  surviving restarts. Use a persistent volume or object storage before testing
  media durability or onboarding real users. Do not expose staging as a public
  release while abuse controls and production storage are outstanding.

### Cloud Run + PostgreSQL staging

1. Create a separate PostgreSQL database for staging. Store the connection
   string as a Secret Manager secret, and grant the Cloud Run runtime service
   account access to that secret only. Do not put the value in build arguments
   or commit it.
2. From `backend`, run `npm ci` and
   `npm run prisma:migrate:deploy` against the reviewed staging database.
   Supply `DATABASE_URL` securely in that terminal only. Do not run
   development fixtures on a production database.
3. Deploy from the backend directory with the Cloud Run source deploy
   workflow. The Node buildpack runs `gcp-build` to generate Prisma Client
   and compile TypeScript; the service starts with `npm start`.

   ```powershell
   gcloud run deploy studyhub-staging --source . --region REGION `
     --allow-unauthenticated --min-instances 0 --max-instances 2 `
     --set-build-env-vars GOOGLE_NODEJS_VERSION=24.x `
     --set-env-vars NODE_ENV=production,STUDYHUB_LEARNING_DATA_SOURCE=prisma `
     --set-secrets DATABASE_URL=studyhub-staging-database-url:1
   ```

   Replace `REGION` and the secret reference as needed. Public invocation
   lets the mobile client reach the API; protected application endpoints
   still require a StudyHub session. Instance limits are not spending caps.
4. Load approved demo content, run `npm run test:staging -- https://...`,
   and build the Android release candidate against that same HTTPS origin.
   Verify login, Exam, Practice, bookmarks and contribution on a real device.

For a Chrome smoke test against staging, run from `frontend`:

```powershell
flutter run -d chrome --web-port=8080 `
  --dart-define=STUDYHUB_LEARNING_SOURCE=api `
  --dart-define=STUDYHUB_API_BASE_URL=https://your-api.example
```

Add the exact origin shown in Chrome (typically `http://localhost:8080`) to
the staging service's `STUDYHUB_CORS_ORIGINS` for this test, then remove it
when no longer needed. Android does not need this CORS entry.

### Local device configuration

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

Run `flutter doctor -v` before building. If the Android SDK has moved, point
`ANDROID_HOME` at the installed SDK and make sure the ignored
`frontend/android/local.properties` does not still point to the old path.

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

Without a local Android SDK, use GitHub Actions > **Build Android staging APK**
after this workflow is pushed. Enter the public staging HTTPS origin and
download the artifact for your device ABI: `studyhub-staging-arm64` for most
current Android phones, `studyhub-staging-arm32` for 32-bit ARM devices, or
`studyhub-staging-x64` for x86_64. Each APK includes only the native code for
that ABI. It is debug-signed for
testing, not a Play Store build. CI and locally generated debug keys may differ;
Android may require uninstalling the previous build before installing the new
one, which clears local app data.

Set the optional GitHub repository variable `STUDYHUB_SUPPORT_EMAIL` to a
monitored public inbox before building an APK for testers. This address is
visible in Settings and is not a secret. An unset or invalid address hides
the contact entry. Tapping it opens an email draft; users still send it
themselves. This is an email contact, not an in-app report queue.
Optional public HTTPS repository variables `STUDYHUB_PRIVACY_URL`,
`STUDYHUB_TERMS_URL`, and `STUDYHUB_UPDATES_URL` add official links to
the corresponding Settings pages. Publish and review these pages before
setting the variables; the app does not create or publish them.

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
- [ ] Open Play and Learn, complete both word games, and verify missed-word
  replay and keyboard usability on the device.
- [ ] Create and submit a manual contribution; verify one pending submission.
- [ ] Paste a long Vietnamese exam, preview, edit, submit, and return Home.
- [ ] Stop the backend, verify safe errors, restart it, retry, and check no duplicates.
- [ ] Rapidly tap submit/retry/Home and confirm only one action/result occurs.
- [ ] Test keyboard-open forms, long Vietnamese text, and 1.5x display text.
- [ ] Check portrait and landscape on a device with a display cutout and
  compare app/data/cache size before and after repeated image uploads.
- [ ] Test Android Back during browsing and during an active Exam.
- [ ] Background/resume the app during browsing and an unfinished form.
- [ ] Cold-start on a slow network and check loading/error/retry states.
- [ ] Reinstall/update the APK and verify expected local-data behavior.

Do not mark device checks complete until they are performed on the physical
device. Minimum account authentication and ownership are implemented, but this
candidate is not ready for public multi-user use until the auth/bookmark migration,
Prisma smoke tests, abuse controls, and dedicated security stabilization complete.
