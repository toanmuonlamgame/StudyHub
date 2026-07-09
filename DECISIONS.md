# StudyHub Decisions

Use this file to record decisions that affect project direction, architecture, tools, or workflow.

## 2026-07-09 - Collaboration Workflow
Decision: Use Git plus project memory files as the shared context between Codex, Antigravity, ChatGPT, and the user.

Reason:
- Chat history is not a reliable source of truth across tools.
- Project files are visible to the coding/planning tools.
- Git commits make changes reviewable and recoverable.

Rule:
- Codex app is the main coding assistant.
- Antigravity is planner, reviewer, and helper.
- ChatGPT is mentor.
- One AI should be the main editor for a task.
- The other AI should review, explain, or plan unless explicitly assigned to edit.

## 2026-07-09 - Product Direction
Decision: StudyHub is a mobile learning platform for organizing and studying learning content.

Reason:
- The project should be useful as both a learning project and an internship portfolio.
- A mobile learning app gives a clear product surface and a practical portfolio story.
- The project can start small and grow into richer study workflows.

## 2026-07-09 - Flexible Taxonomy
Decision: StudyHub organizes content by school, program/system, major, subject, and topic, but the taxonomy must be flexible and optional by level.

Reason:
- Real learning content does not always fit every level.
- Some users may only know the subject or topic.
- A flexible taxonomy avoids blocking uploads and browsing when metadata is incomplete.

Rule:
- Do not force every content item or user journey through all taxonomy levels.
- Support partial taxonomy paths.

## 2026-07-09 - Study Material And Question Set Are Separate Content Types
Decision: Study Material and Question Set are distinct content types.

Reason:
- Study Material is for notes, documents, PDFs, slides, explanations, and reference resources.
- Question Set is for practiceable questions used in quizzes and review.
- Keeping them separate avoids confusing upload/storage, quiz logic, moderation, and future AI generation flows.

Rule:
- A Study Material may be related to a Question Set, but it is not the same thing.
- A document that later produces questions should still remain a Study Material with related generated/reviewed Question Sets.

## 2026-07-09 - Content Source Model
Decision: Users can study existing question sets, upload documents/exams/question sets, and contribute community content.

Reason:
- StudyHub should support both immediate studying and long-term community growth.
- User-owned and community-contributed content makes the platform useful across schools, majors, and subjects.
- Upload and contribution workflows are central to the product.

## 2026-07-09 - Admin Seed Content
Decision: Admins may create a small amount of legal seed content at the start.

Reason:
- Some seed content helps solve cold start.
- Seed content should be limited and lawful.
- The long-term content model should still rely on user uploads and community contributions.

Rule:
- Do not treat pre-seeded content as the primary product strategy.

## 2026-07-09 - Reward And Quality Model
Decision: Do not reward users with credits only because they upload content. Rewards should be based on content validity, actual use, and quality.

Reason:
- Upload-count rewards encourage spam and low-quality content.
- Usage and quality signals better align rewards with real learning value.
- This keeps community incentives healthier.

## 2026-07-09 - Study Credits
Decision: Study Credits are internal credits for unlocking selected content or features. They cannot be withdrawn as real money.

Reason:
- Internal credits can support engagement and unlock mechanics without creating a cash-out economy.
- Avoiding real-money withdrawal reduces complexity, fraud risk, and compliance burden.

Rule:
- V1 should not implement the full credit economy.
- Credit behavior belongs in later roadmap phases after the core learning flow works.

## 2026-07-09 - Roadmap Direction
Decision: Use a phased roadmap.

V1:
- Basic taxonomy.
- Browse question sets.
- Take quiz.
- View result.
- Upload documents/exams/question sets.

V2:
- Contributor profile.
- Rating/report.
- Duplicate prevention.
- Study Credits.
- Unlock content.

V3:
- AI-generated questions from documents with review.
- Ads-for-credit.
- Consider payments later.

Reason:
- V1 should prove the core learning loop before adding economy, moderation complexity, AI, ads, or payments.
- V2 can improve community quality and controlled unlock mechanics.
- V3 can add AI and monetization options after the platform has a stronger content foundation.

## 2026-07-09 - Frontend Stack
Decision: Use Flutter / Dart for the frontend.

Reason:
- StudyHub is a mobile learning platform.
- Flutter is suitable for building a polished mobile app experience.
- Flutter / Dart is useful for portfolio development.

## 2026-07-09 - Backend Stack
Decision: Use Node.js for the backend.

Reason:
- Node.js is practical for building API services.
- It is common in web/mobile app stacks and useful for internship preparation.
- It can stay simple for the first milestone.

## 2026-07-09 - Database
Decision: Use PostgreSQL as the database.

Reason:
- StudyHub needs structured data for users, taxonomy, study materials, question sets, questions, quiz attempts, and content quality signals.
- PostgreSQL is a strong portfolio-friendly relational database.
- It keeps the data model explicit and reliable.

## 2026-07-09 - Architecture Principle
Decision: Keep architecture simple and avoid over-engineering.

Reason:
- The project is currently in the foundation / planning phase.
- The first goal is a working learning platform milestone, not a complex architecture showcase.
- Small, reviewable changes are easier for AI-assisted development and future maintenance.

## 2026-07-09 - Security Boundary And Source Of Truth
Decision: StudyHub uses a strict client-server security boundary. The standard data flow is Flutter App -> Backend API -> Database. The Flutter frontend must never call the database directly.

Reason:
- Mobile clients can be inspected, modified, or replayed by users.
- Frontend state is useful for UI, but it cannot be trusted for security-sensitive decisions.
- StudyHub includes roles, moderation, content unlocks, Study Credits, and rewards, so the backend must own the authoritative logic.
- A clear boundary keeps the architecture simple while avoiding dangerous shortcuts.

Frontend rule:
- The frontend only displays UI according to backend responses.
- The frontend only calls approved backend APIs.
- The frontend is not the source of truth for account data, roles, admin/moderator permissions, Study Credits, rewards, content unlocks, or database logic.
- The frontend must not contain database secrets, JWT secrets, admin keys, or service keys.

Backend rule:
- The backend is the source of truth for authentication, authorization, roles/permissions, admin/moderator actions, upload validation, content access, Study Credit transactions, reward calculation, audit logs, and rate limiting.
- The backend must not trust userId, role, credit amount, unlock status, or reward requests sent by the frontend.
- The backend must derive the acting user from verified authentication context, not from arbitrary request body fields.
- The backend must check permissions server-side for admin, moderator, upload, unlock, reward, and credit actions.

Credit and reward safety:
- Credit and reward logic must be controlled by the backend.
- Study Credit transactions must be recorded with transaction-safe database writes.
- Credit/reward changes should have audit logs so future moderation, debugging, and abuse investigation are possible.
- Reward calculation must not be triggered merely by a frontend claim that content was uploaded, used, unlocked, or should be rewarded.

Secrets rule:
- Database credentials, JWT secrets, admin keys, service keys, and production secrets must not be committed to GitHub.
- Secrets must not be embedded in the Flutter app.
- Use environment variables or a proper secret management approach for backend/runtime secrets.

## Pending Decisions
- V1 milestone scope:
- Authentication approach:
- Deployment target:
- API framework for Node.js:
- PostgreSQL access layer / ORM:
- Moderation approach for uploaded content:
- Required vs optional taxonomy fields in V1:
