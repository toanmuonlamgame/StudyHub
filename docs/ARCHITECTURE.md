# StudyHub Architecture

## Architecture Status
StudyHub is in the foundation / planning phase. The architecture should stay simple and support the V1 learning flow before adding marketplace, credit economy, AI, or complex moderation features.

## High-Level Flow
```text
Flutter App -> Backend API -> Database
```

The Flutter app must never call the database directly.

## Security Boundary
The backend is the source of truth for security-sensitive behavior.

Frontend is not the source of truth for:

- Account data.
- Roles.
- Admin/moderator permissions.
- Study Credits.
- Rewards.
- Content unlocks.
- Database logic.

Backend is the source of truth for:

- Authentication.
- Authorization.
- Roles and permissions.
- Admin/moderator actions.
- Upload validation.
- Content access.
- Study Credit transactions.
- Reward calculation.
- Audit logs.
- Rate limiting.

The frontend should only render UI from backend responses and call approved backend APIs.

## Trust Rules
- Backend must not trust userId, role, credit amount, unlock status, or reward requests sent by the frontend.
- Backend must derive the acting user from verified authentication context when real auth is added.
- Database secrets, JWT secrets, admin keys, service keys, and production secrets must not be stored in the Flutter app or committed to GitHub.
- Credit and reward logic must be controlled by backend transactions and audit logs.

## V1 Architecture
V1 should support:

- Basic flexible taxonomy.
- Required Subject.
- Optional school, program/system, major, and topic.
- Browsing Question Sets by subject/topic.
- Simple multiple-choice quiz.
- Quiz result calculation.
- Upload placeholder with basic metadata.
- Local/demo auth only.

Real authentication is deferred to the backend phase, but V1 should still avoid patterns that conflict with the security boundary.

## Minimal V1 Data Model
- User
- Subject
- Topic
- QuestionSet
- Question
- AnswerOption
- QuizAttempt
- QuizAttemptAnswer
- StudyMaterialUpload

## Content Model Notes
Study Material and Question Set are separate content types.

StudyMaterialUpload represents the V1 upload placeholder for documents, exams, question sets, or related learning material metadata. It should leave room for later moderation, conversion, duplicate detection, and AI-assisted question generation.

## Deferred Architecture
V1 should not implement:

- Full Study Credits economy.
- Content unlock system.
- Ads or payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

These belong in later phases after the core learning loop works.
