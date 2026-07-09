# StudyHub TODO

## Current Phase
Foundation / planning.

## Active
- [x] Confirm product type: mobile learning platform.
- [x] Confirm project goal: learning project and internship portfolio.
- [x] Confirm frontend stack: Flutter / Dart.
- [x] Confirm backend stack: Node.js.
- [x] Confirm database: PostgreSQL.
- [x] Confirm AI workflow roles.
- [x] Confirm flexible taxonomy direction.
- [x] Confirm Study Material and Question Set as separate content types.
- [x] Confirm user upload and community contribution direction.
- [x] Confirm admin may create a small amount of legal seed content.
- [x] Confirm Study Credits are internal only and not withdrawable as real money.
- [x] Define V1 milestone scope in detail.
- [x] Decide authentication approach for V1: local/demo auth only.
- [x] Decide required taxonomy field for V1: Subject.
- [x] Decide optional taxonomy fields for V1: school, program/system, major, topic.
- [x] Decide backend language for V1: TypeScript.
- [x] Decide Node.js API framework: Fastify.
- [x] Decide PostgreSQL access layer / ORM: Prisma.
- [ ] Decide deployment target.
- [ ] Configure GitHub remote.

## V1 Checklist
### Taxonomy And Browsing
- [ ] Create basic flexible taxonomy model for V1.
- [ ] Make Subject required for Question Sets and uploads.
- [ ] Keep school optional in V1.
- [ ] Keep program/system optional in V1.
- [ ] Keep major optional in V1.
- [ ] Keep topic optional in V1.
- [ ] Browse Question Sets by subject.
- [ ] Browse/filter Question Sets by topic when topic exists.

### Quiz Flow
- [ ] Start a simple multiple-choice quiz from a Question Set.
- [ ] Display one or more answer options per question.
- [ ] Record selected answers in a QuizAttempt.
- [ ] Calculate correct count.
- [ ] Calculate wrong count.
- [ ] Calculate percentage score.
- [ ] Show correct answers on the result screen.

### Upload Placeholder
- [ ] Add upload placeholder for document/exam/question set.
- [ ] Capture basic upload metadata.
- [ ] Store upload as StudyMaterialUpload.
- [ ] Keep moderation simple for V1.

### Local/Demo Auth
- [ ] Use local/demo auth for V1 only.
- [ ] Do not implement production authentication in V1.
- [ ] Keep real authentication deferred to the backend phase.

### Minimal V1 Data Model
- [ ] User
- [ ] Subject
- [ ] Topic
- [ ] QuestionSet
- [ ] Question
- [ ] AnswerOption
- [ ] QuizAttempt
- [ ] QuizAttemptAnswer
- [ ] StudyMaterialUpload

## Near-Term Tasks
- [ ] Decide deployment target.
- [ ] Define V1 API boundaries using the security rules in ReadBeforeWork.md.
- [ ] Create first milestone implementation checklist.
- [ ] Learn JavaScript fundamentals needed for the StudyHub backend.
- [ ] Learn TypeScript fundamentals needed for the StudyHub backend.
- [ ] Learn Fastify basics for routing, validation, and plugins.
- [ ] Learn Prisma basics for schema, migrations, and PostgreSQL queries.

## Roadmap
### V1 - Core Learning Flow
- [ ] Basic flexible taxonomy: school, program/system, major, subject, topic.
- [ ] Browse question sets.
- [ ] Take quiz from a question set.
- [ ] View quiz result.
- [ ] Upload study material, exam, or question set.
- [ ] Use local/demo auth only.
- [ ] Keep Study Credits out of V1 except as future-facing terminology if needed.

### V2 - Community Quality And Unlocks
- [ ] Contributor profile.
- [ ] Rating and report system.
- [ ] Duplicate content prevention.
- [ ] Study Credits.
- [ ] Unlock selected content or features using Study Credits.
- [ ] Reward valid, used, high-quality content instead of raw upload count.

### V3 - AI And Monetization Options
- [ ] AI-generated questions from uploaded documents.
- [ ] Human review step before AI-generated questions become available.
- [ ] Ads-for-credit flow.
- [ ] Consider payments after the credit model and content quality loop are proven.

## Content Model Tasks
- [ ] Define Study Material fields.
- [ ] Define Question Set fields.
- [ ] Define how Study Material can be linked to generated or related Question Sets.
- [ ] Define contribution approval rules.
- [ ] Define quality signals for future rewards.
- [ ] Define duplicate detection requirements for V2.

## Documentation Tasks
- [ ] Create docs/PROJECT_OVERVIEW.md after review.
- [ ] Create docs/ARCHITECTURE.md after review.
- [ ] Create docs/TECH_STACK.md after review.
- [ ] Create docs/ROADMAP.md after review.

## Maintenance
- [ ] Keep PROJECT_MEMORY.md updated after important changes.
- [ ] Record architecture/product decisions in DECISIONS.md.
- [ ] Update TODO.md after finishing or changing a task.
- [ ] Commit small working changes.

## Not Doing Yet
- [ ] Do not create docs/ files until explicitly requested.
- [ ] Do not write app code until the first milestone is approved.
- [ ] Do not implement full credit economy in V1.
- [ ] Do not reward users only for uploading content.
- [ ] Do not implement content unlocks in V1.
- [ ] Do not implement ads in V1.
- [ ] Do not implement payments in V1.
- [ ] Do not implement AI question generation in V1.
- [ ] Do not implement marketplace in V1.
- [ ] Do not implement full admin dashboard in V1.
