-- Add server-owned administration state without changing existing learner data.
CREATE TYPE "UserRole" AS ENUM ('user', 'admin');
CREATE TYPE "UserStatus" AS ENUM ('active', 'disabled');

ALTER TABLE "User"
ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'user',
ADD COLUMN "status" "UserStatus" NOT NULL DEFAULT 'active';

ALTER TABLE "Subject" ADD COLUMN "isArchived" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "Topic" ADD COLUMN "isArchived" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "QuestionSet"
ADD COLUMN "isArchived" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "reviewedByUserId" TEXT;

CREATE INDEX "User_status_role_createdAt_idx" ON "User"("status", "role", "createdAt");
CREATE INDEX "Subject_isArchived_name_idx" ON "Subject"("isArchived", "name");
CREATE INDEX "Topic_subjectId_isArchived_name_idx" ON "Topic"("subjectId", "isArchived", "name");
CREATE INDEX "QuestionSet_isArchived_status_createdAt_id_idx"
ON "QuestionSet"("isArchived", "status", "createdAt", "id");
