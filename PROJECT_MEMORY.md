# StudyHub Project Memory

## Project Identity
- Project name: StudyHub
- Product type: mobile learning platform
- Goal: learning project and internship portfolio
- Current phase: foundation / planning

## Product Purpose
StudyHub is a mobile learning platform for organizing and studying learning content. The product should help users browse structured learning content, practice question sets, upload their own materials, and contribute useful community content.

StudyHub is not a pre-seeded question database first. It should support a small amount of legal admin-created seed content to solve cold start, but the long-term model is user-owned and community-contributed learning content.

## Confirmed Product Direction
- StudyHub organizes content by school, program/system, major, subject, and topic.
- The taxonomy must be flexible. Users should not be forced to pass through every taxonomy level when their content does not need it.
- Study Material and Question Set are separate content types.
- Users can study existing question sets.
- Users can upload documents, exams, question sets, and other study content.
- Users can contribute community content.
- Admins may create a small amount of legal seed content at the start to reduce cold start.
- Rewards should not be granted just because someone uploads content.
- Reward logic should be based on valid content, real usage, and quality.
- Study Credits are internal credits for unlocking selected content or features.
- Study Credits cannot be withdrawn as real money.
- V1 should not implement the full credit economy.

## Core Content Model
### Taxonomy
Content can be organized through these optional levels:

- School
- Program / system
- Major
- Subject
- Topic

The taxonomy should support partial paths. For example:

- A user may browse directly by subject without choosing a school.
- A question set may belong to a subject and topic but no major.
- Community content may be tagged broadly until more structure is available.

### Study Material
Study Material means learning resources such as notes, PDFs, documents, slides, explanations, and uploaded reference material.

### Question Set
Question Set means a practiceable collection of questions used for quizzes, review, or exam preparation.

Study Material and Question Set should stay distinct even when a document later produces questions.

## Long-Term Core Loop
1. User browses or filters content using the flexible taxonomy.
2. User opens a Question Set or Study Material.
3. User studies, takes a quiz, or reviews results.
4. User uploads documents, exams, or question sets.
5. Valid, useful, high-quality contributed content becomes discoverable.
6. In later versions, high-quality usage can affect reputation, credits, or unlocks.

## Confirmed Tech Stack
- Frontend: Flutter / Dart
- Backend: Node.js
- Database: PostgreSQL

## Current Repository Status
- Local project path: F:\Projects\StudyHub
- Current phase: foundation / planning
- Current structure includes project memory files and planning docs.
- App code has not been started yet.
- docs/ files should not be created until explicitly requested.

## Roadmap Summary
- V1: basic taxonomy, browse question sets, take quiz, view results, upload documents/exams.
- V2: contributor profiles, rating/report, duplicate prevention, Study Credits, unlock content.
- V3: AI-generated questions from documents with review, ads-for-credit, possible payments later.

## Architecture Guidance
- Keep architecture simple.
- Avoid over-engineering.
- Prefer a small, understandable structure over premature abstractions.
- Build V1 around the smallest useful learning workflow.
- Do not implement the full credit economy in V1.
- Record meaningful architecture, product, and workflow decisions in DECISIONS.md.

## AI Workflow
- Codex app: main coding assistant.
- Antigravity: planner, reviewer, and helper.
- ChatGPT: mentor.

Only one AI should be the main editor for a task. Do not let Codex and Antigravity edit the same files at the same time.

## Installed Support Tools
- ui-ux-pro-max
- mattpocock/skills
- Codebase Memory MCP
- Context Mode

## Collaboration Workflow
- Git is the source of truth.
- Important context must be written into project files, not kept only in chat history.
- Active work should be tracked in TODO.md.
- Meaningful decisions should be recorded in DECISIONS.md.
- Keep changes small and reviewable.
- Commit after each working milestone.

## Handoff Format
When switching from one AI/tool to another, use:

```text
Handoff summary:
- Goal:
- Files changed:
- What works:
- What is unfinished:
- Known issues:
- Recommended next step:
```
