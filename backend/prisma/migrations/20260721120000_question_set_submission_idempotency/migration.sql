-- Retry-safe atomic question-set contribution submissions.
ALTER TABLE "QuestionSet"
ADD COLUMN "clientSubmissionId" TEXT,
ADD COLUMN "submissionFingerprint" TEXT;

CREATE UNIQUE INDEX "QuestionSet_clientSubmissionId_key"
ON "QuestionSet"("clientSubmissionId");
