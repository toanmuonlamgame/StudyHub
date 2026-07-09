# StudyHub Tech Stack

## Confirmed Stack
StudyHub uses this stack:

- Frontend: Flutter / Dart
- Backend: Node.js
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
Node.js is the backend API layer.

Responsibilities:

- Serve approved APIs to the Flutter app.
- Own authentication and authorization when real auth is added.
- Validate uploads and content access.
- Enforce roles and permissions.
- Own future Study Credit transactions and reward calculation.
- Write audit logs for sensitive credit/reward/admin actions.
- Apply rate limiting where needed.

The Node.js API framework is still pending.

## Database
PostgreSQL is the database layer.

Responsibilities:

- Store users, taxonomy, Question Sets, questions, quiz attempts, and uploads.
- Support structured relational data.
- Support future content quality, moderation, unlock, credit, and audit-log data.

The PostgreSQL access layer / ORM is still pending.

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
