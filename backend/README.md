# StudyHub Backend

Minimal Fastify and TypeScript backend skeleton for StudyHub.

## Run locally

```bash
npm install
npm run dev
npm test
```

The server uses port `3000` by default and accepts a `PORT` environment variable.

Health check:

```text
GET http://localhost:3000/health
```

## Mock learning API

The current learning API uses in-memory data only:

```text
GET  /learning/subjects
GET  /learning/subjects/:subjectId/topics
GET  /learning/subjects/:subjectId/question-sets
GET  /learning/question-sets/:questionSetId
GET  /learning/question-sets/:questionSetId/questions
POST /learning/question-sets/:questionSetId/submit
```

Question responses omit correctness metadata. Submit scoring uses a private in-memory answer key.

Run all backend tests with `npm test`.
