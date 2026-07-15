-- Prepared only. Review and apply this migration manually.
CREATE TYPE "QuestionSetSourceType" AS ENUM ('system', 'community');
CREATE TYPE "QuestionSetStatus" AS ENUM ('draft', 'pendingReview', 'published', 'rejected');

ALTER TABLE "QuestionSet"
ADD COLUMN "status" "QuestionSetStatus" NOT NULL DEFAULT 'published',
ADD COLUMN "sourceType" "QuestionSetSourceType" NOT NULL DEFAULT 'system',
ADD COLUMN "createdByUserId" TEXT,
ADD COLUMN "submittedAt" TIMESTAMP(3),
ADD COLUMN "reviewedAt" TIMESTAMP(3),
ADD COLUMN "publishedAt" TIMESTAMP(3),
ADD COLUMN "rejectionReason" TEXT;

ALTER TABLE "Question" ADD COLUMN "explanation" TEXT;

DROP INDEX IF EXISTS "QuestionSet_subjectId_createdAt_id_idx";
DROP INDEX IF EXISTS "QuestionSet_topicId_createdAt_id_idx";

CREATE INDEX "QuestionSet_status_createdAt_id_idx"
ON "QuestionSet"("status", "createdAt", "id");
CREATE INDEX "QuestionSet_sourceType_status_createdAt_id_idx"
ON "QuestionSet"("sourceType", "status", "createdAt", "id");
CREATE INDEX "QuestionSet_subjectId_status_createdAt_id_idx"
ON "QuestionSet"("subjectId", "status", "createdAt", "id");
CREATE INDEX "QuestionSet_topicId_status_createdAt_id_idx"
ON "QuestionSet"("topicId", "status", "createdAt", "id");
