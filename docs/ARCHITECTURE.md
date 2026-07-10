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

## V1 API Boundaries
API means backend code written for Flutter to call. It is not a programming language and not a third-party service.

V1 API flow:

```text
Flutter App -> Backend API -> Database
```

The backend owns validation, scoring, user context, and database writes. Flutter must not call the database directly and must not send trusted score, userId, role, credit, unlock, or reward values.

### V1 Endpoints
```text
GET  /health

GET  /subjects
GET  /topics?subjectId=sub_1

GET  /question-sets?subjectId=sub_1&topicId=topic_1
GET  /question-sets/:id

POST /quiz-attempts
POST /quiz-attempts/:attemptId/submit
GET  /quiz-attempts/:attemptId/result

POST /study-material-uploads
```

### Response Safety
- `GET /question-sets/:id` returns questions and answer options only.
- `GET /question-sets/:id` must not return `isCorrect` or `correctAnswerOptionId`.
- Correct answers are only exposed after quiz submission through the result endpoint.
- Backend calculates score. Flutter does not send score.

### Quiz API Shape
Use the standard two-step quiz flow:

```text
POST /quiz-attempts
POST /quiz-attempts/:attemptId/submit
GET  /quiz-attempts/:attemptId/result
```

This is slightly more work than a single submit endpoint, but it prepares V1 for in-progress attempts, continuing a quiz later, and quiz history.

### Upload API Shape
Use:

```text
POST /study-material-uploads
```

V1 upload is a metadata placeholder. V1 does not need real file storage. If Flutter lets the user select a file in the UI, V1 does not process production storage yet.

### Status Fields
QuestionSet and StudyMaterialUpload should include simple status fields so later moderation can fit without reshaping the model.

Suggested statuses:

- `draft`
- `published`
- `pending_review`
- `rejected`

V1 can keep behavior simple while still storing a status.

### Optional Taxonomy Endpoint
V1 can keep separate endpoints:

```text
GET /subjects
GET /topics?subjectId=sub_1
```

If Flutter needs simpler screen loading, add:

```text
GET /taxonomy
```

`GET /taxonomy` should return the basic subject/topic structure. It is optional for V1, not required.

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
