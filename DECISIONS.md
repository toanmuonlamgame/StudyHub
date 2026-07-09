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
Decision: StudyHub is a mobile learning platform.

Reason:
- The project should be useful as both a learning project and an internship portfolio.
- A mobile learning app gives a clear product surface and a practical portfolio story.
- The project can start small and grow into richer study workflows.

## 2026-07-09 - Content Model
Decision: StudyHub users upload or create their own question banks / study content. The developer does not pre-seed question data as the main content source.

Reason:
- User-owned content makes the product flexible across subjects.
- It avoids requiring the developer to maintain a large default content library.
- It keeps the first version focused on platform behavior instead of content production.

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
- StudyHub needs structured data for users, question banks, questions, and study progress.
- PostgreSQL is a strong portfolio-friendly relational database.
- It keeps the data model explicit and reliable.

## 2026-07-09 - Architecture Principle
Decision: Keep architecture simple and avoid over-engineering.

Reason:
- The project is currently in the foundation / planning phase.
- The first goal is a working learning platform milestone, not a complex architecture showcase.
- Small, reviewable changes are easier for AI-assisted development and future maintenance.

## Pending Decisions
- First usable feature:
- First milestone scope:
- Authentication approach:
- Deployment target:
- API framework for Node.js:
- PostgreSQL access layer / ORM:
