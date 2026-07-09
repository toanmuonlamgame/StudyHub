# StudyHub Project Overview

## Project Identity
- Project name: StudyHub
- Product type: mobile learning platform
- Goal: learning project and internship portfolio
- Current phase: foundation / planning

## Purpose
StudyHub helps users organize and study learning content. The product focuses on browsing structured learning content, practicing Question Sets, viewing quiz results, and preparing for future user/community contribution workflows.

StudyHub is not primarily a pre-seeded question database. Admins may create a small amount of legal seed content to reduce cold start, but the long-term content model is user-owned and community-contributed content.

## Product Direction
StudyHub organizes content using a flexible taxonomy:

- School
- Program / system
- Major
- Subject
- Topic

The taxonomy must support partial paths. Users should not be forced through every level when a content item only needs a subject or topic.

## Core Content Types
### Study Material
Study Material means learning resources such as notes, PDFs, documents, slides, explanations, exams, and uploaded reference material.

### Question Set
Question Set means a practiceable collection of questions used for quizzes, review, or exam preparation.

Study Material and Question Set are separate content types. A Study Material may later be related to a Question Set, but it is not the same thing.

## V1 Scope
V1 is the first usable demo milestone. It proves the core learning flow without building the full platform economy, admin system, marketplace, or AI pipeline.

V1 includes:

- Basic flexible taxonomy.
- Subject is required.
- School, program/system, major, and topic are optional.
- Browse Question Sets by subject/topic.
- Simple multiple-choice quiz.
- Quiz result with correct count, wrong count, percentage score, and correct answers.
- Upload placeholder for document/exam/question set with basic metadata.
- Local/demo auth only.

V1 does not include:

- Full Study Credits economy.
- Content unlock system.
- Ads or payments.
- AI question generation.
- Complex moderation.
- Marketplace.
- Full admin dashboard.

## Long-Term Core Loop
1. User browses or filters content using the flexible taxonomy.
2. User opens a Question Set or Study Material.
3. User studies, takes a quiz, or reviews results.
4. User uploads documents, exams, or question sets.
5. Valid, useful, high-quality contributed content becomes discoverable.
6. Later versions can connect usage and quality to reputation, Study Credits, or unlocks.

## Product Principles
- Keep V1 small and useful.
- Keep architecture simple and avoid over-engineering.
- Do not reward users only for uploading content.
- Reward logic should eventually depend on valid content, real usage, and quality.
- Study Credits are internal only and cannot be withdrawn as real money.
