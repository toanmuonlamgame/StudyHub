# StudyHub Frontend

The Flutter app uses `MockLearningRepository` by default in development. Release
builds require API mode and an explicit HTTPS API origin.

Android displays the app as `StudyHub` with application ID
`com.toanmuonlamgame.studyhub` and version `1.0.0+1`. The main manifest requests
only Internet access. Debug builds allow cleartext HTTP for emulator/LAN
development; release builds do not enable cleartext traffic.

## Learner navigation

StudyHub is mobile-first. The top-level Material 3 shell contains Home, Learn,
Progress, and Settings. Browse, detail, mode selection, quiz, and result screens
open as focused routes above the shell, so bottom navigation does not distract
from a learning session.

Progress shows real completed Exam and Practice summaries stored on the current
device without invented history, charts, or streaks. Settings exposes account,
profile, Saved Question Sets, logout, language, version, privacy/security, and
About StudyHub information.

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
normal result-review screen for detail. Backend history belongs to the
authenticated account. Practice remains in the device-local Progress store and
is not presented as server-synced history.

## Authentication And Account Data

API mode supports registration, login, session restore, display-name editing,
and logout through `AuthRepository`. The app gates protected learner screens
until authentication succeeds. An invalid or expired stored session is cleared
when `/auth/me` rejects it, returning the user to the localized auth screen.

Attempt history, contribution management, and Saved Question Sets use the same
bearer session. Flutter never sends a trusted user ID. Mock authentication exists
for local UI development; durable multi-run accounts require API/Prisma mode.

## Home hub architecture

Home is a repository-lazy mobile hub. It does not fetch Subjects or other remote
learning data during startup. An explicit Start Learning, Browse Subjects, Exam,
or Practice action switches to Learn; Progress and Settings shortcuts switch to
their corresponding shell tabs.

The Home feature is split into a screen, immutable banner model, and focused
widgets under `lib/features/home`. Its `PageView` is manually controlled and does
not auto-rotate. Banner copy describes real learning flows rather than prices,
discounts, or unsupported product claims. Study Materials is now an active deep
route. Saved Question Sets is active; Learning Plans remains post-MVP and is not
shown as a misleading functional action.

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

## UI system

The learner app uses a mobile-first Material 3 theme backed by shared semantic
color, spacing, radius, icon, layout, elevation, and motion tokens. Auth, Home,
navigation, subject browsing, and learning states share the same hierarchy and
accessibility rules. Home displays only real actions and available account data;
it does not invent recommendations, streaks, or progress. See
[`docs/UI_UX_REDESIGN.md`](../docs/UI_UX_REDESIGN.md) for the research and audit.

Build a local release candidate with an explicit deployed HTTPS API origin:

```powershell
flutter build apk --release `
  --dart-define=STUDYHUB_LEARNING_SOURCE=api `
  --dart-define=STUDYHUB_API_BASE_URL=https://<deployed-api-origin>
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Current
release builds use debug signing for local installation only; production
distribution requires a private upload keystore configured outside Git. See
[`docs/RELEASE_READINESS.md`](../docs/RELEASE_READINESS.md).

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

Creators may save drafts, reopen/edit/delete owned drafts, submit them for review,
and inspect draft, pending-review, approved, or rejected status. Mock mode validates
locally; API mode uses authenticated contribution endpoints. A
failed request keeps form state and retries with the same client submission ID,
allowing the backend to return the original pending-review submission instead
of creating a duplicate. Moderation actions and rewards remain deferred; ordinary
users cannot mutate a submission after it leaves draft state.

## Saved Question Sets

The Question Set detail app-bar action saves or removes a bookmark through an
injected `BookmarkRepository`. Saved is available from Home and Settings. API
mode persists account-owned bookmarks on the backend with duplicate prevention;
mock mode keeps a development-only in-memory list.

The creator contract currently allows at most 50 questions and 8 answer options
per question. The prepared contribution and idempotency migrations plus a real
Flutter API-mode submit/retry still require manual verification before this flow
is treated as database-ready.

Core stabilization guards history retries, Practice completion, and creator
confirmation against repeated taps. Recoverable failures keep the current
result or creator draft visible. Parsed full-exam previews render question cards
lazily, and success/error states remain scrollable on short phones with large
text.

## Account experience

Email/password authentication restores a backend-issued session and protects
account-owned attempts, bookmarks, and submissions. Profile shows real attempt,
saved-set, and submission counts, and links to History, Saved, and Contributions.
Saved items can be removed or reopened in the normal learner flow. Contribution
management supports draft actions and read-only pending, approved, and rejected
details, including moderator rejection notes.

Google sign-in remains disabled until provider-console configuration and secure
backend ID-token verification are implemented. Facebook is hidden. See
[`docs/SOCIAL_AUTH_SETUP.md`](../docs/SOCIAL_AUTH_SETUP.md); no client-only or
fake provider login is used.

## Notifications and question media

Settings contains an opt-in daily study reminder with a persisted time. The app
does not request notification permission at startup, remembers a denial, and
links to system settings when permission is unavailable. Reminders use one
quiet channel, inexact daily scheduling, and open the existing Home shell.

Question and explanation images are optional. The creator uses Android's system
photo picker, uploads through `MediaRepository`, and keeps all text when upload
fails. Images render in a stable, bounded frame with loading/error states and a
zoomable preview. API mode uses `POST /media/images`; mock mode keeps preview
bytes in memory only. Camera, GIF playback, and video playback are deferred.

## Advertising boundary

Advertising is centralized under `lib/features/advertising/`. UI screens depend
on `AdvertisingService`, while Google Mobile Ads remains isolated in one
provider adapter. Supported modes are `disabled` (default), `test`, and
`production`.

Run Android with official provider test ads:

```powershell
flutter run --dart-define=STUDYHUB_AD_MODE=test
```

Production additionally requires `STUDYHUB_AD_BANNER_ID`,
`STUDYHUB_AD_INTERSTITIAL_ID`, and `STUDYHUB_AD_REWARDED_ID` as dart-defines.
Supply the Android app ID outside Git with the Gradle environment property:

```powershell
$env:ORG_GRADLE_PROJECT_STUDYHUB_ADMOB_APP_ID = "<provider-app-id>"
$env:ORG_GRADLE_PROJECT_STUDYHUB_AD_BUILD_MODE = "production"
```

Production requests remain blocked while consent status is unresolved. A real
provider consent flow must set `AdvertisingConsentStatus.granted` or
`notRequired`; compile-time flags are not treated as legal consent. The current
requests are non-personalized.

Allowed placements are a non-critical Home section and the end of History.
Interstitials are considered only after an Exam result returns to Home: at
least 3 completed exams, a 10-minute cooldown, at most 2 per session and 3 per
local day. Rewarded ads optionally disable banners/interstitials for the current
session and grant the reward only after the provider completion callback.

Ads are prohibited in auth, contribution forms, question/answer UI, result
review cards, and before results or persistence completes. Loading failures,
offline/no-fill cases, and unsupported platforms never block navigation.
The native provider is configured for Android in this milestone. iOS requires
separate provider registration and `Info.plist` configuration before it is
allowed to initialize.
