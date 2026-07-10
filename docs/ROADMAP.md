# StudyHub Roadmap

## Current Phase
StudyHub is in the foundation / planning phase.

The current priority is to turn the confirmed V1 scope into a small, buildable milestone using the confirmed stack:

- Frontend: Flutter / Dart
- Backend: Node.js
- Database: PostgreSQL

## V1 - Core Learning Flow
V1 is the first usable demo milestone.

### V1 Includes
- Basic flexible taxonomy.
- Subject is required.
- School, program/system, major, and topic are optional.
- Browse Question Sets by subject/topic.
- Take a simple multiple-choice quiz.
- View quiz result:
  - correct count
  - wrong count
  - percentage score
  - correct answers
- Upload placeholder for document/exam/question set with basic metadata.
- Local/demo auth only.

### Minimal V1 Data Model
- User
- Subject
- Topic
- QuestionSet
- Question
- AnswerOption
- QuizAttempt
- QuizAttemptAnswer
- StudyMaterialUpload

### V1 Excludes
- Full Study Credits economy.
- Content unlock system.
- Ads.
- Payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

### V1 Checklist
- [x] Choose Node.js API framework: Fastify.
- [x] Choose PostgreSQL access layer / ORM: Prisma.
- [x] Define V1 API boundaries using the security rules.
- [ ] Implement `GET /health`.
- [ ] Implement `GET /subjects`.
- [ ] Implement `GET /topics?subjectId=...`.
- [ ] Implement `GET /question-sets?subjectId=...&topicId=...`.
- [ ] Implement `GET /question-sets/:id` without exposing correct answers.
- [ ] Implement `POST /quiz-attempts`.
- [ ] Implement `POST /quiz-attempts/:attemptId/submit`.
- [ ] Implement `GET /quiz-attempts/:attemptId/result`.
- [ ] Implement `POST /study-material-uploads` as metadata placeholder.
- [ ] Implement basic taxonomy with required Subject.
- [ ] Support optional topic filtering.
- [ ] Implement Question Set browsing.
- [ ] Implement simple multiple-choice quiz.
- [ ] Implement quiz result view.
- [ ] Implement upload placeholder with basic metadata.
- [ ] Keep auth local/demo-only for V1.

## V2 - Community Quality And Unlocks
V2 builds on the core learning loop and starts adding community quality systems.

Planned capabilities:

- Contributor profile.
- Rating and report system.
- Duplicate content prevention.
- Study Credits.
- Unlock selected content or features using Study Credits.
- Reward valid, used, high-quality content instead of raw upload count.

V2 should still keep Study Credits internal only. Credits must not be withdrawable as real money.

## V3 - AI And Monetization Options
V3 explores AI-assisted and monetization-adjacent features after the content foundation is healthier.

Planned capabilities:

- AI-generated questions from uploaded documents.
- Human review before AI-generated questions become available.
- Ads-for-credit flow.
- Consider payments later.

Payments should only be considered after the credit model, content quality loop, and security boundaries are proven.

## Ongoing Principles
- Keep changes small and reviewable.
- Do not over-engineer before V1 works.
- Keep frontend, backend, and database responsibilities separate.
- Treat backend as the source of truth for auth, permissions, credits, unlocks, and rewards.
- Do not store secrets in Flutter or GitHub.
