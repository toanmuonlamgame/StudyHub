# StudyHub Tech Stack

## Confirmed Stack
StudyHub uses this stack:

- Frontend: Flutter / Dart
- Backend runtime: Node.js
- Backend language: TypeScript
- Backend framework: Fastify
- ORM / database access layer: Prisma
- Database: PostgreSQL

These choices are already confirmed and should not be re-proposed unless the project owner explicitly reopens the decision.

## Frontend
Flutter / Dart is the mobile app layer.

Responsibilities:

- Render the learning UI.
- Display taxonomy, Question Sets, quizzes, results, and upload placeholder screens.
- Call approved backend APIs.
- Show backend-provided account, content, permission, unlock, reward, or credit state.

Frontend must not:

- Call the database directly.
- Store database credentials or service keys.
- Act as the source of truth for roles, permissions, credits, rewards, unlocks, or database logic.

## Backend
Node.js is the backend runtime. Backend application code should be written in TypeScript.

Fastify is the backend framework for V1.

Responsibilities:

- Serve approved APIs to the Flutter app.
- Own authentication and authorization when real auth is added.
- Validate uploads and content access.
- Enforce roles and permissions.
- Own future Study Credit transactions and reward calculation.
- Write audit logs for sensitive credit/reward/admin actions.
- Apply rate limiting where needed.

Why this choice fits StudyHub:

- Node.js fits the JavaScript ecosystem.
- TypeScript makes backend data shapes clearer, reduces avoidable runtime mistakes, and makes AI review easier.
- Fastify is lightweight, fast, and less over-engineered than NestJS for V1.
- This stack supports the learning goal, internship portfolio goal, and future codebase growth.

## Database
PostgreSQL is the database layer.

Responsibilities:

- Store users, taxonomy, Question Sets, questions, quiz attempts, and uploads.
- Support structured relational data.
- Support future content quality, moderation, unlock, credit, and audit-log data.

Prisma is the ORM / database access layer.

Prisma responsibilities:

- Define and manage the database schema.
- Run migrations.
- Provide clear TypeScript-friendly PostgreSQL queries.
- Keep database access explicit and reviewable.

## V1 Technical Scope
V1 should use the confirmed stack to support:

- Subject-required taxonomy.
- Optional school, program/system, major, and topic metadata.
- Browse Question Sets.
- Simple multiple-choice quiz.
- Quiz result display.
- Upload placeholder with basic metadata.
- Local/demo auth only.

## Deferred Technical Scope
V1 should not implement:

- Full Study Credits economy.
- Content unlock system.
- Ads or payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

## Tooling Context
Installed support tools include:

- ui-ux-pro-max
- mattpocock/skills
- Codebase Memory MCP
- Context Mode

These tools support planning, review, memory, and implementation workflows. Git remains the source of truth.
